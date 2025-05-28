defmodule Cuid.Cuidv2 do
  @moduledoc """
  Implementação do CUIDv2 (Collision-resistant Unique ID version 2) em Elixir.
  """

  alias Cuid.Cuidv2.{Counter, Fingerprint}

  @typedoc "Um CUIDv2 como uma string."
  @type t :: String.t()

  @default_length 24
  @min_length 2
  @max_length 32
  @random_block_size 32
  # CORREÇÃO: Aumentado para 20 bytes (160 bits) para garantir comprimento suficiente para 32 caracteres.
  @hash_length_bytes 20

  @spec generate(length :: pos_integer()) :: t()
  def generate(length \\ @default_length) when length in @min_length..@max_length do
    timestamp_ms = System.os_time(:millisecond)
    counter = Counter.get_and_increment(timestamp_ms)
    fingerprint = Fingerprint.get()
    session_salt = :crypto.strong_rand_bytes(@random_block_size)

    hash_input = <<
      session_salt::binary,
      fingerprint::binary,
      timestamp_ms::integer-size(64),
      counter::integer-size(32)
    >>

    full_hash = :crypto.hash(:sha3_512, hash_input)
    hash_part = binary_part(full_hash, 0, @hash_length_bytes)

    letter = <<Enum.random(?a..?z)>>
    timestamp_b36 = Integer.to_string(timestamp_ms, 36)
    counter_b36 = Integer.to_string(counter, 36)

    hash_b36 =
      hash_part
      |> :binary.decode_unsigned()
      |> Integer.to_string(36)

    untrimmed_id = letter <> timestamp_b36 <> counter_b36 <> hash_b36
    String.slice(untrimmed_id, 0, length)
  end
end
