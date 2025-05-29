# test/uuid/uuid_v7_test.exs
defmodule Uuid.UuidV7Test do
  use ExUnit.Case, async: false

  @agent_name Uuid.UuidV7
  @max_seq 4095

  setup do
    start_supervised!(@agent_name)
    :ok
  end

  describe "generate/0" do
    test "gera um UUID com formato, versão e variante corretos" do
      uuid_string = Uuid.UuidV7.generate()

      assert uuid_string =~
               ~r/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

      # CORREÇÃO: O padrão de bits para extrair a versão e a variante foi ajustado.
      # A versão (version) fica logo após o timestamp de 48 bits.
      <<_::48, version::4, _::12, variant::2, _::62>> = parse_uuid(uuid_string)
      assert version == 7
      assert variant == 2
    end

    test "gera um UUID com um timestamp preciso" do
      ts_before = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
      uuid_string = Uuid.UuidV7.generate()
      ts_after = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

      <<uuid_ts::48, _::80>> = parse_uuid(uuid_string)

      assert uuid_ts >= ts_before and uuid_ts <= ts_after
    end

    test "gera UUIDs estritamente monotônicos em rápida sucessão" do
      uuids = for _ <- 1..100, do: Uuid.UuidV7.generate()

      assert uuids == Enum.sort(uuids)

      <<ts1::48, _::4, seq1::12, _::64>> = parse_uuid(Enum.at(uuids, 0))
      <<ts2::48, _::4, seq2::12, _::64>> = parse_uuid(Enum.at(uuids, 1))

      assert ts1 == ts2
      assert seq2 == seq1 + 1
    end

    test "lida com o estouro do contador incrementando o timestamp" do
      # CORREÇÃO: A lógica do teste foi ajustada para corresponder ao comportamento da implementação.
      # O estado é definido para um valor que permitirá testar o estouro de forma clara.
      ts_inicial = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
      # Começa com seq = 4094
      Agent.update(@agent_name, fn _ -> {ts_inicial, @max_seq - 1} end)

      # A primeira chamada incrementa a sequência para 4095.
      # usa seq = 4095
      uuid1 = Uuid.UuidV7.generate()

      # A segunda chamada tenta incrementar, estoura o contador, incrementa o timestamp e reseta a sequência.
      # usa seq = 0, ts = ts_inicial + 1
      uuid2 = Uuid.UuidV7.generate()

      <<ts1::48, _::4, seq1::12, _::64>> = parse_uuid(uuid1)
      <<ts2::48, _::4, seq2::12, _::64>> = parse_uuid(uuid2)

      # Verifica se o primeiro UUID usou o timestamp inicial e a sequência máxima.
      assert ts1 == ts_inicial
      # O valor usado é 4095
      assert seq1 == @max_seq

      # Verifica se o segundo UUID incrementou o timestamp e resetou a sequência.
      assert ts2 == ts_inicial + 1
      assert seq2 == 0
    end

    test "lida com o ajuste do relógio para trás usando o último timestamp conhecido" do
      ts_futuro = DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> Kernel.+(1000)
      Agent.update(@agent_name, fn _ -> {ts_futuro, 42} end)

      uuid_string = Uuid.UuidV7.generate()
      <<uuid_ts::48, _::4, uuid_seq::12, _::64>> = parse_uuid(uuid_string)

      assert uuid_ts == ts_futuro
      assert uuid_seq == 43
    end
  end

  ### Funções de Apoio ###
  defp parse_uuid(uuid_string) do
    uuid_string
    |> String.replace("-", "")
    |> Base.decode16!(case: :lower)
  end
end
