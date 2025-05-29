defmodule Uuid.UuidV2 do
  @moduledoc """
  Implementação para a geração de UUIDs da Versão 2 (DCE Security).

  UUIDv2 é uma variante rara do UUIDv1, projetada para ambientes DCE (Distributed
  Computing Environment). Ela substitui partes do timestamp e da sequência de
  clock por um identificador de domínio local (como um ID de usuário ou grupo POSIX)
  e um domínio local, respectivamente.

  Esta implementação segue as especificações, gerando os seguintes componentes:

  - **Timestamp**: Um valor de 60 bits representando o número de intervalos de 100ns
    desde 15 de Outubro de 1582. Apenas os 28 bits mais significativos são
    usados no UUID, resultando em uma precisão de aproximadamente 7 minutos.
  - **Identificador Local**: Um inteiro de 32 bits. Por padrão, esta implementação
    tenta obter o ID do usuário (UID) do sistema POSIX executando `id -u`. Se falhar,
    um número aleatório de 32 bits é usado como fallback.
  - **Domínio Local**: Um inteiro de 8 bits. É definido como `0` (Person/Pessoa) ao usar um UID
    real, ou `2` (Org/Organização) ao usar um identificador aleatório.
  - **Sequência de Clock**: Um valor aleatório de 6 bits para evitar colisões.
  - **ID do Nó**: Tenta usar o primeiro endereço MAC não-loopback disponível através da
    biblioteca `mac_address`. Se não for possível, gera um endereço aleatório de 48 bits
    com o bit multicast definido, conforme a RFC 4122.
  """
  alias UUID
  import Bitwise

  # O número de intervalos de 100ns entre a época Gregoriana (1582-10-15) e a época Unix (1970-01-01).
  @gregorian_epoch_offset 122_192_928_000_000_000

  # Constantes da estrutura do UUIDv2.
  @version 2
  # Os 2 bits mais significativos do octeto `clock_seq_hi_and_reserved`.
  @variant 0b10

  # Constantes para o Domínio Local.
  @domain_person 0
  @domain_org 2

  @doc """
  Gera uma string de UUIDv2.
  """
  def generate() do
    {time_mid, time_high} = get_timestamp_parts()
    {local_domain, local_identifier} = get_local_info()
    clock_seq = get_clock_sequence()
    node_id = get_node_id()

    # Monta o UUID binário de 16 bytes de acordo com a especificação v2.
    uuid_binary =
      <<
        local_identifier::unsigned-big-integer-size(32),
        time_mid::unsigned-big-integer-size(16),
        @version <<< 12 ||| time_high::unsigned-big-integer-size(16),
        @variant <<< 6 ||| clock_seq::unsigned-big-integer-size(8),
        local_domain::unsigned-big-integer-size(8),
        node_id::binary-size(6)
      >>

    UUID.binary_to_string!(uuid_binary)
  end

  # --- Helpers Privados ---

  @doc false
  defp get_timestamp_parts() do
    # Calcula o timestamp de 60 bits (intervalos de 100ns desde 1582).
    ts_val = div(System.system_time(:nanosecond), 100) + @gregorian_epoch_offset

    # No UUIDv2, o `time_low` (32 bits LSB do timestamp) é descartado.
    # Extraímos apenas as partes `time_mid` e `time_high`.
    time_mid = ts_val >>> 32 &&& 0xFFFF
    time_high = ts_val >>> 48 &&& 0x0FFF

    {time_mid, time_high}
  end

  @doc false
  defp get_local_info() do
    case System.cmd("id", ["-u"]) do
      # Sucesso ao obter UID do sistema POSIX.
      {uid_str, 0} ->
        {
          @domain_person,
          String.trim(uid_str) |> String.to_integer()
        }

      # Fallback para sistemas não-POSIX ou se o comando falhar.
      _ ->
        {
          @domain_org,
          :crypto.strong_rand_bytes(4) |> :binary.decode_unsigned(:big)
        }
    end
  end

  @doc false
  defp get_clock_sequence() do
    # Para um gerador sem estado, uma sequência de clock aleatória de 6 bits é suficiente.
    # Uma implementação de produção robusta poderia gerenciar o estado para incrementar este valor.
    :crypto.strong_rand_bytes(1) |> :binary.first() &&& 0x3F
  end

  @doc false
  defp get_node_id() do
    # Tenta obter o endereço MAC, com fallback para um nó aleatório.
    find_mac_address() || generate_random_node()
  end

  defp find_mac_address() do
    if Code.ensure_loaded?(MACAddress) do
      case MACAddress.mac_addresses() do
        {:ok, addresses} ->
          Enum.find_value(addresses, fn {_interface, mac_binary} ->
            # Ignora endereços de loopback e multicast.
            if mac_binary != <<0, 0, 0, 0, 0, 0>> and (mac_binary |> :binary.first() &&& 1) == 0 do
              mac_binary
            end
          end)

        _ ->
          nil
      end
    else
      nil
    end
  end

  defp generate_random_node() do
    # Gera 48 bits aleatórios e define o bit multicast (LSB do primeiro octeto) como 1,
    # conforme a RFC 4122 para nós aleatórios.
    <<r1::8, r2::8, r3::8, r4::8, r5::8, r6::8>> = :crypto.strong_rand_bytes(6)
    <<r1 ||| 1::8, r2::8, r3::8, r4::8, r5::8, r6::8>>
  end
end
