ExUnit.start()

defmodule Snowflake.SnowflakeTest.SystemMockBehaviour do
  @moduledoc false
  @callback system_time(unit :: :millisecond) :: integer()
end

defmodule Snowflake.SnowflakeTest.ProcessMockBehaviour do
  @moduledoc false
  @callback sleep(timeout :: non_neg_integer() | :infinity) :: :ok
end

Mox.defmock(SystemMock, for: Snowflake.SnowflakeTest.SystemMockBehaviour)
Mox.defmock(ProcessMock, for: Snowflake.SnowflakeTest.ProcessMockBehaviour)
