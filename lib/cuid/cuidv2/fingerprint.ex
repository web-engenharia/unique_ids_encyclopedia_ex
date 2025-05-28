defmodule Cuid.Cuidv2.Fingerprint do
  @moduledoc """
  Agente para gerar e armazenar em cache um "fingerprint" para a aplicação.
  """
  use Agent
  # 256 bits de entropia para sal e fingerprint
  @random_block_size 32

  def start_link(_opts) do
    fingerprint = :crypto.strong_rand_bytes(@random_block_size)
    Agent.start_link(fn -> fingerprint end, name: __MODULE__)
  end

  def get, do: Agent.get(__MODULE__, & &1)
end
