defmodule Uuid.UuidV0 do
  @moduledoc """
  Implementação do gerador de UUID v0 (formalmente conhecido como UUID v1).

  Este módulo gera um UUID de 128 bits baseado em tempo, conforme a RFC 4122.
  Ele utiliza:
  - Um timestamp de 60 bits com precisão de 100 nanossegundos desde a
    época gregoriana (15 de Outubro de 1582).
  - Um endereço MAC de 48 bits do host. Se não for encontrado, um nó
    aleatório com o bit multicast definido é usado.
  - Uma sequência de clock de 14 bits para evitar colisões.

  Requer a biblioteca `mac_address` para obter o endereço físico do host.
  """

  alias UUID
  import Bitwise

  @gregorian_to_unix_epoch_offset 0x01B2_1DD2_1381_4000
  @version 1

  def generate() do
    timestamp = get_timestamp()
    clock_seq = get_clock_sequence()
    node_id = get_node_id()

    uuid_binary = assemble_uuid(timestamp, clock_seq, node_id)

    format_binary_to_string(uuid_binary)
  end

  # ===================================================================
  # Funções Privadas
  # ===================================================================

  @spec get_timestamp() :: integer()
  defp get_timestamp do
    unix_nanos = System.os_time(:nanosecond)
    div(unix_nanos, 100) + @gregorian_to_unix_epoch_offset
  end

  @spec get_clock_sequence() :: integer()
  defp get_clock_sequence do
    :rand.uniform(0x3FFF)
  end

  @spec get_node_id() :: binary()
  defp get_node_id do
    find_mac_address() || generate_random_node_id()
  end

  @spec find_mac_address() :: binary() | nil
  defp find_mac_address do
    case MACAddress.mac_addresses() do
      {:ok, mac_list} ->
        Enum.find(mac_list, fn {_, mac} ->
          is_valid_mac?(mac)
        end)
        |> case do
          {_, mac} -> mac
          nil -> nil
        end

      {:error, _reason} ->
        nil
    end
  end

  @spec is_valid_mac?(binary()) :: boolean()
  defp is_valid_mac?(<<b0, _::binary-size(5)>> = mac) do
    mac != <<0, 0, 0, 0, 0, 0>> and (b0 &&& 1) == 0
  end

  @spec generate_random_node_id() :: binary()
  defp generate_random_node_id do
    random_bytes = :crypto.strong_rand_bytes(6)
    <<b0, rest::binary-size(5)>> = random_bytes
    <<b0 ||| 1, rest::binary>>
  end

  @spec assemble_uuid(integer(), integer(), binary()) :: binary()
  def assemble_uuid(timestamp, clock_seq, node_id) do
    time_low = timestamp &&& 0xFFFF_FFFF
    time_mid = timestamp >>> 32 &&& 0xFFFF
    time_high = timestamp >>> 48 &&& 0x0FFF
    time_hi_and_version = time_high ||| @version <<< 12
    clock_seq_low = clock_seq &&& 0xFF
    clock_seq_high = clock_seq >>> 8 &&& 0x3F
    clock_seq_hi_and_reserved = clock_seq_high ||| 0b10 <<< 6

    <<
      time_low::32,
      time_mid::16,
      time_hi_and_version::16,
      clock_seq_hi_and_reserved::8,
      clock_seq_low::8,
      # --- CORREÇÃO AQUI ---
      # A variável `node_id` já é um binário de 6 bytes.
      # Usamos `::binary` para anexá-la diretamente.
      node_id::binary
    >>
  end

  @spec format_binary_to_string(binary()) :: String.t()
  def format_binary_to_string(<<
        time_low::binary-size(4),
        time_mid::binary-size(2),
        time_hi_ver::binary-size(2),
        clock_seq::binary-size(2),
        node::binary-size(6)
      >>) do
    tl = Base.encode16(time_low, case: :lower)
    tm = Base.encode16(time_mid, case: :lower)
    thv = Base.encode16(time_hi_ver, case: :lower)
    cs = Base.encode16(clock_seq, case: :lower)
    n = Base.encode16(node, case: :lower)

    "#{tl}-#{tm}-#{thv}-#{cs}-#{n}"
  end
end
