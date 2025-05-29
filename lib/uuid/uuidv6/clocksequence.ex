defmodule Uuid.UuidV6.ClockSequence do
  @moduledoc false

  # Gera uma sequência de clock aleatória de 14 bits.
  def generate_random do
    <<rand_val::16>> = :crypto.strong_rand_bytes(2)
    # 0x3FFF é a máscara para 14 bits (0b0011111111111111)
    Bitwise.band(rand_val, 0x3FFF)
  end
end
