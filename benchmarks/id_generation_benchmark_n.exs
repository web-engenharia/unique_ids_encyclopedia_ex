# benchmarks/id_generation_benchmark.exs

# --- ALIASES ---
alias Cid.Cid
# Certifique-se que seu wrapper Cuid.Cuid chama a lib CUID correta internamente
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

# --- NÚMERO DE EXECUÇÕES POR JOB DE BENCHMARK ---
numero_de_execucoes_por_job = 1000

# --- DEFINIÇÃO DOS JOBS DE BENCHMARK ---
jobs = %{
  "Cid.generate_v0 (string)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Cid.generate_v0(sample_data_string)
  end,
  "Cid.generate_v0 (binary)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Cid.generate_v0(sample_data_binary)
  end,
  "Cid.generate_v1 (sha256, dag-pb, string)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Cid.generate_v1(sample_data_string)
  end,
  "Cid.generate_v1 (sha256, dag-pb, binary)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Cid.generate_v1(sample_data_binary)
  end,
  "Cid.generate_v1 (sha256, raw, binary)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Cid.generate_v1(sample_data_binary, "raw")
  end,
  "Cid.generate_v1 (blake3, dag-pb, binary)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job,
        do: Cid.generate_v1(sample_data_binary, "dag-pb", :blake3)
  end,
  "Ksuid.Ksuid.generate_string" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Ksuid.generate_string()
  end,
  "Nano.Nano.generate (default)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Nano.generate()
  end,
  "Nano.Nano.generate (size 10)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Nano.generate(10)
  end,
  "Nano.Nano.generate (size 30)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: Nano.generate(30)
  end,
  "Nano.Nano.generate (size 10, custom alphabet)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job,
        do: Nano.generate(10, "abcdefghijklmnopqrstuvwxyz1234567890")
  end,
  "Ulid.Ulid.generate" => fn -> for _ <- 1..numero_de_execucoes_por_job, do: Ulid.generate() end,
  "Uuid.UuidV8.generate" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV8.generate()
  end,
  "Uuid.UuidV6.generate" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV6.generate()
  end,
  "Uuid.UuidV5.generate (dns, web-engenharia.dev)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV5.generate()
  end,
  "Uuid.UuidV4.generate" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV4.generate()
  end,
  "Uuid.UuidV3.generate (dns, web-engenharia.dev)" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV3.generate()
  end,
  "Uuid.UuidV2.generate" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV2.generate()
  end,
  "Uuid.UuidV1.generate" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV1.generate()
  end,
  "Uuid.UuidV0_RFC4122_V1.generate" => fn ->
    for _ <- 1..numero_de_execucoes_por_job, do: UuidV0_RFC4122_V1.generate()
  end,

  # --- Jobs com Hooks usando a sintaxe de TUPLA {fun, [hook_opts]} ---

  "Cuid.Cuidv2.generate (default length)" => {
    fn _ -> for _ <- 1..numero_de_execucoes_por_job, do: Cuidv2.generate() end,
    [
      before_scenario: fn _ ->
        case Cuidv2.Counter.start_link([]) do
          {:ok, _} -> :ok
          {:error, {:already_started, _}} -> :ok
          {:error, r} -> raise "Cuidv2.Counter error: #{inspect(r)}"
        end

        case Cuidv2.Fingerprint.start_link([]) do
          {:ok, _} -> :ok
          {:error, {:already_started, _}} -> :ok
          {:error, r} -> raise "Cuidv2.Fingerprint error: #{inspect(r)}"
        end

        :ok
      end,
      after_scenario: fn _ ->
        if Process.whereis(Cuidv2.Counter), do: Agent.stop(Cuidv2.Counter, :shutdown, :infinity)

        if Process.whereis(Cuidv2.Fingerprint),
          do: Agent.stop(Cuidv2.Fingerprint, :shutdown, :infinity)

        :ok
      end
    ]
  },
  "Cuid.Cuidv2.generate (length 10)" => {
    fn _ -> for _ <- 1..numero_de_execucoes_por_job, do: Cuidv2.generate(10) end,
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
        if Process.whereis(Cuidv2.Counter), do: Agent.stop(Cuidv2.Counter, :shutdown, :infinity)

        if Process.whereis(Cuidv2.Fingerprint),
          do: Agent.stop(Cuidv2.Fingerprint, :shutdown, :infinity)

        :ok
      end
    ]
  },
  "Cuid.Cuidv2.generate (length 32)" => {
    fn _ -> for _ <- 1..numero_de_execucoes_por_job, do: Cuidv2.generate(32) end,
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
        if Process.whereis(Cuidv2.Counter), do: Agent.stop(Cuidv2.Counter, :shutdown, :infinity)

        if Process.whereis(Cuidv2.Fingerprint),
          do: Agent.stop(Cuidv2.Fingerprint, :shutdown, :infinity)

        :ok
      end
    ]
  },
  "CuidOriginal.generate (external PID)" => {
    fn pid -> for _ <- 1..numero_de_execucoes_por_job, do: CuidOriginal.generate(pid) end,
    [
      before_scenario: fn _ ->
        # Lembre-se de corrigir seu wrapper Cuid.Cuid se necessário
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
    fn pid -> for _ <- 1..numero_de_execucoes_por_job, do: Snowflake.next_id(pid) end,
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
    fn _ -> for _ <- 1..numero_de_execucoes_por_job, do: UuidV7.generate() end,
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
        if Process.whereis(UuidV7), do: Agent.stop(UuidV7, :shutdown, :infinity)
        :ok
      end
    ]
  }
}

# --- CONFIGURAÇÃO E EXECUÇÃO DO BENCHEE ---
IO.puts(
  "Iniciando benchmarks de geração de ID (cada job executa #{numero_de_execucoes_por_job} vezes internamente)..."
)

Benchee.run(
  jobs,
  # Benchee executará cada "bloco de N execuções" por este tempo
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
