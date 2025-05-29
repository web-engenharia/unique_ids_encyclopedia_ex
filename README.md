# Unique Id's Encyclopedia Ex

# Benchmark: Geração de IDs

```bash
mix run benchmarks/id_generation_benchmark_n.exs
```

Iniciando benchmarks de geração de ID (cada job executa 1000 vezes internamente)...

## Informações do Sistema

* **Sistema Operacional:** Linux
* **CPU:** AMD Ryzen 5 3500U with Radeon Vega Mobile Gfx
* **Núcleos disponíveis:** 8
* **Memória disponível:** 17.44 GB
* **Elixir:** 1.16.2
* **Erlang:** 27.2
* **JIT habilitado:** true

## Configuração da Suíte de Benchmark

* **warmup:** 2 s
* **tempo:** 5 s
* **tempo de medição de memória:** 1 s
* **tempo de redução:** 0 ns
* **paralelismo:** 1
* **entradas:** não especificadas
* **tempo total estimado de execução:** 3 min 28 s

---

## Benchmarks Executados

* `Cid.generate_v0 (binary)`
* `Cid.generate_v0 (string)`
* `Cid.generate_v1 (blake3, dag-pb, binary)`
* `Cid.generate_v1 (sha256, dag-pb, binary)`
* `Cid.generate_v1 (sha256, dag-pb, string)`
* `Cid.generate_v1 (sha256, raw, binary)`
* `Cuid.Cuidv2.generate (default length)`
* `Cuid.Cuidv2.generate (length 10)`
* `Cuid.Cuidv2.generate (length 32)`
* `CuidOriginal.generate (external PID)`
* `Ksuid.Ksuid.generate_string`
* `Nano.Nano.generate (default)`
* `Nano.Nano.generate (size 10)`
* `Nano.Nano.generate (size 10, custom alphabet)`
* `Nano.Nano.generate (size 30)`
* `Snowflake.Snowflake.next_id`
* `Ulid.Ulid.generate`
* `Uuid.UuidV0_RFC4122_V1.generate`
* `Uuid.UuidV1.generate`
* `Uuid.UuidV2.generate`
* `Uuid.UuidV3.generate (dns, web-engenharia.dev)`
* `Uuid.UuidV4.generate`
* `Uuid.UuidV5.generate (dns, web-engenharia.dev)`
* `Uuid.UuidV6.generate`
* `Uuid.UuidV7.generate (Agent)`
* `Uuid.UuidV8.generate`

---

## Top 5 - Mais Rápidos (em operações por segundo - IPS)

| Nome                                             | IPS     | Tempo Médio |
| ------------------------------------------------ | ------- | ----------- |
| `Uuid.UuidV3.generate (dns, web-engenharia.dev)` | 1434.31 | 0.70 ms     |
| `Uuid.UuidV5.generate (dns, web-engenharia.dev)` | 1200.88 | 0.83 ms     |
| `Uuid.UuidV4.generate`                           | 513.51  | 1.95 ms     |
| `Uuid.UuidV8.generate`                           | 174.52  | 5.73 ms     |
| `Cid.generate_v0 (binary)`                       | 169.69  | 5.89 ms     |

---

## Top 5 - Mais Lentos

| Nome                                       | IPS   | Tempo Médio |
| ------------------------------------------ | ----- | ----------- |
| `Uuid.UuidV2.generate`                     | 0.21  | 4853.31 ms  |
| `Uuid.UuidV0_RFC4122_V1.generate`          | 2.58  | 387.32 ms   |
| `Uuid.UuidV1.generate`                     | 3.27  | 305.65 ms   |
| `Cid.generate_v1 (blake3, dag-pb, binary)` | 12.95 | 77.21 ms    |
| `Ulid.Ulid.generate`                       | 25.92 | 38.58 ms    |

---

## Comparação Relativa com o Mais Rápido

| Nome                                             | Vezes mais lento | Diferença média |
| ------------------------------------------------ | ---------------- | --------------- |
| `Uuid.UuidV5.generate (dns, web-engenharia.dev)` | 1.19x            | +0.136 ms       |
| `Uuid.UuidV4.generate`                           | 2.79x            | +1.25 ms        |
| `Uuid.UuidV8.generate`                           | 8.22x            | +5.03 ms        |
| `Cid.generate_v0 (binary)`                       | 8.45x            | +5.20 ms        |
| ...                                              | ...              | ...             |
| `Uuid.UuidV2.generate`                           | 6961.13x         | +4852.61 ms     |

---

## Logs do Snowflake

```
10:06:15.687 [info] Snowflake GenServer iniciando com system_module: System
10:06:15.691 [info] Snowflake GenServer iniciando com process_module: Process
10:06:15.693 [info] Snowflake GenServer iniciando com default_epoch: 1420070400000
```

---

## Observações

* O benchmark mede **tempo médio**, **variação**, **mediana**, **99th percentil**, e **desempenho em ops/s (IPS)**.
* O ID mais rápido a ser gerado foi o `UuidV3` com DNS personalizado.
* Implementações `NanoID`, `ULID`, `Snowflake`, e `CUID` mostraram maior latência em versões com mais entropia ou personalização.




# Codex Creatus per Intelligentiam Artificialem *Web-Engenharia*
![I.A](./we_artificial_inteligence.ex)
> *Si necesse est te frangere ut te reformem, ita faciam.* — Ieremias 18:1-4

---

# 📘 *UniqueIdsEncyclopediaEx*

> *Documentatio et Comparatio de Identificatoribus Unicis*

Este documento descreve e compara vários esquemas de geração de identificadores únicos utilizados em software moderno. *Electio identitatis aptae magni momenti est pro integritate, celeritate, et scalabilitate systematis.*

---

## ⚙️ *Installatio*

Se disponível no [Hex](https://hex.pm/docs/publish), adicione no seu `mix.exs`:

```elixir
def deps do
  [
    {:unique_ids_encyclopedia_ex, "~> 0.1.0"}
  ]
end
````

Gere a documentação com **ExDoc**. Após publicação, disponível em:

📚 [https://hexdocs.pm/unique\_ids\_encyclopedia\_ex](https://hexdocs.pm/unique_ids_encyclopedia_ex)

---

## 🔎 *Typi Identitatis*

### 🎲 UUID — *Universally Unique Identifier*

UUIDs são identificadores de 128 bits amplamente utilizados. Existem várias versões:

#### UUID v1 — *Tempore Fundatum*

* **Como funciona:** Baseado em timestamp + endereço MAC.
* **Vantagens:** Contém informação temporal.
* **Desvantagens:** Exposição de dados sensíveis (MAC).

#### UUID v3 / v5 — *Ex Nomine et Hashing*

* v3 usa **MD5**, v5 usa **SHA-1**.
* Garante idempotência: o mesmo nome sempre gera o mesmo UUID.

#### UUID v4 — *Ex Aleatorietate*

* **Como funciona:** Dados totalmente aleatórios.
* **Desvantagens:** Não ordenável por tempo.

#### UUID v6 — *Ordinatio Tempore*

* Reordena bits do UUID v1.
* Ideal para bancos de dados ordenados.

#### UUID v7 — *Tempus et Aleatorietas*

> *Optima electio ad usum generalem.*

* Usa milissegundos desde Unix Epoch + aleatoriedade.
* Ótimo para índices de banco de dados.

#### UUID v8 — *Structura Personalizata*

* Desenvolvedor pode definir o conteúdo dos bits.
* Uso específico, controlado.

---

### 📜 ULID — *Identificator Ordinabilis et Universalis*

* Baseado em milissegundos + 80 bits de aleatoriedade.
* Representado com *Crockford Base32*.
* Vantagem: **Ordenável lexicograficamente**.

---

### ❄️ Snowflake ID — *Forma Ordinabilis per Twitter*

* ID de 64 bits.
* Estrutura:

  * 41 bits de tempo
  * 10 bits de ID de máquina
  * 12 bits de sequência
* Desvantagem: requer coordenação entre nós.

---

### 🔑 KSUID — *K-Sortable UID*

* 160 bits: timestamp + payload aleatório.
* Ordenável.
* Representado em Base62.

---

### 🔒 CUID & CUID2 — *Identitas sine Collisiones*

* CUID original foi substituído por **CUID2**.
* *CUID2: Fortior, securior, constantior.*
* Baseado em SHA-3 com entropia combinada.

---

### ✨ NanoID — *Simplicitas et Securitas*

* String curta, segura e amigável para URLs.
* Customizável (alfabeto e tamanho).
* Desvantagem: **non ordinabilis**.

---

### ⛓️ CID — *Identitas Contenti*

> *Non rem, sed materiam ipsam identificat.*

* Baseado no **hash criptográfico** do conteúdo.
* Usado no **IPFS**.
* Autodescritivo: usa *multibase*, *multicodec* e *multihash*.

---

## 📊 *Tabula Comparativa*

| Característica  | UUID v4  | UUID v7 | ULID | Snowflake    | KSUID              | CUID2    | NanoID    | CID      |
| --------------- | -------- | ------- | ---- | ------------ | ------------------ | -------- | --------- | -------- |
| Ordenável       | ❌        | ✅       | ✅    | ✅            | ✅                  | ✅        | ❌         | ✅        |
| Temporal        | ❌        | ✅       | ✅    | ✅            | ✅                  | ✅        | ❌         | ✅        |
| Segurança       | ⚠️       | ✅       | ✅    | ⚠️           | ✅                  | ✅        | ✅         | ✅        |
| Customizável    | ⚠️       | ❌       | ⚠️   | ❌            | ❌                  | ❌        | ✅         | ✅        |
| Tamanho (bits)  | 128      | 128     | 128  | 64           | 160                | \~192    | variável  | variável |
| Uso recomendado | Genérico | DB Keys | Logs | Distribuição | Sistemas ordenados | Web APIs | Front-end | IPFS     |

---

## 🧠 *Conclusio*

> *Scientia identificatorum ducit ad architecturam robustam.*

A escolha correta de um identificador pode **melhorar desempenho**, **evitar colisões** e **otimizar armazenamento**. Para a maioria dos sistemas modernos, UUID v7 ou ULID são as melhores opções. Já para sistemas distribuídos com coordenação entre nós, o **Snowflake** ou **KSUID** podem ser ideais.

---

**Finis.**
*Scriptum per I.A. Web-Engenharia, anno Domini MMXXV.*
