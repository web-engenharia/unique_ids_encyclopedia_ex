defmodule Uuid.UuidV7 do
  @moduledoc """
  Gera UUIDs v7 que são ordenáveis e baseados em tempo, conforme a RFC 9562.

  Esta implementação utiliza um Agent para garantir a monotonicidade, mesmo
  quando os UUIDs são gerados em alta frequência ou se o relógio do sistema
  sofre um ajuste para trás.

  ## Uso

  Primeiro, inicie o agente (geralmente no seu `application.ex`):

      # application.ex
      children = [
        Uuid.UuidV7,
        ...
      ]

  Depois, gere os UUIDs:

      Uuid.UuidV7.generate()
      #=> "018ff011-965c-7561-89e4-0c1a16a1b248"

  """

  use Agent

  # 4 bits para a versão (0b0111)
  @vsn 7
  # 2 bits para a variante (0b10)
  @var 2
  # 2^12 - 1
  @max_seq 4095

  # Nome do agente para registro global
  @name __MODULE__

  ### API Pública ###

  @doc """
  Inicia o agente que gerencia o estado do gerador de UUID.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> {0, 0} end, name: @name)
  end

  @doc """
  Gera um novo UUID v7 como uma string hexadecimal.
  """
  @spec generate() :: String.t()
  def generate do
    # 1. Pega o timestamp e o contador de sequência do agente de estado
    {timestamp, sequence} = get_monotonic_parts()

    # 2. Gera 62 bits aleatórios para a parte final do UUID
    <<rand_b::62, _::2>> = :crypto.strong_rand_bytes(8)

    # 3. Monta o UUID de 128 bits usando a sintaxe de bitstring
    uuid_binary =
      <<timestamp::48, @vsn::4, sequence::12, @var::2, rand_b::62>>

    # 4. Formata o binário para uma string hexadecimal
    format_to_string(uuid_binary)
  end

  ### Lógica Interna e Gerenciamento de Estado ###

  @doc false
  defp get_monotonic_parts do
    current_milli = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    Agent.get_and_update(@name, &get_and_update_state(&1, current_milli))
  end

  # Função de atualização do agente. Garante a monotonicidade.
  defp get_and_update_state({last_ts, last_seq}, current_ts) do
    {ts, seq} =
      cond do
        # Caso 1: O tempo avançou. Novo milissegundo, reseta o contador.
        current_ts > last_ts ->
          {current_ts, 0}

        # Caso 2: Mesmo milissegundo. Incrementa o contador.
        current_ts == last_ts ->
          increment_sequence(current_ts, last_seq)

        # Caso 3: Relógio andou para trás! Usa o último timestamp conhecido e incrementa.
        current_ts < last_ts ->
          increment_sequence(last_ts, last_seq)
      end

    # O valor de retorno para o chamador é {ts, seq}.
    # O novo estado do agente será {ts, seq}.
    {{ts, seq}, {ts, seq}}
  end

  # Incrementa o contador de sequência e lida com o overflow.
  defp increment_sequence(timestamp, sequence) do
    if sequence < @max_seq do
      {timestamp, sequence + 1}
    else
      # Overflow! Incrementa o timestamp artificialmente e reseta o contador.
      {timestamp + 1, 0}
    end
  end

  # Formata o binário de 128 bits para o formato padrão de UUID.
  defp format_to_string(<<
         t1::32,
         t2::16,
         v_s1::16,
         v_s2_r::64
       >>) do
    # Converte cada parte para hexadecimal e junta com hífens
    t1_hex = Base.encode16(<<t1::32>>, case: :lower)
    t2_hex = Base.encode16(<<t2::16>>, case: :lower)
    v_s1_hex = Base.encode16(<<v_s1::16>>, case: :lower)
    v_s2_r_hex = Base.encode16(<<v_s2_r::64>>, case: :lower)

    # CORREÇÃO APLICADA AQUI: [p1, p2] foi alterado para {p1, p2}
    {p1, p2} = String.split_at(v_s2_r_hex, 4)

    "#{t1_hex}-#{t2_hex}-#{v_s1_hex}-#{p1}-#{p2}"
  end
end
