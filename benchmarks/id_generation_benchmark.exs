# benchmarks/id_generation_benchmark.exs

# --- ALIASES ---
alias Cid.Cid
alias Cuid.Cuid, as: CuidOriginal
alias Cuid.Cuidv2
alias Ksuid.Ksuid
alias Nano.Nano
alias Snowflake.Snowflake
alias Ulid.Ulid
alias Uuid.UuidV8
alias Uuid.UuidV7
alias Uuid.UuidV6
alias Uuid.UuidV5
alias Uuid.UuidV4
alias Uuid.UuidV3
alias Uuid.UuidV2
alias Uuid.UuidV1
alias Uuid.UuidV0, as: UuidV0_RFC4122_V1

# --- DADOS DE ENTRADA ---
sample_data_binary = :crypto.strong_rand_bytes(64)
sample_data_string = "Olá, mundo do benchmark de IDs!"

# --- DEFINIÇÃO DOS JOBS DE BENCHMARK ---
jobs = %{
  "Cid.generate_v0 (string)" => fn -> Cid.generate_v0(sample_data_string) end,
  "Cid.generate_v0 (binary)" => fn -> Cid.generate_v0(sample_data_binary) end,
  "Cid.generate_v1 (sha256, dag-pb, string)" => fn -> Cid.generate_v1(sample_data_string) end,
  "Cid.generate_v1 (sha256, dag-pb, binary)" => fn -> Cid.generate_v1(sample_data_binary) end,
  "Cid.generate_v1 (sha256, raw, binary)" => fn -> Cid.generate_v1(sample_data_binary, "raw") end,
  "Cid.generate_v1 (blake3, dag-pb, binary)" => fn ->
    Cid.generate_v1(sample_data_binary, "dag-pb", :blake3)
  end,
  "Ksuid.Ksuid.generate_string" => fn -> Ksuid.generate_string() end,
  "Nano.Nano.generate (default)" => fn -> Nano.generate() end,
  "Nano.Nano.generate (size 10)" => fn -> Nano.generate(10) end,
  "Nano.Nano.generate (size 30)" => fn -> Nano.generate(30) end,
  "Nano.Nano.generate (size 10, custom alphabet)" => fn ->
    Nano.generate(10, "abcdefghijklmnopqrstuvwxyz1234567890")
  end,
  "Ulid.Ulid.generate" => fn -> Ulid.generate() end,
  "Uuid.UuidV8.generate" => fn -> UuidV8.generate() end,
  "Uuid.UuidV6.generate" => fn -> UuidV6.generate() end,
  "Uuid.UuidV5.generate (dns, web-engenharia.dev)" => fn -> UuidV5.generate() end,
  "Uuid.UuidV4.generate" => fn -> UuidV4.generate() end,
  "Uuid.UuidV3.generate (dns, web-engenharia.dev)" => fn -> UuidV3.generate() end,
  "Uuid.UuidV2.generate" => fn -> UuidV2.generate() end,
  "Uuid.UuidV1.generate" => fn -> UuidV1.generate() end,
  "Uuid.UuidV0_RFC4122_V1.generate" => fn -> UuidV0_RFC4122_V1.generate() end,

  # --- Jobs com Hooks usando a sintaxe de TUPLA {fun, [hook_opts]} ---

  "Cuid.Cuidv2.generate (default length)" => {
    # Função de benchmark
    fn _ -> Cuidv2.generate() end,
    # Keyword list para hooks
    [
      before_scenario: fn _ ->
        case Cuidv2.Counter.start_link([]) do
          {:ok, _} ->
            :ok

          {:error, {:already_started, _}} ->
            IO.puts("Cuid.Cuidv2.Counter já iniciado.")
            :ok

          {:error, r} ->
            raise "Cuid.Cuidv2.Counter start error: #{inspect(r)}"
        end

        case Cuidv2.Fingerprint.start_link([]) do
          {:ok, _} ->
            :ok

          {:error, {:already_started, _}} ->
            IO.puts("Cuid.Cuidv2.Fingerprint já iniciado.")
            :ok

          {:error, r} ->
            raise "Cuid.Cuidv2.Fingerprint start error: #{inspect(r)}"
        end

        # Retorno do before_scenario
        :ok
      end,
      after_scenario: fn _ ->
        if Process.whereis(Cuidv2.Counter),
          do: Agent.stop(Cuidv2.Counter, :shutdown, :infinity)

        if Process.whereis(Cuidv2.Fingerprint),
          do: Agent.stop(Cuidv2.Fingerprint, :shutdown, :infinity)

        :ok
      end
    ]
  },
  "Cuid.Cuidv2.generate (length 10)" => {
    fn _ -> Cuidv2.generate(10) end,
    # Reutiliza a mesma lógica de hooks, mas definida inline para clareza ou pode-se usar variáveis
    [
      before_scenario: fn _ ->
        case Cuidv2.Counter.start_link([]) do
          {:ok, _} -> :ok
          {:error, {:already_started, _}} -> :ok
          {:error, r} -> raise "#{inspect(r)}"
        end

        case Cuidv2.Fingerprint.start_link([]) do
          {:ok, _} -> :ok
          {:error, {:already_started, _}} -> :ok
          {:error, r} -> raise "#{inspect(r)}"
        end

        :ok
      end,
      after_scenario: fn _ ->
        if Process.whereis(Cuidv2.Counter),
          do: Agent.stop(Cuidv2.Counter, :shutdown, :infinity)

        if Process.whereis(Cuidv2.Fingerprint),
          do: Agent.stop(Cuidv2.Fingerprint, :shutdown, :infinity)

        :ok
      end
    ]
  },
  "Cuid.Cuidv2.generate (length 32)" => {
    fn _ -> Cuid.Cuidv2.generate(32) end,
    [
      before_scenario: fn _ ->
        case Cuid.Cuidv2.Counter.start_link([]) do
          {:ok, _} -> :ok
          {:error, {:already_started, _}} -> :ok
          {:error, r} -> raise "#{inspect(r)}"
        end

        case Cuid.Cuidv2.Fingerprint.start_link([]) do
          {:ok, _} -> :ok
          {:error, {:already_started, _}} -> :ok
          {:error, r} -> raise "#{inspect(r)}"
        end

        :ok
      end,
      after_scenario: fn _ ->
        if Process.whereis(Cuidv2.Counter),
          do: Agent.stop(Cuidv2.Counter, :shutdown, :infinity)

        if Process.whereis(Cuidv2.Fingerprint),
          do: Agent.stop(Cuidv2.Fingerprint, :shutdown, :infinity)

        :ok
      end
    ]
  },
  "CuidOriginal.generate (external PID)" => {
    fn pid -> CuidOriginal.generate(pid) end,
    [
      before_scenario: fn _ ->
        case CuidOriginal.start_link() do
          {:ok, p} ->
            p

          {:error, {:already_started, p}} ->
            IO.puts("CuidOriginal já iniciado: #{inspect(p)}")
            p

          {:error, r} ->
            raise "CuidOriginal start error: #{inspect(r)}"
        end
      end,
      after_scenario: fn pid ->
        if Process.alive?(pid), do: Process.exit(pid, :shutdown)
        :ok
      end
    ]
  },
  "Snowflake.Snowflake.next_id" => {
    fn pid -> Snowflake.next_id(pid) end,
    [
      before_scenario: fn _ ->
        worker_id = 1
        name = :"my_snowflake_bench_#{System.unique_integer([:positive])}"
        opts = [worker_id: worker_id, name: name]

        case Snowflake.start_link(opts) do
          {:ok, p} ->
            p

          {:error, {:already_started, p}} ->
            IO.puts("Snowflake (#{name}) já iniciado: #{inspect(p)}")
            p

          {:error, r} ->
            raise "Snowflake (#{name}) start error: #{inspect(r)}"
        end
      end,
      after_scenario: fn pid ->
        if Process.alive?(pid), do: GenServer.stop(pid, :normal, :infinity)
        :ok
      end
    ]
  },
  "Uuid.UuidV7.generate (Agent)" => {
    fn _ -> UuidV7.generate() end,
    [
      before_scenario: fn _ ->
        case UuidV7.start_link([]) do
          {:ok, _} ->
            :ok

          {:error, {:already_started, _}} ->
            IO.puts("Uuid.UuidV7 já iniciado.")
            :ok

          {:error, r} ->
            raise "Uuid.UuidV7 start error: #{inspect(r)}"
        end
      end,
      after_scenario: fn _ ->
        if Process.whereis(Uuid.UuidV7), do: Agent.stop(Uuid.UuidV7, :shutdown, :infinity)
        :ok
      end
    ]
  }
}

# --- CONFIGURAÇÃO E EXECUÇÃO DO BENCHEE ---
IO.puts("Iniciando benchmarks de geração de ID...")

Benchee.run(
  jobs,
  # Para mais "amostras" (execuções), aumente este valor (ex: 10, 20)
  time: 5,
  warmup: 2,
  memory_time: 1,
  formatters: [
    {Benchee.Formatters.Console,
     [
       extended_statistics: true,
       comparison: true
     ]}
  ],
  print: %{
    benchmarking: true,
    configuration: true,
    fast_warning: true
  }
)
