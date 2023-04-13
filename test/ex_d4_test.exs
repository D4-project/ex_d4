defmodule Exd4Test do
  use ExUnit.Case, async: true

  require Logger

  test "Configuring a d4 connection from config" do
    d4_connection = %Exd4{
      destination: Exd4.d4_ip(),
      port: Exd4.d4_port(),
      uuid: Exd4.d4_uuid(),
      type: Exd4.d4_type(),
      version: Exd4.d4_version(),
      snaplen: Exd4.d4_snaplen(),
      key: Exd4.d4_key()
    }

    assert d4_connection.destination == {10, 106, 129, 254}
    assert d4_connection.port == 4443
    assert d4_connection.uuid == "b5062e1f-674e-45a0-9c30-2557d6e70ef5"
    assert d4_connection.type == 3
    assert d4_connection.version == 1
    assert d4_connection.snaplen == 4096
    assert d4_connection.key == "private key to change"
  end

  test "Encapsulating and shiping data to a d4 server - hardcoded settings" do
    options = [
      :binary,
      active: false,
      verify: :verify_none
    ]

    d4_connection = %Exd4{
      destination: {10, 106, 129, 254},
      uuid: "b5062e1f-674e-45a0-9c30-deaddeaddead"
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

  # TODO sending a type 2 metaheader.
  # test "Sending a type 2 metaheader" do
  # end
end
