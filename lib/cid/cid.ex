defmodule Cid.Cid do
  @moduledoc """
  Módulo para gerar Content Identifiers (CIDs) em Elixir.
  Suporta CIDv0 (legado) e CIDv1 (recomendado).
  """

  alias CID
  alias Multihash
  # Opcional, para BLAKE3
  alias B3

  @doc """
  Gera um CIDv1 a partir de um dado.

  Por padrão, usa SHA256 para hashing e o codec 'dag-pb'.
  Recomendado para novos projetos.

  ## Parâmetros
  - `data`: O dado (binário ou string) a ser identificado.
  - `codec`: O codec Multicodec a ser usado (e.g., "dag-pb", "dag-cbor", "raw").
             Padrão: "dag-pb".
  - `hash_algo`: O algoritmo de hash a ser usado (e.g., :sha2_256, :blake3).
                 Padrão: :sha2_256.

  ## Exemplos
      iex> Cid.Cid.generate_v1("Olá, mundo!")
      {:ok, "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3hz2nrxle2yzzl5ruc2fwgpmb"}

      iex> Cid.Cid.generate_v1("Dados CBOR", "dag-cbor", :sha2_256)
      {:ok, "bafyreih36b44h5x7zxdz5y7p2vj4q4m4w4k4l4m4n4o4p4q4r4s4t4u4v4w4x4y4z4a5"} # Exemplo, o hash real mudaria

      iex> Cid.Cid.generate_v1("Dados RAW", "raw", :blake3)
      {:ok, "bafyegqj32xge4h62gfs4geu4gg3w2p4v4b4x4y4z4a5b5c5d5e5f5g5h5i5j5k5l5m5n5o5p5q5r5s5t5u5v5w5x5y5z4a5b6"} # Exemplo, o hash real mudaria
  """
  @spec generate_v1(binary(), binary(), atom()) :: {:ok, String.t()} | {:error, any()}
  def generate_v1(data, codec \\ "dag-pb", hash_algo \\ :sha2_256) do
    with {:ok, digest} <- hash_data(data, hash_algo),
         {:ok, multihash} <- Multihash.encode(hash_algo, digest),
         {:ok, cid_struct} <- CID.cid(multihash, codec, 1),
         {:ok, cid_string} <- CID.encode(cid_struct) do
      {:ok, cid_string}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Gera um CIDv0 a partir de um dado.

  O CIDv0 usa SHA256, codec 'dag-pb' e codificação base58btc implicitamente.
  É uma versão legada e não é recomendada para novos desenvolvimentos.
  Apenas dados com hash SHA256 e codec 'dag-pb' podem ser representados como CIDv0.

  ## Parâmetros
  - `data`: O dado (binário ou string) a ser identificado.

  ## Exemplos
      iex> Cid.Cid.generate_v0("Olá, mundo!")
      {:ok, "QmYwAPJzvCEJdPNwF9R5nKj3B1hFwW1y63zJ4f5J4K4L4"} # Exemplo, o hash real mudaria
  """
  @spec generate_v0(binary()) :: {:ok, String.t()} | {:error, any()}
  def generate_v0(data) do
    with {:ok, digest} <- hash_data(data, :sha2_256),
         # Para CIDv0, o multihash deve ter exatamente 32 bytes (para sha2_256)
         {:ok, multihash} <- Multihash.encode(:sha2_256, digest, 32),
         {:ok, cid_struct} <- CID.cid(multihash, "dag-pb", 0),
         {:ok, cid_string} <- CID.encode(cid_struct) do
      {:ok, cid_string}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Decodifica uma string CID de volta para a estrutura CID.

  ## Parâmetros
  - `cid_string`: A string CID a ser decodificada.

  ## Exemplos
      iex> {:ok, cid_struct} = Cid.Cid.decode("bafybeigdyrzt5sfp7udm7hu76uh7y26nf3hz2nrxle2yzzl5ruc2fwgpmb")
      iex> cid_struct.version
      1
      iex> cid_struct.codec
      "dag-pb"
  """
  @spec decode(String.t()) :: {:ok, CID.t()} | {:error, any()}
  def decode(cid_string) do
    with {:ok, cid_struct} <- CID.decode_cid(cid_string) do
      {:ok, cid_struct}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Função auxiliar para realizar o hashing do dado
  defp hash_data(data, :sha2_256), do: {:ok, :crypto.hash(:sha256, data)}
  defp hash_data(data, :blake3), do: {:ok, B3.hash(data)}
  defp hash_data(_data, algorithm), do: {:error, "Unsupported hash algorithm: #{algorithm}"}
end
