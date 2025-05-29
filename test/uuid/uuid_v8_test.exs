defmodule Uuid.UuidV8Test do
  use ExUnit.Case, async: true
  alias Uuid.UuidV8

  describe "generate/0" do
    test "retorna uma string no formato canônico de UUID" do
      uuid = UuidV8.generate()

      # Verifica se o formato geral está correto (36 caracteres com hífens)
      assert is_binary(uuid)
      assert String.length(uuid) == 36

      # Verifica a posição dos hífens usando uma expressão regular
      # Formato: 8-4-4-4-12
      regex = ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      assert Regex.match?(regex, uuid)
    end

    test "o UUID gerado tem a versão 8 e a variante correta (RFC 4122)" do
      uuid_string = UuidV8.generate()

      # Converte a string de volta para binário para inspecionar os bits
      binary_uuid =
        uuid_string
        |> String.replace("-", "")
        |> Base.decode16!(case: :lower)

      assert byte_size(binary_uuid) == 16

      # Extrai a versão e a variante usando pattern matching
      <<
        _time_low::binary-size(4),
        _time_mid::binary-size(2),
        # O 7º byte (índice 6) contém a versão nos 4 bits mais significativos
        version::4,
        _::12,
        # O 9º byte (índice 8) contém a variante nos 2 bits mais significativos
        variant::2,
        _::62
      >> = binary_uuid

      # A versão DEVE ser 8
      assert version == 8

      # A variante DEVE ser `10` em binário, que é 2 em decimal
      assert variant == 2
    end

    test "gera UUIDs únicos em sucessivas chamadas" do
      # Gera 10,000 UUIDs para verificar a unicidade
      count = 10_000
      generated_uuids = for _ <- 1..count, do: UuidV8.generate()

      # Usa um MapSet para contar os valores únicos
      unique_uuids = MapSet.new(generated_uuids)

      assert MapSet.size(unique_uuids) == count
    end

    test "o timestamp embutido no UUID é preciso" do
      # Captura o tempo antes e depois da geração
      time_before_ms = System.os_time(:millisecond)
      uuid_string = UuidV8.generate()
      time_after_ms = System.os_time(:millisecond)

      # Extrai o timestamp de 48 bits do UUID gerado
      <<timestamp_from_uuid::48, _::80>> =
        uuid_string
        |> String.replace("-", "")
        |> Base.decode16!(case: :lower)

      # Verifica se o timestamp do UUID está dentro da janela de tempo da sua criação
      assert timestamp_from_uuid >= time_before_ms
      assert timestamp_from_uuid <= time_after_ms
    end
  end

  describe "format_to_string/1" do
    test "formata corretamente um binário de 16 bytes" do
      # Exemplo de binário de 16 bytes (128 bits)
      # Corresponde a 018fefb3-a06a-8d1e-8a21-784f183c5c93
      binary = <<25, 239, 239, 179, 160, 106, 141, 30, 138, 33, 120, 79, 24, 60, 92, 147>>

      expected_string = "19efefb3-a06a-8d1e-8a21-784f183c5c93"
      # Nota: A função format_to_string não se importa com a versão/variante,
      # ela apenas formata o binário que recebe.
      # O primeiro byte `25` (0x19) é apenas um exemplo.
      assert UuidV8.format_to_string(binary) == expected_string
    end
  end
end
