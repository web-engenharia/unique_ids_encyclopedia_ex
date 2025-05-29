defmodule Uuid.UuidV4 do
  alias UUID

  def generate() do
    UUID.uuid4()
  end
end
