defmodule Uuid.UuidV2Test do
  use ExUnit.Case, async: true
  # O alias foi removido para corrigir o aviso, já que o nome completo do módulo é usado.
  # import Bitwise é mantido pois é usado.
  import Bitwise

  describe "generate/0" do
    test "retorna uma string UUID válida" do
      uuid_string = Uuid.UuidV2.generate()

      # Verifica se a string tem o formato UUID padrão
      assert uuid_string =~ ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

      # Usa a biblioteca UUID para uma validação mais robusta
      assert {:ok, _info} = UUID.info(uuid_string)
    end

    test "gera um UUID da versão 2" do
      uuid_string = Uuid.UuidV2.generate()
      {:ok, info} = UUID.info(uuid_string)

      # CORREÇÃO: Usa a sintaxe de Keyword List `[:key]` em vez de `.key`
      assert info[:version] == 2
    end

    test "gera um UUID da variante 1 (RFC 4122)" do
      uuid_string = Uuid.UuidV2.generate()
      {:ok, info} = UUID.info(uuid_string)

      # CORREÇÃO: Usa a sintaxe de Keyword List `[:key]` em vez de `.key`
      assert info[:variant] == :rfc4122
    end

    test "incorpora corretamente o identificador local e o nó do sistema" do
      uuid_string = Uuid.UuidV2.generate()
      # CORREÇÃO: Usa UUID.string_to_binary!/1
      uuid_binary = UUID.string_to_binary!(uuid_string)

      # Extrai os componentes do UUID binário conforme a especificação v2
      <<
        local_identifier::unsigned-big-integer-size(32),
        _time_mid::unsigned-big-integer-size(16),
        _time_hi_and_version::unsigned-big-integer-size(16),
        _clock_seq_hi_and_reserved::unsigned-big-integer-size(8),
        local_domain::unsigned-big-integer-size(8),
        node_id::binary-size(6)
      >> = uuid_binary

      # --- Verifica o Identificador e Domínio Local ---
      case System.cmd("id", ["-u"]) do
        {uid_str, 0} ->
          expected_uid = String.trim(uid_str) |> String.to_integer()

          assert local_domain == 0,
                 "O domínio local deveria ser 0 (Person) quando o UID é encontrado"

          assert local_identifier == expected_uid

        _ ->
          assert local_domain == 2,
                 "O domínio local deveria ser 2 (Org) como fallback quando o UID não é encontrado"
      end

      # --- Verifica o ID do Nó ---
      if mac = find_real_mac_on_system() do
        assert node_id == mac
      else
        <<first_octet::8, _rest::binary>> = node_id
        assert Bitwise.band(first_octet, 1) == 1, "O bit multicast do nó aleatório deve ser 1"
      end
    end

    test "incorpora um timestamp recente e correto" do
      gregorian_epoch_offset = 122_192_928_000_000_000

      ts_before = div(System.system_time(:nanosecond), 100) + gregorian_epoch_offset
      uuid_string = Uuid.UuidV2.generate()
      ts_after = div(System.system_time(:nanosecond), 100) + gregorian_epoch_offset

      # CORREÇÃO: Usa UUID.string_to_binary!/1
      uuid_binary = UUID.string_to_binary!(uuid_string)

      <<_local_id::32, time_mid::16, version_and_time_high::16, _rest::binary>> = uuid_binary

      time_high = Bitwise.band(version_and_time_high, 0x0FFF)
      reconstructed_ts_upper_28_bits = Bitwise.bsl(time_high, 16) ||| time_mid

      ts_before_upper_28_bits = Bitwise.bsr(ts_before, 32)
      ts_after_upper_28_bits = Bitwise.bsr(ts_after, 32)

      assert reconstructed_ts_upper_28_bits >= ts_before_upper_28_bits and
               reconstructed_ts_upper_28_bits <= ts_after_upper_28_bits
    end
  end

  defp find_real_mac_on_system() do
    if Code.ensure_loaded?(MACAddress) do
      case MACAddress.mac_addresses() do
        {:ok, addresses} ->
          Enum.find_value(addresses, fn {_interface, mac_binary} ->
            is_real_mac =
              mac_binary != <<0, 0, 0, 0, 0, 0>> and (mac_binary |> :binary.first() &&& 1) == 0

            if is_real_mac, do: mac_binary
          end)

        _ ->
          nil
      end
    else
      nil
    end
  end
end
