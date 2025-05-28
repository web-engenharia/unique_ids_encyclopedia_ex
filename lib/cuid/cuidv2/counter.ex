defmodule Cuid.Cuidv2.Counter do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> {0, 0} end, name: __MODULE__)
  end

  @spec get_and_increment(timestamp_ms :: integer) :: integer
  def get_and_increment(timestamp_ms) do
    Agent.get_and_update(__MODULE__, fn {last_ms, count} ->
      # CORREÇÃO: Lógica ajustada para retornar o valor correto e atualizar o estado corretamente.
      if timestamp_ms == last_ms do
        # No mesmo milissegundo: retorna o contador atual e incrementa o próximo estado.
        {count, {last_ms, count + 1}}
      else
        # Em um novo milissegundo: retorna 0 e define o próximo estado para 1.
        {0, {timestamp_ms, 1}}
      end
    end)
  end
end
