# Ex_d4

Ex_d4 allows for communicating with d4-servers in elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_d4` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exd4, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_d4>.

## Usage
First, create Exd4 map:
```elixir
d4_connection = %Exd4{
  destination: {192, 168, 0, 1},
  port: 4443,
  uuid: "b5062e1f-beef-45a0-dead-2557d6e70ef6",
  type: 3,
  version: 1,
  snaplen: 4096,
  key: "toto" 
  }
```

Then the Sender can be run by itself:
```elixir
pry(2)> {:ok, pid} = Sender.start_link(d4_connection: d4_connection)
{:ok, #PID<0.267.0>}
# one can also define a name
pry(3)> {:ok, pid} = Sender.start_link([d4_connection: d4_connection, name: :d4sender])
{:ok, #PID<0.275.0>}
```
Or under a supervisor:
```elixir
def start(_type, _args) do
  children = [
    {Sender,
     d4_connection: %Exd4{
       destination: {192, 168, 0, 1},
       uuid: "b5062e1f-674e-45a0-9c30-2557d6e70ef8"
     },
     name: :d4_sender}
  ]
  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

Then, we can send packets using `send`:
```elixir
pry(2)> {:ok} = Sender.send(pid, "{\"this\": \"is my test\"}\n")

14:44:38.813 [debug] Sent payload to d4 server.
{:ok}
#using a name if defined on creation, or launched under the supervisor
pry(3)> {:ok} = Sender.send(:d4sender, "toto\n")

14:46:55.494 [debug] Sent payload to d4 server.
{:ok}
```

## Test
D4 server with the following registered sensors:
`b5062e1f-674e-45a0-9c30-2557d6e70ef5`
`b5062e1f-674e-45a0-9c30-2557d6e70ef6`
`b5062e1f-674e-45a0-9c30-2557d6e70ef7`
`b5062e1f-674e-45a0-9c30-deaddeaddead`