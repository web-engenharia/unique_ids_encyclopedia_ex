# Em test/cuid/cuidv2_test.exs

defmodule Cuid.Cuidv2Test do
  use ExUnit.Case, async: false

  alias Cuid.Cuidv2
  alias Cuid.Cuidv2.{Counter, Fingerprint}

  # `setup` é executado antes de CADA teste, garantindo o isolamento
  # e reiniciando o estado do Counter a cada execução.
  setup do
    start_supervised!(Counter)
    start_supervised!(Fingerprint)
    :ok
  end

  describe "generate/1" do
    test "gera um ID com o comprimento padrão de 24 caracteres" do
      id = Cuidv2.generate()
      assert is_binary(id)
      assert String.length(id) == 24
    end

    test "gera IDs com comprimentos personalizados" do
      assert String.length(Cuidv2.generate(10)) == 10
      assert String.length(Cuidv2.generate(32)) == 32
    end

    test "o ID gerado começa com uma letra minúscula" do
      id = Cuidv2.generate()
      first_char = String.first(id)
      assert first_char >= "a" and first_char <= "z"
    end

    test "o ID gerado contém apenas caracteres válidos (Base36)" do
      id = Cuidv2.generate()
      # Verifica se os caracteres são alfanuméricos, ignorando a caixa (maiúscula/minúscula)
      assert id =~ ~r/^[a-z0-9]+$/i
    end

    test "gera IDs únicos em sequência" do
      # Um número menor é usado para acelerar os testes no dia a dia.
      count = 10_000
      ids = for _ <- 1..count, do: Cuidv2.generate()

      unique_ids_count =
        ids
        |> Enum.into(MapSet.new())
        |> MapSet.size()

      assert unique_ids_count == count
    end
  end

  describe "concorrência" do
    test "gera IDs únicos sob alta concorrência" do
      num_tasks = 100
      ids_per_task = 100

      ids =
        1..num_tasks
        |> Task.async_stream(fn _ ->
          for _ <- 1..ids_per_task, do: Cuidv2.generate()
        end)
        |> Enum.flat_map(fn {:ok, result} -> result end)

      total_generated = num_tasks * ids_per_task

      unique_ids_count =
        ids
        |> Enum.into(MapSet.new())
        |> MapSet.size()

      assert unique_ids_count == total_generated
    end
  end

  describe "componentes internos" do
    test "Counter incrementa no mesmo milissegundo e reinicia no próximo" do
      current_ms = System.os_time(:millisecond)

      assert Counter.get_and_increment(current_ms) == 0
      assert Counter.get_and_increment(current_ms) == 1
      assert Counter.get_and_increment(current_ms) == 2

      next_ms = current_ms + 1

      assert Counter.get_and_increment(next_ms) == 0
      assert Counter.get_and_increment(next_ms) == 1
    end

    test "Fingerprint é estável e retorna o mesmo valor" do
      fingerprint1 = Fingerprint.get()
      fingerprint2 = Fingerprint.get()

      assert is_binary(fingerprint1)
      assert byte_size(fingerprint1) == 32
      assert fingerprint1 == fingerprint2
    end
  end
end
