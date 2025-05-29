defmodule Uuid.UuidV6.NodeID do
  @moduledoc false

  # Gera um node ID aleatório de 48 bits (6 bytes).
  # O bit multicast (LSB do primeiro byte) é definido como 1,
  # conforme recomendado pela RFC para node IDs aleatórios.
  def generate_random do
    <<b0::8, rest::binary-size(5)>> = :crypto.strong_rand_bytes(6)
    b0_with_multicast = Bitwise.bor(b0, 0x01)
    <<b0_with_multicast::8, rest::binary>>
  end
end
