defmodule Cid.CidTest do
  use ExUnit.Case, async: true

  # Alias for the module we are testing
  alias Cid.Cid

  # --- generate_v1/1 Tests ---
  test "generate_v1/1 generates a standard CIDv1 for 'Olá, mundo!'" do
    data = "Olá, mundo!"
    {:ok, cid_string} = Cid.generate_v1(data)

    # This is the correct, verifiable CID for the input string
    assert cid_string == "zdj7WfVYHrU3kUC28Wrn8GRY3zMg3eFGAQyhWEfY8jYWcakgQ"
    {:ok, %{version: 1, codec: "dag-pb"}} = Cid.decode(cid_string)
  end

  test "generate_v1/3 with 'raw' codec" do
    data = "Dados RAW"
    {:ok, cid_string} = Cid.generate_v1(data, "raw", :sha2_256)

    # Correct CID for "Dados RAW" with raw codec
    assert cid_string == "zb2rhgNVBmW4vYVnYHfmmENnzamHmrw2d8cqBMWHy2x5vJPER"
    {:ok, %{version: 1, codec: "raw"}} = Cid.decode(cid_string)
  end

  test "generate_v1/3 returns an error for an unsupported hash algorithm" do
    data = "Algoritmo ruim"
    # The multihash library used by :cid does not support :sha1 by that name
    assert Cid.generate_v1(data, "raw", :sha1) == {:error, "Unsupported hash algorithm: sha1"}
  end

  # --- generate_v0/1 Tests ---
  test "generate_v0/1 generates a standard CIDv0 for 'Hello IPFS!'" do
    data = "Hello IPFS!"
    {:ok, cid_string} = Cid.generate_v0(data)

    # Correct, verifiable CIDv0 for "Hello IPFS!"
    assert cid_string == "QmUsNLPuhg4pA5NZZFf1x8cxrU2gQzBRYdDvmq2VQcBthJ"
    {:ok, %{version: 0, codec: "dag-pb"}} = Cid.decode(cid_string)
  end

  # --- decode/1 Tests ---
  test "decode/1 handles a valid CIDv1 string" do
    cid_string = "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3hz2nrxle2yzzl5ruc2fwgpmb"
    {:ok, cid_struct} = Cid.decode(cid_string)

    assert cid_struct.version == 1
    assert cid_struct.codec == "dag-pb"
  end

  test "decode/1 handles a valid CIDv0 string" do
    cid_string = "QmXnnyufdzAWL5CqZ2RnSNgPbvCc1ALT73s6epPrRnpgsF"
    {:ok, cid_struct} = Cid.decode(cid_string)

    assert cid_struct.version == 0
    assert cid_struct.codec == "dag-pb"
  end

  test "decode/1 returns an error for an invalid CID string" do
    invalid_cid_string = "not_a_valid_cid_string"
    assert Cid.decode(invalid_cid_string) == {:error, "unable to decode CID string"}
  end
end
