defmodule Cuid.Cuid do
  @moduledoc """
  Um wrapper para a geração de CUIDs.

  ⚠️ AVISO IMPORTANTE:
  O algoritmo CUID original (implementado por esta biblioteca 'cuid') está obsoleto
  devido a preocupações de segurança. A versão recomendada é o CUID2.
  Considere fortemente migrar para uma biblioteca que implemente CUID2 (como `cuid2_ex`)
  em seus projetos de produção para maior segurança.
  """

  # O Cuid original utiliza um processo OTP para manter o estado (pid, hostname, etc.)
  # Para um uso mais simples, podemos iniciar e parar o processo internamente
  # ou gerenciá-lo com um Supervisor.

  @doc """
  Gera um novo CUID.

  Este método inicia um processo Cuid temporário para gerar o ID.
  Para aplicações de alta performance ou onde muitos IDs são gerados
  continuamente, é mais eficiente gerenciar o processo Cuid com um Supervisor
  e passar o PID para a função `generate/1`.
  """
  @spec generate() :: String.t()
  def generate() do
    case Cuid.start_link() do
      {:ok, pid} ->
        cuid = Cuid.generate(pid)
        # Encerra o processo Cuid
        Process.exit(pid, :normal)
        cuid

      {:error, reason} ->
        # Em caso de erro ao iniciar o processo Cuid
        IO.warn("Falha ao iniciar o processo Cuid: #{inspect(reason)}")
        # Você pode optar por retornar nil, uma tupla de erro ou levantar uma exceção
        raise "Não foi possível gerar CUID: #{inspect(reason)}"
    end
  end

  @doc """
  Gera um novo CUID utilizando um PID de um processo Cuid já em execução.

  Isso é mais performático para geração contínua de IDs.
  O PID deve ser obtido de `Cuid.start_link/0` ou gerenciado por um Supervisor.
  """
  @spec generate(pid :: pid()) :: String.t()
  def generate(pid) when is_pid(pid) do
    Cuid.generate(pid)
  end
end
