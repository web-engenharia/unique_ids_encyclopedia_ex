# Código gerado pela I.A Especializada da Web-Engenharia, usando técnica de aprendizado aprimorada.
![I.A](./we_artificial_inteligence.ex)

> _"Se for preciso te quebrar para te refazer, assim Eu farei."_
> **Jeremias 18:1-4**

# UniqueIdsEncyclopediaEx

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `unique_ids_encyclopedia_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unique_ids_encyclopedia_ex, "~> 0.1.0"}
  ]
end
````

Documentation can be generated with ExDoc and published on HexDocs.
Once published, the docs can be found at [https://hexdocs.pm/unique\_ids\_encyclopedia\_ex](https://hexdocs.pm/unique_ids_encyclopedia_ex).

---

## 📘 Documentação e Comparação de Identificadores Únicos

Este documento detalha vários esquemas de geração de identificadores únicos (IDs), projetados para diferentes casos de uso em sistemas de software. A escolha do ID correto pode impactar o desempenho, a escalabilidade e a integridade dos dados de uma aplicação.

### 🎲 UUID (Universally Unique Identifier)

UUID é um padrão de 128 bits (16 bytes) para a criação de IDs. Existem várias versões:

#### UUID v1: Baseado em Tempo

* Timestamp de 60 bits, clock sequence e MAC address.
* ⚠️ Exposição de endereço MAC e fragmentação de índices.

#### UUID v3 e v5: Baseados em Nome (Hashing)

* v3 usa MD5, v5 usa SHA-1.
* Determinísticos, idempotentes.

#### UUID v4: Aleatório

* Simples e seguro, mas não ordenável por tempo.

#### UUID v6: Reordenado e Baseado em Tempo

* Corrige o v1 para ordenação temporal.

#### UUID v7: Baseado em Tempo (Unix Epoch)

* Recomendado para novos projetos, ótima ordenação e desempenho.

#### UUID v8: Customizado

* 122 bits para uso livre. Ideal para casos muito específicos.

---

### 📜 ULID (Universally Unique Lexicographically Sortable Identifier)

* 128 bits (48 de timestamp + 80 aleatórios).
* Representado em Base32, ordenável por tempo.
* ⚡ Eficiente, curto e URL-safe.

---

### ❄️ Snowflake ID

* Criado pelo Twitter.
* 64 bits: timestamp + ID do nó + sequência.
* ⚠️ Requer sincronização e distribuição de nós.

---

### 🔑 KSUID (K-Sortable Unique Identifier)

* 160 bits (32 timestamp + 128 aleatório).
* Ordenável e com baixa chance de colisão.
* Representado em Base62 (27 caracteres).

---

### 🔒 CUID / CUID2

* **CUID**: Descontinuado devido a falhas de segurança.
* **CUID2**: Seguro, SHA-3, string iniciando por letra, otimizado contra predição.
* ✅ Ótima escolha para web moderna e escalável.

---

### ✨ NanoID

* Foco em simplicidade, tamanho pequeno e segurança.
* Altamente customizável (alfabeto e tamanho).
* ⚠️ Não ordenável por tempo.

---

### ⛓️ CID (Content Identifier)

* Utilizado em IPFS.
* ID gerado a partir do **hash do conteúdo**.
* Multiformats: multibase + multicodec + multihash.
* Ideal para conteúdo imutável.

---

## 📊 Tabela Comparativa

| Característica                 | UUID v4     | UUID v7         | ULID     | Snowflake   | KSUID         | CUID2 | NanoID   | CID           |
| ------------------------------ | ----------- | --------------- | -------- | ----------- | ------------- | ----- | -------- | ------------- |
| Ordenável por Tempo            | ❌           | ✅               | ✅        | ✅           | ✅             | ❌     | ❌        | ❌             |
| Criptograficamente Seguro      | ❌           | ✅               | ✅        | ❌           | ✅             | ✅     | ✅        | ✅             |
| Comprimento (padrão)           | 36          | 36              | 26       | 64 bits     | 27            | \~24  | 21       | variável      |
| Seguro contra colisão          | ✅           | ✅               | ✅        | ✅           | ✅             | ✅     | ✅        | ✅             |
| URL-safe                       | ✅           | ✅               | ✅        | ✅           | ✅             | ✅     | ✅        | ✅             |
| Customizável                   | ❌           | ❌               | Parcial  | ❌           | ❌             | ✅     | ✅        | ✅             |
| Indicado para chaves primárias | ❌           | ✅               | ✅        | ✅           | ✅             | ✅     | ✅        | ❌             |
| Exposição de informações       | ⚠️ MAC      | ❌               | ❌        | ⚠️ Nó       | ❌             | ❌     | ❌        | ❌             |
| Aplicação principal            | Generalista | Bancos de Dados | Web/Logs | Distribuído | Bancos e logs | Web   | Frontend | IPFS/Conteúdo |

---

> Desenvolvido com 💡 pela Web-Engenharia

