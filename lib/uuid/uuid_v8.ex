defmodule Uuid.UuidV8 do
  @moduledoc """
  Implementação para geração de UUID v8, conforme a RFC 9562.
  """

  @doc """
  Gera um UUID v8 e o retorna como uma string formatada.
  """
  def generate() do
    # 1. Obter o timestamp Unix em milissegundos (48 bits).
    unix_ts_ms = System.os_time(:millisecond)

    # 2. Gerar os 74 bits customizáveis (12 + 62) como um bitstring.
    #    Geramos 10 bytes (80 bits) e pegamos apenas o que precisamos.
    <<
      custom_b::bits-size(12),
      custom_c::bits-size(62),
      # Ignora os 6 bits restantes
      _::bits
    >> = :crypto.strong_rand_bytes(10)

    # 3. Montar o UUID binário de 128 bits, seguindo a estrutura da RFC.
    uuid_binary =
      <<
        unix_ts_ms::48,
        # Versão (ver) = 8 (`1000` binário)
        8::4,
        # 12 bits customizáveis
        custom_b::bits,
        # Variante (var) = 2 (`10` binário)
        2::2,
        # 62 bits customizáveis restantes
        custom_c::bits
      >>

    format_to_string(uuid_binary)
  end

  @doc """
  Formata um UUID binário de 16 bytes em sua representação de string canônica.
  """
  def format_to_string(
        <<time_low::binary-size(4), time_mid::binary-size(2), time_hi_and_version::binary-size(2),
          clock_seq_and_reserved::binary-size(2), node::binary-size(6)>>
      ) do
    # Esta função permanece a mesma, pois já estava correta.
    hex =
      (time_low <> time_mid <> time_hi_and_version <> clock_seq_and_reserved <> node)
      |> Base.encode16(case: :lower)

    <<
      hex_time_low::binary-size(8),
      "-",
      hex_time_mid::binary-size(4),
      "-",
      hex_time_hi_and_version::binary-size(4),
      "-",
      hex_clock_seq_and_reserved::binary-size(4),
      "-",
      hex_node::binary-size(12)
    >> =
      <<
        binary_part(hex, 0, 8)::binary,
        "-",
        binary_part(hex, 8, 4)::binary,
        "-",
        binary_part(hex, 12, 4)::binary,
        "-",
        binary_part(hex, 16, 4)::binary,
        "-",
        binary_part(hex, 20, 12)::binary
      >>

    hex_time_low <>
      "-" <>
      hex_time_mid <>
      "-" <>
      hex_time_hi_and_version <>
      "-" <>
      hex_clock_seq_and_reserved <> "-" <> hex_node
  end
end
