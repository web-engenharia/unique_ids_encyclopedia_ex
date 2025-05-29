defmodule Uuid.UuidV3 do
  alias UUID

  def generate() do
    UUID.uuid3(:dns, "web-engenharia.dev")
  end
end
