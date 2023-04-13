defmodule Exd4 do
  alias Ecto.UUID

  @moduledoc """
  Module that holds D4 connection struct, and provides encapsulation method.
  """
  @moduledoc since: "0.1.0"

  # D4 protocol parameters
  # bits
  @version_size 8
  # bits
  @type_size 8
  # bytes
  @uuid_size 16
  # bits
  @timestamp_size 64
  # bytes
  @hmac_size 32
  # bits
  @size_size 32

  # TODO metaheader implementation
  #  @metaheader_max_size 100_000

  @enforce_keys [:destination, :uuid]

  defstruct destination: nil,
            uuid: nil,
            snaplen: 4096,
            port: 4443,
            key: "private key to change",
            type: 3,
            version: 1

  @typedoc "A d4 connection struct"
  @type t() :: %__MODULE__{
          destination: :inet.ip_address(),
          uuid: String.t(),
          snaplen: non_neg_integer(),
          port: non_neg_integer(),
          key: String.t(),
          type: non_neg_integer(),
          version: non_neg_integer()
        }

  @doc """
  Encapsultate data to ship to a given D4 server.

  Return a tuple {:ok, [IO data]}
  """
  def encapsulate!(d4_connection, data) do
    # initialize header
    uuid_bytes =
      case UUID.dump(d4_connection.uuid) do
        {:ok, uuid_bytes} ->
          uuid_bytes

        :error ->
          raise("Cannot convert UUID #{d4_connection.uuid}")
      end

    timestamp = :os.system_time(:second)
    hmac_init = :binary.copy(<<0>>, @hmac_size)

    # build header
    header = <<
      d4_connection.version::@version_size,
      d4_connection.type::@type_size,
      uuid_bytes::@uuid_size-binary,
      timestamp::unsigned-integer-size(@timestamp_size)-little,
      hmac_init::binary,
      byte_size(data)::unsigned-integer-size(@size_size)-little
    >>

    # compute HMAC on header + data
    hmac =
      :crypto.macN(
        :hmac,
        :sha256,
        :unicode.characters_to_binary(d4_connection.key),
        header <> data,
        32
      )

    # update the HMAC in the header
    header = <<
      d4_connection.version::@version_size,
      d4_connection.type::@type_size,
      uuid_bytes::@uuid_size-binary,
      timestamp::integer-size(@timestamp_size)-little,
      hmac::binary,
      byte_size(data)::unsigned-integer-size(@size_size)-little
    >>

    {:ok, [header, data]}
  end

  def d4_ip, do: Application.fetch_env!(:ex_d4, :destination_ip)
  def d4_port, do: Application.fetch_env!(:ex_d4, :destination_port)
  def d4_uuid, do: Application.fetch_env!(:ex_d4, :uuid)
  def d4_key, do: Application.fetch_env!(:ex_d4, :key)
  def d4_type, do: Application.fetch_env!(:ex_d4, :type)
  def d4_version, do: Application.fetch_env!(:ex_d4, :version)
  def d4_snaplen, do: Application.fetch_env!(:ex_d4, :snaplen)
end
