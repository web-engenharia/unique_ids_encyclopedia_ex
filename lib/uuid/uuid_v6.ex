defmodule Uuid.UuidV6 do
  @moduledoc """
  Implementação para geração de UUIDv6 em Elixir, conforme a RFC 9562.
  """

  alias Uuid.UuidV6.ClockSequence
  alias Uuid.UuidV6.NodeID
  alias Uuid.UuidV6.Timestamp

  # 0b0110
  @version 6
  # 0b10 (usado para os 2 bits mais significativos do octeto 8)
  @variant 2

  @doc """
  Gera um UUIDv6 e o retorna como uma string formatada.

  Utiliza o timestamp UTC atual, um node ID aleatório de 48 bits e uma
  sequência de clock aleatória de 14 bits a cada chamada.

  ## Exemplo
      iex> Uuid.UuidV6.generate()
      "1ed5f8a8-8686-6ae0-b429-01fe35a47e70"

  """
  def generate() do
    # 1. Obter os componentes do UUID
    timestamp_100ns = Timestamp.generate_100ns_timestamp()
    {time_high, time_mid, time_low} = Timestamp.split_timestamp(timestamp_100ns)

    clock_seq = ClockSequence.generate_random()
    node = NodeID.generate_random()

    # 2. Montar o binário de 128 bits
    binary_uuid = assemble_binary(time_high, time_mid, time_low, clock_seq, node)

    # 3. Formatar o binário para a string padrão
    format_to_string(binary_uuid)
  end

  def assemble_binary(time_high, time_mid, time_low, clock_seq, node) do
    # Monta os octetos 8 e 9, que contêm a variante e a sequência de clock.
    # O octeto 8 (clk_seq_hi_res) contém a variante (2 bits) e os 6 bits mais significativos do clock_seq.
    # O octeto 9 (clock_seq_low_octet) contém os 8 bits menos significativos do clock_seq.

    # Pega os 6 bits superiores de clock_seq (que tem 14 bits no total)
    clock_seq_high_part = Bitwise.bsr(clock_seq, 8)

    # Combina a variante (2 bits) e a parte alta do clock_seq (6 bits)
    clk_seq_hi_res_octet = Bitwise.bor(Bitwise.bsl(@variant, 6), clock_seq_high_part)

    # Pega os 8 bits inferiores de clock_seq
    clock_seq_low_octet = Bitwise.band(clock_seq, 0xFF)

    # Constrói o UUID de 128 bits na ordem correta
    <<
      time_high::32,
      time_mid::16,
      @version::4,
      time_low::12,
      clk_seq_hi_res_octet::8,
      clock_seq_low_octet::8,
      node::binary-size(6)
    >>
  end

  def format_to_string(binary_uuid) do
    <<
      # time_high
      p1::binary-size(4),
      # time_mid
      p2::binary-size(2),
      # ver_time_low
      p3::binary-size(2),
      # clk_seq_hi_res, clk_seq_low
      p4::binary-size(2),
      # node
      p5::binary-size(6)
    >> = binary_uuid

    # Concatena as partes codificadas em hexadecimal
    "#{Base.encode16(p1, case: :lower)}-#{Base.encode16(p2, case: :lower)}-#{Base.encode16(p3, case: :lower)}-#{Base.encode16(p4, case: :lower)}-#{Base.encode16(p5, case: :lower)}"
  end
end
