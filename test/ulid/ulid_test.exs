defmodule Ulid.UlidTest do
  use ExUnit.Case
  doctest Ulid.Ulid

  # Regex para validar se a string contém apenas caracteres da Base32 de Crockford.
  @crockford_chars_regex ~r/^[0-9A-HJKMNP-TV-Z]{26}$/

  describe "generate/0" do
    test "gera um ULID com 26 caracteres" do
      ulid = Ulid.Ulid.generate()
      assert String.length(ulid) == 26
    end

    test "gera um ULID usando apenas caracteres da Base32 de Crockford" do
      ulid = Ulid.Ulid.generate()
      assert Regex.match?(@crockford_chars_regex, ulid)
    end

    test "gera ULIDs únicos em chamadas consecutivas" do
      ulid1 = Ulid.Ulid.generate()
      ulid2 = Ulid.Ulid.generate()
      assert ulid1 != ulid2
    end

    test "ULIDs são lexicograficamente classificáveis" do
      ulid1 = Ulid.Ulid.generate()
      # Garante que pelo menos um milissegundo tenha passado para um timestamp diferente
      Process.sleep(2)
      ulid2 = Ulid.Ulid.generate()

      assert ulid1 < ulid2
      assert Enum.sort([ulid2, ulid1]) == [ulid1, ulid2]
    end
  end

  describe "generate_at/1" do
    test "gera um ULID para um timestamp específico" do
      # Timestamp de "2016-07-28 01:16:16.385 UTC"
      timestamp = 1_469_918_176_385
      ulid = Ulid.Ulid.generate_at(timestamp)

      assert String.length(ulid) == 26
      assert Regex.match?(@crockford_chars_regex, ulid)
    end

    test "a parte do timestamp é a mesma para ULIDs gerados no mesmo milissegundo" do
      # 2023-01-01 00:00:00.000 UTC
      timestamp = 1_672_531_200_000

      ulid1 = Ulid.Ulid.generate_at(timestamp)
      ulid2 = Ulid.Ulid.generate_at(timestamp)

      # CORREÇÃO: Comparamos os primeiros 9 caracteres (45 bits), que são
      # garantidamente derivados apenas do timestamp de 48 bits.
      assert String.slice(ulid1, 0, 9) == String.slice(ulid2, 0, 9)

      # O ULID completo ainda deve ser diferente devido à parte aleatória.
      assert ulid1 != ulid2
    end

    test "ULIDs gerados com timestamps diferentes são classificáveis" do
      # 2023-01-01 00:00:00.000 UTC
      timestamp1 = 1_672_531_200_000
      # 1 segundo depois
      timestamp2 = timestamp1 + 1000

      ulid1 = Ulid.Ulid.generate_at(timestamp1)
      ulid2 = Ulid.Ulid.generate_at(timestamp2)

      assert ulid1 < ulid2
    end
  end
end
