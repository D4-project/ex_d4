defmodule Exd4Test do
  use ExUnit.Case, async: true

  require Logger

  test "Encapsulating and shiping data to a d4 server" do
    options = [
      :binary,
      active: false,
      verify: :verify_none
    ]

    d4_connection = %Exd4{
      destination: {10, 106, 129, 254},
      uuid: "b5062e1f-674e-45a0-9c30-2557d6e70ef5"
    }

    :ok = :ssl.start()

    case :ssl.connect(d4_connection.destination, d4_connection.port, options, 5_000) do
      {:ok, socket} ->
        case Exd4.encapsulate!(d4_connection, "123456789\n") do
          {:ok, packet} ->
            assert :ssl.send(socket, packet) == :ok
        end

        case Exd4.encapsulate!(d4_connection, "Is my D4 client broken??\n") do
          {:ok, packet} ->
            assert :ssl.send(socket, packet) == :ok
        end

        :ok = :ssl.close(socket)

      {:error, reason} ->
        Logger.error("Failed to connect to test server #{inspect({:error, reason})}")
    end
  end
end
