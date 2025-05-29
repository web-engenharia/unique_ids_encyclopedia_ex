defmodule Snowflake.Snowflake do
  use GenServer
  import Bitwise
  require Logger
  @worker_id_bits 10
  @sequence_bits 12
  @max_worker_id (1 <<< @worker_id_bits) - 1
  @max_sequence (1 <<< @sequence_bits) - 1
  @worker_id_shift @sequence_bits
  @timestamp_shift @sequence_bits + @worker_id_bits

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name))
  def next_id(pid), do: GenServer.call(pid, :generate_id)

  @impl true
  def init(opts) do
    system_module = Application.get_env(:unique_ids_encyclopedia_ex, :system_module, System)
    process_module = Application.get_env(:unique_ids_encyclopedia_ex, :process_module, Process)
    default_epoch = Application.get_env(:unique_ids_encyclopedia_ex, :epoch_ms, 1_420_070_400_000)

    Logger.info("Snowflake GenServer iniciando com system_module: #{inspect(system_module)}")
    Logger.info("Snowflake GenServer iniciando com process_module: #{inspect(process_module)}")
    Logger.info("Snowflake GenServer iniciando com default_epoch: #{inspect(default_epoch)}")
    worker_id = Keyword.fetch!(opts, :worker_id)
    epoch_ms = Keyword.get(opts, :epoch_ms, default_epoch)

    if worker_id < 0 || worker_id > @max_worker_id do
      {:stop, {:invalid_worker_id, worker_id}}
    else
      {:ok,
       %{
         last_timestamp: -1,
         sequence: 0,
         worker_id: worker_id,
         custom_epoch: epoch_ms,
         system_module: system_module,
         process_module: process_module
       }}
    end
  end

  @impl true
  def handle_call(:generate_id, _from, state) do
    system_module = state.system_module
    current_msec = system_module.system_time(:millisecond)

    if current_msec < state.last_timestamp do
      {:reply, {:error, :clock_moved_backward}, state}
    else
      {new_msec, new_sequence} =
        if current_msec == state.last_timestamp,
          do: {current_msec, state.sequence + 1},
          else: {current_msec, 0}

      handle_sequence_overflow(new_msec, new_sequence, state)
    end
  end

  defp handle_sequence_overflow(msec, sequence, state) do
    if sequence > @max_sequence,
      do: wait_for_next_millisecond(msec, state),
      else: build_id(msec, sequence, state)
  end

  defp wait_for_next_millisecond(current_msec, state) do
    system_module = state.system_module
    process_module = state.process_module
    next_msec = current_msec + 1
    time_to_wait = next_msec - system_module.system_time(:millisecond)
    if time_to_wait > 0, do: process_module.sleep(time_to_wait)
    build_id(next_msec, 0, state)
  end

  defp build_id(msec, sequence, state) do
    timestamp_delta = msec - state.custom_epoch

    if timestamp_delta < 0 do
      {:reply, {:error, :timestamp_out_of_range}, state}
    else
      id =
        timestamp_delta <<< @timestamp_shift |||
          state.worker_id <<< @worker_id_shift |||
          sequence

      {:reply, {:ok, id}, %{state | last_timestamp: msec, sequence: sequence}}
    end
  end
end
