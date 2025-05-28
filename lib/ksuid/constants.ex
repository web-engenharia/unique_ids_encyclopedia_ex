defmodule Ksuid.Constants do
  @moduledoc """
  Define as constantes utilizadas na geração e análise de KSUIDs.
  """

  @doc "Retorna a época KSUID em segundos Unix (2014-05-13T19:46:40Z)."
  def ksuid_epoch_seconds, do: 1_400_000_000

  @doc "Retorna o comprimento total da representação binária do KSUID em bytes (20)."
  def binary_length, do: 20

  @doc "Retorna o tamanho em bits do componente de timestamp (32)."
  def timestamp_bits, do: 32

  @doc "Retorna o comprimento do componente de payload em bytes (16)."
  def payload_length, do: 16

  @doc "Retorna o tamanho total em bits do binário KSUID (160)."
  def total_bits, do: 160

  @doc "Retorna o comprimento necessário da representação de string codificada em Base62 (27)."
  def string_length, do: 27

  @doc "Retorna o alfabeto Base62 (ordem lexicográfica: 0-9, A-Z, a-z)."
  def base62_alphabet, do: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  @doc "Retorna o caractere de preenchimento para a string Base62 ('0')."
  def base62_padding_char, do: "0"
end
