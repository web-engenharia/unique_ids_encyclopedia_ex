defmodule Ksuid.Ksuid do
  @moduledoc """
  Implementa a geração e análise de K-Sortable Unique IDentifiers (KSUIDs).
  """
  alias Ksuid.Constants

  # Defina os valores como atributos de módulo para uso em pattern matching e guards.
  # A chamada de função acontece em tempo de compilação.
  @binary_length Constants.binary_length()
  @string_length Constants.string_length()
  @timestamp_bits Constants.timestamp_bits()
  @payload_length Constants.payload_length()
  @total_bits Constants.total_bits()

  @typedoc "Uma string KSUID de 27 caracteres codificada em Base62."
  @type ksuid_string :: String.t()

  @typedoc "Uma representação binária de 20 bytes de um KSUID."
  @type ksuid_binary :: binary()

  @typedoc "O valor do timestamp KSUID (segundos desde a época KSUID)."
  @type ksuid_timestamp_value :: non_neg_integer()

  @typedoc "O payload aleatório de 16 bytes de um KSUID."
  @type payload_binary :: binary()

  @typedoc "A representação inteira de 160 bits de um binário KSUID."
  @type ksuid_integer :: non_neg_integer()

  @doc """
  Gera um novo KSUID e retorna sua representação de string Base62 de 27 caracteres.
  """
  @spec generate_string() :: ksuid_string()
  def generate_string do
    timestamp_val = generate_timestamp_value()
    payload_bin = generate_payload_binary()
    ksuid_binary = build_ksuid_binary(timestamp_val, payload_bin)
    binary_to_padded_base62_string(ksuid_binary)
  end

  @doc """
  Analisa uma string KSUID de 27 caracteres em seus componentes: DateTime (UTC) e payload binário.
  Retorna `{:ok, {DateTime.t(), payload_binary()}}` ou `{:error, atom()}`.
  """
  @spec parse_string(ksuid_string()) :: {:ok, {DateTime.t(), payload_binary()}} | {:error, atom()}
  def parse_string(<<_::binary-size(@string_length)>> = str) do
    with :ok <- validate_base62_characters(str),
         {:ok, ksuid_int} <- base62_string_to_ksuid_integer(str),
         ksuid_binary = ksuid_integer_to_binary(ksuid_int),
         {:ok, timestamp_val, payload_bin} <- decompose_ksuid_binary(ksuid_binary),
         {:ok, datetime} <- ksuid_timestamp_value_to_datetime(timestamp_val) do
      {:ok, {datetime, payload_bin}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_string(_), do: {:error, :invalid_ksuid_string_format_or_length}

  @doc """
  Converte um binário KSUID de 20 bytes em sua string Base62 de 27 caracteres.
  Retorna `{:ok, ksuid_string()}` ou `{:error, atom()}`.
  """
  @spec from_binary(ksuid_binary()) :: {:ok, ksuid_string()} | {:error, atom()}
  def from_binary(<<_::binary-size(@binary_length)>> = bin) do
    {:ok, binary_to_padded_base62_string(bin)}
  end

  def from_binary(_), do: {:error, :invalid_ksuid_binary_format_or_length}

  @doc """
  Converte uma string KSUID de 27 caracteres em sua representação binária de 20 bytes.
  Retorna `{:ok, ksuid_binary()}` ou `{:error, atom()}`.
  """
  @spec to_binary(ksuid_string()) :: {:ok, ksuid_binary()} | {:error, atom()}
  def to_binary(<<_::binary-size(@string_length)>> = str) do
    with :ok <- validate_base62_characters(str),
         {:ok, ksuid_int} <- base62_string_to_ksuid_integer(str) do
      {:ok, ksuid_integer_to_binary(ksuid_int)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def to_binary(_), do: {:error, :invalid_ksuid_string_format_or_length}

  # --- Funções Auxiliares Internas ---

  defp generate_timestamp_value() do
    current_unix_seconds = System.os_time(:second)
    ksuid_epoch = Constants.ksuid_epoch_seconds()
    max(0, current_unix_seconds - ksuid_epoch)
  end

  defp generate_payload_binary() do
    :crypto.strong_rand_bytes(@payload_length)
  end

  defp build_ksuid_binary(timestamp_val, payload_bin) do
    <<timestamp_val::unsigned-big-integer-size(@timestamp_bits),
      payload_bin::binary-size(@payload_length)>>
  end

  defp decompose_ksuid_binary(
         <<ts_val::unsigned-big-integer-size(@timestamp_bits),
           p_bin::binary-size(@payload_length)>>
       ) do
    {:ok, ts_val, p_bin}
  end

  defp ksuid_timestamp_value_to_datetime(ksuid_ts_val) do
    unix_seconds = ksuid_ts_val + Constants.ksuid_epoch_seconds()

    case DateTime.from_unix(unix_seconds, :second) do
      {:ok, datetime} -> {:ok, DateTime.shift_zone!(datetime, "Etc/UTC")}
      {:error, _reason} -> {:error, :datetime_conversion_error}
    end
  end

  defp ksuid_binary_to_integer(<<int_val::unsigned-big-integer-size(@total_bits)>>),
    do: int_val

  defp ksuid_integer_to_binary(int_val)
       when is_integer(int_val) and int_val >= 0 do
    <<int_val::unsigned-big-integer-size(@total_bits)>>
  end

  defp binary_to_padded_base62_string(ksuid_bin) do
    large_int = ksuid_binary_to_integer(ksuid_bin)
    # Assumindo a API da biblioteca `igas/base62`: `Base62.encode(integer)`
    raw_base62_string = Base62.encode(large_int)
    String.pad_leading(raw_base62_string, @string_length, Constants.base62_padding_char())
  end

  defp base62_string_to_ksuid_integer(str) do
    # Assumindo a API da biblioteca `igas/base62`: `Base62.decode(string)`
    case Base62.decode(str) do
      {:ok, integer_val} when is_integer(integer_val) and integer_val >= 0 ->
        {:ok, integer_val}

      {:ok, _} ->
        {:error, :base62_decoding_invalid_integer_type}

      :error ->
        {:error, :base62_decoding_failed}
    end
  end

  defp validate_base62_characters(str) do
    if Regex.match?(~r/^[0-9A-Za-z]+$/, str) do
      :ok
    else
      {:error, :invalid_character_in_ksuid_string}
    end
  end
end
