defmodule Sender do
  @behaviour :gen_statem

  require Logger

  defstruct [:d4_connection, :socket, callers: []]

  ## Public API

  def start_link(opts) do
    d4_connection = Keyword.fetch!(opts, :d4_connection)
    :gen_statem.start_link(__MODULE__, d4_connection, [])
  end

  def send(pid, payload) do
    :gen_statem.call(pid, {:payload, payload})
  end

  def get_status(pid) do
    :gen_statem.call(pid, {:status})
  end

  ## :gen_statem callbacks

  @impl true
  def callback_mode(), do: [:state_functions, :state_enter]

  @impl true
  def init(d4_connection) do
    data = %__MODULE__{d4_connection: d4_connection}
    actions = [{:next_event, :internal, :connect}]
    {:ok, :disconnected, data, actions}
  end

  ## Disconnected state

  def disconnected(:enter, :disconnected, _data), do: :keep_state_and_data

  def disconnected(:enter, :connected, data) do
    Logger.error("Connection closed")

    Enum.each(data.callers, fn {from} ->
      :gen_statem.reply(from, {:error, :disconnected})
    end)

    data = %{data | socket: nil, callers: []}

    actions = [{{:timeout, :reconnect}, 5000, nil}]
    {:keep_state, data, actions}
  end

  def disconnected(:internal, :connect, data) do
    socket_opts = [:binary, active: true, verify: :verify_none]

    case :ssl.connect(data.d4_connection.destination, data.d4_connection.port, socket_opts, 5_000) do
      {:ok, socket} ->
        # Send metaheader or create an empty d4 packet to check whether a session already exists with the same uuid
        {:ok, packet} = if data.d4_connection.type == 2 do
          {:ok, jsonrpr} = JSON.encode(data.d4_connection.metaheader)
          Exd4.encapsulate!(data.d4_connection, jsonrpr)
        else
          Exd4.encapsulate!(data.d4_connection, "")
        end

        case :ssl.send(socket, packet) do
          :ok ->
            # Logger.debug("Connected to d4 server.")
            {:next_state, :connected, %{data | socket: socket}}

          {:error, reason} ->
            Logger.error("D4 server kicked us out #{inspect({:error, reason})}")
            :keep_state_and_data
        end

      {:error, reason} ->
        Logger.error(
          "Connection to d4 server could not be established #{inspect({:error, reason})}"
        )

        :keep_state_and_data
    end
  end

  def disconnected({:timeout, :reconnect}, _, data) do
    actions = [{:next_event, :internal, :connect}]
    {:keep_state, data, actions}
  end

  def disconnected({:call, from}, {:payload, _payload}, _data) do
    actions = [{:reply, from, {:error, :disconnected}}]
    {:keep_state_and_data, actions}
  end

  def disconnected({:call, from}, {:status}, _data) do
    actions = [{:reply, from, {:error, :disconnected}}]
    {:keep_state_and_data, actions}
  end

  ## Connected state

  def connected({:call, from}, {:status}, _data) do
    actions = [{:reply, from, {:ok}}]
    {:keep_state_and_data, actions}
  end

  def connected(:enter, :disconnected, _data) do
    :keep_state_and_data
  end

  def connected(:enter, :connected, _data) do
    :keep_state_and_data
  end

  def connected(:info, {:ssl_closed, socket}, %{socket: socket} = data) do
    Logger.debug(":ssl_closed")
    {:next_state, :disconnected, data}
  end

  def connected({:call, from}, {:payload, payload}, data) do
    {:ok, packet} = Exd4.encapsulate!(data.d4_connection, payload)

    case :ssl.send(data.socket, packet) do
      :ok ->
        Logger.debug("Sent payload to d4 server.")
        :gen_statem.reply(from, {:ok})
        data = %{data | callers: [data.callers | from]}
        {:keep_state, data}

      {:error, reason} ->
        Logger.error("Connection to d4 server lost #{inspect({:error, reason})}")
        :gen_statem.reply(from, {:error, reason})
        :ok = :ssl.close(data.socket)
        {:next_state, :disconnected, data}
    end
  end

  def connected(:info, {:tcp, _socket, _packet}, _ = _data) do
    # D4 server should never send us anything back
    :keep_state_and_data
  end
end
