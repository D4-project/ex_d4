defmodule SenderTest do
  use ExUnit.Case, async: false

  require Logger

  test "Sender connecting to D4 server" do
    d4_connection = %Exd4{
      destination: Exd4.d4_ip(),
      port: Exd4.d4_port(),
      uuid: Exd4.d4_uuid(),
      type: Exd4.d4_type(),
      version: Exd4.d4_version(),
      snaplen: Exd4.d4_snaplen(),
      key: Exd4.d4_key()
    }

    assert {:ok, _} = Sender.start_link(d4_connection: d4_connection)
  end

  test "Sender sending data to D4 Server" do
    d4_connection = %Exd4{
      destination: Exd4.d4_ip(),
      port: Exd4.d4_port(),
      uuid: "b5062e1f-674e-45a0-9c30-2557d6e70ef6",
      type: Exd4.d4_type(),
      version: Exd4.d4_version(),
      snaplen: Exd4.d4_snaplen(),
      key: Exd4.d4_key()
    }

    assert {:ok, pid} = Sender.start_link(d4_connection: d4_connection)

    Sender.send(pid, "😀 😃 😄 😁 😆 😅 😂 🤣 🥲 🤩 🥳 😏 😒 😞 😔 😟 😕 🙁  😐 😑 😬  ☠️ 👽 👾 🤖 🎃 😺 😸 😹 😻 😼 😽 🙀 😿 😾 \n")
    Sender.send(pid, "blip blop\n")
  end

  test "Sender thrown out because of duplucate uuid" do
    d4_connection = %Exd4{
      destination: Exd4.d4_ip(),
      port: Exd4.d4_port(),
      uuid: "b5062e1f-674e-45a0-9c30-2557d6e70ef7",
      type: Exd4.d4_type(),
      version: Exd4.d4_version(),
      snaplen: Exd4.d4_snaplen(),
      key: Exd4.d4_key()
    }

    assert {:ok, pid1} = Sender.start_link(d4_connection: d4_connection)
    assert {:ok} = Sender.send(pid1, "pid1\n")
    assert {:ok, pid2} = Sender.start_link(d4_connection: d4_connection)
    Process.sleep(1000)
    assert {:error, :disconnected} = Sender.get_status(pid2)
  end

  test "D4 server unreachable" do
    d4_connection = %Exd4{
      destination: {10, 106, 129, 1},
      port: 5000,
      uuid: "b5062e1f-674e-45a0-9c30-2557d6e70ef7",
      type: Exd4.d4_type(),
      version: Exd4.d4_version(),
      snaplen: Exd4.d4_snaplen(),
      key: Exd4.d4_key()
    }

    assert {:ok, pid} = Sender.start_link(d4_connection: d4_connection)
    Process.sleep(1000)
    assert {:error, :disconnected} = Sender.get_status(pid)
  end

  test "D4 metaheaders type" do
     d4_connection = %Exd4{
      destination: Exd4.d4_ip(),
      port: Exd4.d4_port(),
      uuid: "b5062e1f-674e-45a0-9c30-2557d6e70ef7",
      type: 2,
      version: Exd4.d4_version(),
      snaplen: Exd4.d4_snaplen(),
      key: Exd4.d4_key(),
      metaheader: %{
        "type" => "json-lines"
      }
    }
    assert {:ok, pid} = Sender.start_link(d4_connection: d4_connection)
    assert {:ok} = Sender.get_status(pid)
    assert {:ok} = Sender.send(pid, "{\"this\": \"is my test\"}\n")
    assert {:ok} = Sender.send(pid, "{\"this\": \"is my another test\"}\n")

  end
end
