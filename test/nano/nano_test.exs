defmodule Nano.NanoTest do
  use ExUnit.Case, async: true

  describe "generate/0" do
    test "gera um ID com o tamanho padrão de 21 caracteres" do
      id = Nano.Nano.generate()
      assert String.length(id) == 21
    end

    test "gera um ID usando o alfabeto padrão" do
      id = Nano.Nano.generate()
      # Regex para validar se todos os caracteres pertencem ao alfabeto padrão
      assert String.match?(id, ~r/^[a-zA-Z0-9_-]{21}$/)
    end
  end

  describe "generate/1" do
    test "gera um ID com o tamanho personalizado especificado" do
      assert String.length(Nano.Nano.generate(10)) == 10
      assert String.length(Nano.Nano.generate(36)) == 36
    end

    test "usa o alfabeto padrão quando apenas o tamanho é especificado" do
      id = Nano.Nano.generate(15)
      assert String.match?(id, ~r/^[a-zA-Z0-9_-]{15}$/)
    end
  end

  describe "generate/2" do
    test "gera um ID com tamanho e alfabeto personalizados" do
      alphabet = "0123456789abcdef"
      size = 12
      id = Nano.Nano.generate(size, alphabet)

      assert String.length(id) == size
      assert String.match?(id, ~r/^[0-9a-f]{#{size}}$/)
    end

    test "funciona com um alfabeto binário" do
      alphabet = "01"
      size = 20
      id = Nano.Nano.generate(size, alphabet)

      assert String.length(id) == size
      assert String.match?(id, ~r/^[01]{#{size}}$/)
    end

    test "funciona com um alfabeto de um único caractere" do
      alphabet = "a"
      size = 5
      id = Nano.Nano.generate(size, alphabet)

      assert id == "aaaaa"
    end

    test "gera IDs longos corretamente" do
      # Testa se a recursão funciona para tamanhos maiores
      assert String.length(Nano.Nano.generate(1024)) == 1024
    end
  end

  describe "validações de entrada e tratamento de erros" do
    test "levanta um erro para tamanho zero" do
      assert_raise ArgumentError, "O tamanho do ID deve ser um inteiro positivo.", fn ->
        Nano.Nano.generate(0)
      end
    end

    test "levanta um erro para tamanho negativo" do
      assert_raise ArgumentError, "O tamanho do ID deve ser um inteiro positivo.", fn ->
        Nano.Nano.generate(-10)
      end
    end

    test "levanta um erro para alfabeto vazio" do
      assert_raise ArgumentError,
                   "O comprimento do alfabeto deve ser entre 1 e 256 caracteres.",
                   fn ->
                     Nano.Nano.generate(10, "")
                   end
    end

    test "levanta um erro para alfabeto com mais de 256 caracteres" do
      long_alphabet =
        String.duplicate("a", 257)
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map_join(fn {_, i} -> <<i::8>> end)

      assert_raise ArgumentError,
                   "O comprimento do alfabeto deve ser entre 1 e 256 caracteres.",
                   fn ->
                     Nano.Nano.generate(10, long_alphabet)
                   end
    end

    test "levanta um erro para alfabeto com caracteres duplicados" do
      assert_raise ArgumentError, "O alfabeto deve conter caracteres únicos.", fn ->
        Nano.Nano.generate(10, "abca")
      end
    end
  end

  describe "propriedades do gerador" do
    test "gera IDs únicos em várias chamadas" do
      # Este teste não prova a aleatoriedade, mas pode capturar erros grosseiros
      # onde o gerador produz o mesmo valor repetidamente.
      generated_ids =
        Enum.map(1..100, fn _ ->
          Nano.Nano.generate()
        end)

      unique_ids = MapSet.new(generated_ids)

      assert MapSet.size(unique_ids) == 100
    end
  end
end
