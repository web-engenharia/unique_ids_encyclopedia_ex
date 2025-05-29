defmodule Ulid.Ulid do
  @moduledoc """
  Implementação de Universally Unique Lexicographically Sortable Identifiers (ULIDs).

  Esta implementação segue a especificação ULID para gerar identificadores de 128 bits
  compostos por um timestamp de 48 bits e 80 bits de aleatoriedade. O resultado é
  codificado como uma string de 26 caracteres usando a Base32 de Crockford.
  """

  @crockford_alphabet "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

  @doc """
  Gera um novo ULID.

  O ULID é baseado no tempo Unix atual em milissegundos e em 10 bytes de
  dados criptograficamente seguros.

  ## Exemplos

      iex> String.length(Ulid.Ulid.generate())
      26
  """
  def generate do
    timestamp = current_timestamp()
    random_bytes = generate_random_bytes()
    encode(timestamp, random_bytes)
  end

  @doc """
  Gera um novo ULID para um timestamp específico.

  Esta função é útil para migração de dados ou testes, permitindo a criação
  de um ULID em um ponto específico no tempo.

  ## Exemplos

      iex> ulid = Ulid.Ulid.generate_at(1_469_918_176_385)
      iex> String.length(ulid)
      26
  """
  def generate_at(timestamp) when is_integer(timestamp) do
    random_bytes = generate_random_bytes()
    encode(timestamp, random_bytes)
  end

  ### Funções Privadas ###

  @spec current_timestamp() :: integer()
  defp current_timestamp do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end

  @spec generate_random_bytes() :: binary()
  defp generate_random_bytes do
    :crypto.strong_rand_bytes(10)
  end

  @spec encode(integer(), binary()) :: String.t()
  defp encode(timestamp, random_bytes) do
    <<timestamp::integer-size(48), random_bytes::binary-size(10)>>
    |> do_encode()
  end

  defp do_encode(bits) do
    # Adiciona 2 bits zero ao final para fazer um total de 130 bits (26 * 5)
    padded_bits = <<bits::bitstring, 0::size(2)>>

    # Itera sobre o binário de 130 bits, que agora é perfeitamente divisível por 5
    for <<value::integer-size(5) <- padded_bits>>, into: "" do
      String.at(@crockford_alphabet, value)
    end
  end
end
