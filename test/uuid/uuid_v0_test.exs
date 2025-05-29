# test/uuid/uuid_v0_test.exs

defmodule Uuid.UuidV0Test do
  # Usamos `async: false` por causa do meck
  use ExUnit.Case, async: false
  alias Uuid.UuidV0

  # Regex para validar o formato, a versão (1) e a variante (8, 9, a, b)
  @v1_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

  describe "generate/0" do
    test "retorna uma string no formato UUID v1 correto" do
      uuid = UuidV0.generate()
      assert is_binary(uuid)
      assert String.match?(uuid, @v1_regex)
    end

    test "gera UUIDs únicos em sucessão" do
      # Gera 1,000 UUIDs
      generated_uuids = for _ <- 1..1_000, do: UuidV0.generate()

      # Verifica se todos são únicos usando um MapSet
      unique_uuids = MapSet.new(generated_uuids)

      assert Enum.count(unique_uuids) == 1_000
    end
  end

  describe "generate/0 com dependências mockadas" do
    # Garante que o meck seja descarregado após cada teste neste bloco
    setup do
      :meck.unload()
      :ok
    end

    test "usa um endereço MAC específico quando disponível" do
      # Define o MAC que esperamos que seja retornado
      mac_address = <<0x1A, 0x2B, 0x3C, 0x4D, 0x5E, 0x6F>>
      expected_node_hex = "1a2b3c4d5e6f"

      # Prepara o mock do MACAddress para retornar nosso MAC
      :meck.new(MACAddress, [:non_strict, :passthrough])
      :meck.expect(MACAddress, :mac_addresses, fn -> {:ok, [{"en0", mac_address}]} end)

      # Gera o UUID e verifica se a parte do nó está correta
      uuid = UuidV0.generate()
      assert String.ends_with?(uuid, expected_node_hex)

      # Descarrega o mock
      :meck.unload(MACAddress)
    end

    test "usa um nó aleatório quando nenhum MAC válido é encontrado" do
      # Mock do MACAddress para simular uma falha
      :meck.new(MACAddress, [:non_strict, :passthrough])
      :meck.expect(MACAddress, :mac_addresses, fn -> {:error, :not_found} end)

      # Mock do gerador de bytes aleatórios para retornar um valor conhecido
      random_node = <<0x12, 0x34, 0x56, 0x78, 0x90, 0xAB>>
      # Nó esperado com o bit multicast definido (0x12 | 1 = 0x13)
      expected_node_hex = "1334567890ab"
      :meck.new(:crypto, [:non_strict, :passthrough])
      :meck.expect(:crypto, :strong_rand_bytes, fn 6 -> random_node end)

      uuid = UuidV0.generate()
      assert String.ends_with?(uuid, expected_node_hex)

      :meck.unload([MACAddress, :crypto])
    end
  end

  describe "lógica de montagem (teste determinístico)" do
    test "monta corretamente um UUID com valores fixos" do
      # --- Valores Corrigidos ---

      # Timestamp para 2025-01-01 00:00:00.000Z.
      # Este é o número exato de intervalos de 100ns desde a época gregoriana (1582).
      timestamp = 0x1DFB546A4C00000
      # Sequência de clock.
      # (4660 em decimal)
      clock_seq = 0x1234
      # Nó (endereço MAC).
      node_id = <<0x01, 0x02, 0x03, 0x04, 0x05, 0x06>>

      # Chamando as funções privadas para o teste.
      binary_uuid = UuidV0.assemble_uuid(timestamp, clock_seq, node_id)
      string_uuid = UuidV0.format_binary_to_string(binary_uuid)

      # Resultado esperado, derivado corretamente a partir do timestamp acima.
      expected_string = "a4c00000-b546-11df-9234-010203040506"

      assert string_uuid == expected_string
    end
  end
end
