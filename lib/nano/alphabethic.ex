defmodule Nano.Alphabethic do
  @moduledoc false

  @doc """
  Checks if all characters (graphemes) in the given alphabet string are unique.
  """
  def unique_chars?(alphabet_string) when is_binary(alphabet_string) do
    grapheme_list = String.graphemes(alphabet_string)

    if length(grapheme_list) <= 1 do
      true
    else
      unique_grapheme_count = MapSet.new(grapheme_list) |> MapSet.size()
      length(grapheme_list) == unique_grapheme_count
    end
  end
end
