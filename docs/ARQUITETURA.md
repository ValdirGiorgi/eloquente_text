# Arquitetura

O código é dividido em camadas com uma regra simples de dependência: cada
camada só conhece as que estão **abaixo** dela.

```
ui/      telas e widgets (Fluent UI)
  ↓
ai/      provedores de IA e prompts        data/   banco, repositórios e criptografia
  ↓                                          ↓
models/  tipos puros, sem Flutter e sem banco
```

`app/` (inicialização e tema) e `core/` (janela, bandeja, atalho global,
captura de texto) ficam de fora desse fluxo: são a cola com o sistema
operacional e só são usados por `main.dart` e pela tela principal.

## Diretórios

| Pasta | O que vive aqui |
|---|---|
| `lib/app/` | `bootstrap()` (ordem de inicialização), tema e identidade do app |
| `lib/core/` | Integrações com o SO: janela, bandeja, atalho global, captura da seleção |
| `lib/models/` | Tipos puros: `Tone`, `Purpose`, `AiResponse`, `HistoryEntry`, `ModelConfig`, `UsageSummary` |
| `lib/ai/` | Prompts e um provedor por API (`providers/`), com o catálogo em `provider_catalog.dart` |
| `lib/data/` | SQLite (`app_database.dart`, `migrations.dart`), repositórios e criptografia das API keys |
| `lib/ui/` | Uma pasta por tela (`home`, `history`, `settings`, `stats`) e widgets compartilhados em `common/` |
| `test/` | Testes espelhando a estrutura de `lib/` |

## Decisões que valem conhecer antes de mexer

**Modelos puros, sem Flutter.** Nada em `lib/models/` importa
`package:flutter`. É o que permite testar tom, finalidade, métricas e
histórico sem subir nenhuma tela.

**Rótulo é chave.** `AiProviderKind.label`, `Tone.label` e `Purpose.label`
são ao mesmo tempo o texto mostrado na interface e o valor gravado no
banco. Renomear um rótulo quebra os dados de quem já usa o app — se
precisar renomear, escreva uma migração.

**Prompts em um lugar só.** Ficam em `lib/ai/prompts/`, nunca dentro de um
provedor: o prompt é idêntico para todos, só o formato HTTP muda.

**Cada provedor é uma classe.** OpenAI e DeepSeek herdam de
`OpenAiCompatibleProvider` (mesmo dialeto de API); Anthropic e Gemini
implementam `AiProvider` diretamente. O construtor aceita um `http.Client`
opcional, que é como os testes injetam um `MockClient`.

**A tela principal não tem lógica.** `HomeController` (um `ChangeNotifier`)
guarda o estado e fala com os repositórios; `HomePage` só monta widgets e
reage. O controller nunca recebe `BuildContext` — métodos que podem falhar
devolvem a mensagem de erro, e a tela decide como mostrá-la.

**Duas tabelas para os processamentos.** `history` guarda os textos e pode
ser limpa pelo usuário; `stats_log` guarda só números e sobrevive a essa
limpeza. Por isso todo processamento é gravado nas duas.

## Adicionando um provedor de IA

1. Crie a classe em `lib/ai/providers/`, implementando `AiProvider` (ou
   estendendo `OpenAiCompatibleProvider`, se a API seguir o formato da
   OpenAI).
2. Acrescente um valor em `AiProviderKind`
   (`lib/ai/provider_catalog.dart`), com o rótulo, a URL onde o usuário
   obtém a API key e o `create()` correspondente.
3. Escolha a cor do provedor em `lib/ui/common/provider_colors.dart`.
4. Escreva um teste em `test/ai/providers_test.dart` com um `MockClient`.

As telas leem `AiProviderKind.values`, então nenhuma delas precisa mudar.

## Mudando o banco de dados

1. Incremente `schemaVersion` em `lib/data/migrations.dart`.
2. Ajuste `createSchema` (instalações novas).
3. Acrescente um bloco `if (oldVersion < N)` em `upgradeSchema`, ao final —
   nunca edite um bloco já publicado: instalações antigas passam por todos
   eles em ordem.
4. Cubra a mudança em `test/data/repositories_test.dart`, que roda sobre um
   banco em memória (`AppDatabase.inMemory()`).
