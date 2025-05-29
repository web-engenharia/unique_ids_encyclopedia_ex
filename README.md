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
