defmodule Uuid.UuidV5 do
  alias UUID

  def generate() do
    UUID.uuid5(:dns, "web-engenharia.dev")
  end
end
