defmodule Nano.Nano do
  @moduledoc """
  Uma implementação em Elixir do Nano ID, um gerador de strings de ID minúsculo, seguro, amigável para URLs e único.
  """

  alias Nano.Alphabethic
  import Bitwise
  # O alfabeto e o tamanho padrão, conforme a especificação do Nano ID.
  @default_alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
  @default_size 21

  @doc """
  Gera um Nano ID usando o alfabeto padrão (`A-Za-z0-9_-`) e o tamanho padrão (21 caracteres).

  ## Exemplos
      iex> id = Nano.Nano.generate()
      iex> String.length(id) == 21
      true
      iex> String.match?(id, ~r/^[a-zA-Z0-9_-]{21}$/)
      true
  """
  def generate() do
    generate(@default_size, @default_alphabet)
  end

  @doc """
  Gera um Nano ID com um `tamanho` personalizado e o alfabeto padrão.

  ## Exemplos
      iex> id = Nano.Nano.generate(10)
      iex> String.length(id) == 10
      true
  """
  def generate(size) when is_integer(size) do
    generate(size, @default_alphabet)
  end

  @doc """
  Gera um Nano ID com um `tamanho` e um `alfabeto` personalizados.

  O `tamanho` deve ser um inteiro positivo.
  O `alfabeto` deve ser uma string contendo de 1 a 256 caracteres únicos.
  """
  def generate(size, alphabet) when is_integer(size) and is_binary(alphabet) do
    # Validações de entrada
    if size <= 0 do
      raise ArgumentError, "O tamanho do ID deve ser um inteiro positivo."
    end

    alphabet_len = String.length(alphabet)

    if alphabet_len < 1 or alphabet_len > 256 do
      raise ArgumentError, "O comprimento do alfabeto deve ser entre 1 e 256 caracteres."
    end

    unless Alphabethic.unique_chars?(alphabet) do
      raise ArgumentError, "O alfabeto deve conter caracteres únicos."
    end

    # Usa uma tupla para busca eficiente de caracteres em O(1)
    alphabet_tuple = String.to_charlist(alphabet) |> List.to_tuple()

    # Calcula a máscara de bits necessária para cobrir o alfabeto
    bits_needed =
      if alphabet_len == 1, do: 0, else: :math.ceil(:math.log2(alphabet_len)) |> round()

    mask = (1 <<< bits_needed) - 1

    # Calcula o tamanho do lote ("step") para buscar bytes aleatórios
    # O multiplicador (por exemplo, 1.6) é um valor empírico do Nano ID original
    # para compensar os bytes que são descartados durante a amostragem de rejeição.
    step_multiplier = 1.6
    step_float = step_multiplier * mask * size / alphabet_len
    # Garante um tamanho de passo mínimo razoável para eficiência
    step_size = :math.ceil(step_float) |> round() |> max(size) |> max(32)

    # Usa uma função auxiliar recursiva para construir o ID
    reversed_char_list =
      generate_loop(size, alphabet_tuple, alphabet_len, mask, step_size, [])

    # Inverte a lista e a converte para uma string no final
    reversed_char_list |> Enum.reverse() |> List.to_string()
  end

  # Função auxiliar recursiva de cauda para gerar o ID
  defp generate_loop(target_size, alphabet_tuple, alphabet_len, mask, step_size, collected_chars) do
    current_length = length(collected_chars)

    if current_length >= target_size do
      # Caso base: Já coletamos caracteres suficientes
      Enum.take(collected_chars, target_size)
    else
      # Passo recursivo: Gera mais caracteres
      random_bytes = :crypto.strong_rand_bytes(step_size)

      # Itera sobre os bytes aleatórios, reduzindo-os à nossa lista de caracteres coletados
      newly_collected_chars =
        for <<byte <- random_bytes>>, reduce: collected_chars do
          acc ->
            # Para de processar se já tivermos caracteres suficientes
            if length(acc) < target_size do
              index = byte &&& mask

              # Este é o núcleo do algoritmo: amostragem de rejeição.
              # Só usamos o byte se o seu valor mascarado estiver dentro do intervalo de índice válido para o alfabeto.
              # Isso garante uma distribuição uniforme e evita viés.
              if index < alphabet_len do
                # Adiciona o caractere no início da lista para eficiência
                [elem(alphabet_tuple, index) | acc]
              else
                # Descarta o byte e continua
                acc
              end
            else
              # O tamanho alvo foi alcançado, para de processar bytes
              acc
            end
        end

      # Recorre com a nova lista de caracteres coletados
      generate_loop(
        target_size,
        alphabet_tuple,
        alphabet_len,
        mask,
        step_size,
        newly_collected_chars
      )
    end
  end
end
