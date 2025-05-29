defmodule Uuid.UuidV1 do
  alias UUID

  def generate() do
    UUID.uuid1()
  end
end
