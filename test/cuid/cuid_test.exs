defmodule Cuid.CuidTest do
  use ExUnit.Case, async: true
  doctest Cuid.Cuid

  # Para testar o cenário de falha de `generate/0`, é essencial "mockar" (simular)
  # a resposta do módulo `Cuid` do qual ele depende. A biblioteca `mox` é a
  # abordagem idiomática e recomendada em Elixir para isso, pois se baseia
  # em comportamentos (behaviours) explícitos.
  #
  # Assumindo que você não pode alterar a biblioteca `cuid` para adicionar um
  # behaviour, a segunda melhor opção é usar uma biblioteca de mocking como a `mock`.
  #
  # Para este teste funcionar, adicione `{:mock, "~> 0.3.0", only: :test}`
  # ao seu `mix.exs` e execute `mix deps.get`.
  import Mock

  describe "generate/0" do
    test "retorna um CUID válido e único" do
      cuid1 = Cuid.Cuid.generate()
      cuid2 = Cuid.Cuid.generate()

      # Asserções básicas de formato
      assert is_binary(cuid1)
      assert is_binary(cuid2)

      # CORREÇÃO: O CUID padrão começa com "c", e não "c-".
      assert String.starts_with?(cuid1, "c")
      assert String.starts_with?(cuid2, "c")

      # Garante que CUIDs gerados em sequência são únicos
      refute cuid1 == cuid2
    end

    test "lida com falha ao iniciar o processo Cuid" do
      # Usamos `with_mock` para interceptar a chamada a `Cuid.start_link/0`
      # e forçá-la a retornar um erro, sem realmente tentar iniciar o processo.
      with_mock Cuid, start_link: fn -> {:error, :simulated_failure} end do
        # Verificamos se a falha no `start_link` causa um `RuntimeError`,
        # conforme definido na função `Cuid.Cuid.generate/0`.
        expected_message = "Não foi possível gerar CUID: :simulated_failure"

        assert_raise RuntimeError, expected_message, fn ->
          Cuid.Cuid.generate()
        end
      end
    end
  end

  describe "generate/1" do
    # O `setup` inicia um processo Cuid que será usado por todos os testes
    # dentro deste bloco `describe`. O PID é passado para cada teste no `context`.
    # O `on_exit` garante que o processo seja encerrado ao final de cada teste,
    # mantendo os testes limpos e independentes.
    setup do
      {:ok, pid} = Cuid.start_link()
      # Passa o pid para o contexto do teste
      on_exit(fn -> Process.exit(pid, :kill) end)
      {:ok, pid: pid}
    end

    test "retorna um CUID válido usando um PID existente", %{pid: pid} do
      # CORREÇÃO: Para verificar se um processo está ativo pelo seu PID,
      # use `Process.alive?/1`. A função `Process.whereis/1` serve para
      # encontrar um PID a partir de um nome registrado (um átomo).
      assert Process.alive?(pid)

      cuid1 = Cuid.Cuid.generate(pid)
      cuid2 = Cuid.Cuid.generate(pid)

      assert is_binary(cuid1)
      assert String.starts_with?(cuid1, "c")
      refute cuid1 == cuid2

      # O processo ainda deve estar vivo, pois `generate/1` não o encerra.
      assert Process.alive?(pid)
    end

    test "levanta um erro com um argumento inválido" do
      # A cláusula `when is_pid(pid)` na função `generate/1` garante que
      # qualquer coisa que não seja um PID causará um `FunctionClauseError`.
      assert_raise FunctionClauseError, fn ->
        Cuid.Cuid.generate("não-é-um-pid")
      end

      assert_raise FunctionClauseError, fn ->
        Cuid.Cuid.generate(nil)
      end
    end
  end
end
