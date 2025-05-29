defmodule Snowflake.SnowflakeTest do
  use ExUnit.Case, async: false
  import Mox
  import Bitwise

  @worker_id 31
  @epoch 1_420_070_400_000

  setup do
    # Importante para o Mox
    Mox.set_mox_global(self())
    Mox.verify_on_exit!(self())
    :ok
  end

  # ... (testes de "geração de ID" permanecem os mesmos) ...

  describe "geração de ID" do
    test "gera IDs únicos e crescentes em chamadas consecutivas" do
      expect(SystemMock, :system_time, fn :millisecond -> @epoch + 100 end)
      {:ok, pid} = start_snowflake_supervised()
      {:ok, id1} = Snowflake.Snowflake.next_id(pid)

      expect(SystemMock, :system_time, fn :millisecond -> @epoch + 101 end)
      {:ok, id2} = Snowflake.Snowflake.next_id(pid)

      assert id2 > id1
      assert worker_id_from_id(id1) == @worker_id
    end

    test "incrementa a sequência para chamadas no mesmo milissegundo" do
      expect(SystemMock, :system_time, 3, fn :millisecond -> @epoch + 200 end)
      {:ok, pid} = start_snowflake_supervised()

      {:ok, id1} = Snowflake.Snowflake.next_id(pid)
      {:ok, id2} = Snowflake.Snowflake.next_id(pid)
      {:ok, id3} = Snowflake.Snowflake.next_id(pid)

      assert id2 - id1 == 1
      assert id3 - id2 == 1
    end

    test "reseta a sequência quando o milissegundo muda" do
      expect(SystemMock, :system_time, fn :millisecond -> @epoch + 300 end)
      {:ok, pid} = start_snowflake_supervised()
      # Chamada 1
      {:ok, _id1} = Snowflake.Snowflake.next_id(pid)

      expect(SystemMock, :system_time, fn :millisecond -> @epoch + 300 end)
      # Chamada 2
      {:ok, id2} = Snowflake.Snowflake.next_id(pid)

      expect(SystemMock, :system_time, fn :millisecond -> @epoch + 301 end)
      # Chamada 3
      {:ok, id3} = Snowflake.Snowflake.next_id(pid)

      assert sequence_from_id(id2) == 1
      assert sequence_from_id(id3) == 0
    end
  end

  describe "casos de borda e erros" do
    test "retorna erro quando o relógio retrocede" do
      expect(SystemMock, :system_time, fn :millisecond -> @epoch + 400 end)
      {:ok, pid} = start_snowflake_supervised()
      {:ok, _id} = Snowflake.Snowflake.next_id(pid)

      expect(SystemMock, :system_time, fn :millisecond -> @epoch + 399 end)
      assert Snowflake.Snowflake.next_id(pid) == {:error, :clock_moved_backward}
    end

    test "lida com o estouro da sequência avançando o timestamp" do
      current_time = @epoch + 500
      expect(SystemMock, :system_time, 4096, fn :millisecond -> current_time end)
      {:ok, pid} = start_snowflake_supervised()

      for sequence_val <- 0..4095 do
        {:ok, id} = Snowflake.Snowflake.next_id(pid)
        assert sequence_from_id(id) == sequence_val
        assert timestamp_from_id(id) == current_time - @epoch
      end

      # Na chamada de estouro (a 4097ª), o GenServer vai:
      # 1. Chamar system_time para pegar o tempo atual (que ainda é `current_time`).
      # 2. Perceber o estouro e dormir.
      # 3. Chamar system_time novamente para calcular `time_to_wait`.
      # Chamada 1 (para determinar next_msec)
      expect(SystemMock, :system_time, fn :millisecond -> current_time end)

      expect(ProcessMock, :sleep, fn duration ->
        # ou assert duration == 1, se for preciso
        assert duration >= 0
        :ok
      end)

      # CORREÇÃO: Esta chamada deve retornar o tempo *antes* do incremento para
      # que `time_to_wait` seja positivo.
      # Chamada 2 (para calcular time_to_wait)
      expect(SystemMock, :system_time, fn :millisecond -> current_time end)

      {:ok, overflow_id} = Snowflake.Snowflake.next_id(pid)

      assert sequence_from_id(overflow_id) == 0
      assert timestamp_from_id(overflow_id) == current_time - @epoch + 1
    end

    @tag :capture_log
    test "retorna erro se o ID de worker for inválido ao iniciar" do
      assert_raise :exit, {:invalid_worker_id, 1024}, fn ->
        Snowflake.Snowflake.start_link(worker_id: 1024)
      end
    end

    test "retorna erro quando o timestamp está fora do intervalo (negativo)" do
      expect(SystemMock, :system_time, fn :millisecond -> @epoch - 100 end)
      {:ok, pid} = start_snowflake_supervised()
      assert Snowflake.Snowflake.next_id(pid) == {:error, :timestamp_out_of_range}
    end
  end

  # ... (start_snowflake_supervised e funções de deconstrução permanecem os mesmos) ...
  defp start_snowflake_supervised(opts \\ []) do
    default_opts = [worker_id: @worker_id]
    final_opts = Keyword.merge(default_opts, opts)

    {:ok, sup_pid} =
      Supervisor.start_link([{Snowflake.Snowflake, final_opts}], strategy: :one_for_one)

    [worker_pid] = Supervisor.which_children(sup_pid) |> Enum.map(&elem(&1, 1))
    {:ok, worker_pid}
  end

  @worker_id_bits 10
  @sequence_bits 12
  @worker_id_shift @sequence_bits
  @timestamp_shift @sequence_bits + @worker_id_bits

  defp timestamp_from_id(id), do: Bitwise.bsr(id, @timestamp_shift)

  defp worker_id_from_id(id),
    do: Bitwise.band(Bitwise.bsr(id, @worker_id_shift), (1 <<< @worker_id_bits) - 1)

  defp sequence_from_id(id), do: Bitwise.band(id, (1 <<< @sequence_bits) - 1)
end
