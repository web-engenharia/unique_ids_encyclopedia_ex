defmodule Uuid.UuidV6Test do
  use ExUnit.Case, async: true

  # Para acessar as funções privadas para o teste de validação da RFC.
  import Uuid.UuidV6,
    only: [
      assemble_binary: 5,
      format_to_string: 1
    ]

  describe "generate/0" do
    test "retorna uma string no formato UUID padrão" do
      uuid = Uuid.UuidV6.generate()
      regex = ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      assert Regex.match?(regex, uuid)
    end

    test "o UUID gerado tem a versão 6" do
      uuid = Uuid.UuidV6.generate()
      # A versão está no 13º caractere (índice 14, -1 do hífen)
      version_char = String.at(uuid, 14)
      assert version_char == "6"
    end

    test "o UUID gerado tem a variante correta (RFC 4122)" do
      uuid = Uuid.UuidV6.generate()
      # A variante está no 17º caractere (índice 19)
      # Deve ser '8', '9', 'a', ou 'b'.
      variant_char = String.at(uuid, 19)
      assert variant_char in ["8", "9", "a", "b"]
    end

    test "gera UUIDs únicos em chamadas consecutivas" do
      # Gera uma lista de UUIDs e verifica se todos são únicos
      uuid_list = Enum.map(1..100, fn _ -> Uuid.UuidV6.generate() end)
      assert length(Enum.uniq(uuid_list)) == 100
    end

    test "UUIDs gerados em sequência são classificáveis (sortable)" do
      uuid1 = Uuid.UuidV6.generate()
      # Uma pequena pausa para garantir que o timestamp mude
      Process.sleep(1)
      uuid2 = Uuid.UuidV6.generate()

      assert uuid1 < uuid2
      assert Enum.sort([uuid2, uuid1]) == [uuid1, uuid2]
    end
  end

  describe "validação com vetor de teste da RFC 9562" do
    test "monta corretamente o UUID de exemplo do Apêndice A.5 da RFC 9562" do
      # Valores do Apêndice A.5 da RFC 9562
      # Timestamp: 0x1EC9414C232AB00
      # Isso corresponde a: 2022-06-02 21:03:41.132890Z
      time_high = 0x1EC9414C
      time_mid = 0x232A
      time_low = 0xB00

      # Clock Sequence (14 bits): 0x33C8
      # Isso é derivado dos octetos 8 (0xB3) e 9 (0xC8) do exemplo.
      clock_seq = 0x33C8

      # Node ID (48 bits): 0x9F6BDECED846
      node = <<0x9F, 0x6B, 0xDE, 0xCE, 0xD8, 0x46>>

      expected_uuid_string = "1ec9414c-232a-6b00-b3c8-9f6bdeced846"

      # Usa as funções privadas do módulo para montar o binário
      binary = assemble_binary(time_high, time_mid, time_low, clock_seq, node)

      # E depois formata para string
      generated_string = format_to_string(binary)

      assert generated_string == expected_uuid_string
    end
  end

  describe "Uuid.UuidV6.NodeID" do
    test "gera um node ID de 6 bytes (48 bits)" do
      node_id = Uuid.UuidV6.NodeID.generate_random()
      assert byte_size(node_id) == 6
    end

    test "define o bit multicast no node ID aleatório" do
      # O bit menos significativo (LSB) do primeiro byte deve ser 1
      <<first_byte::8, _rest::binary>> = Uuid.UuidV6.NodeID.generate_random()
      # Verifica se o bit está setado com uma operação AND bit a bit
      assert Bitwise.band(first_byte, 0x01) == 0x01
    end
  end

  describe "Uuid.UuidV6.ClockSequence" do
    test "gera uma sequência de clock dentro do range de 14 bits" do
      clock_seq = Uuid.UuidV6.ClockSequence.generate_random()
      # 16383
      max_14_bit_value = 0x3FFF

      assert is_integer(clock_seq)
      assert clock_seq >= 0
      assert clock_seq <= max_14_bit_value
    end
  end
end
