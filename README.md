# Eloquente Text

[![CI](https://github.com/valdirgiorgi/eloquente_text/actions/workflows/ci.yml/badge.svg)](https://github.com/valdirgiorgi/eloquente_text/actions/workflows/ci.yml)
[![Licença: MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.4%2B-02569B?logo=flutter)](https://flutter.dev)

Aplicativo de desktop (Windows e Linux) que fica na bandeja do sistema e
melhora qualquer texto selecionado com um atalho de teclado, usando a IA
que você preferir. Selecione um texto em qualquer aplicativo, aperte
`Ctrl+Shift+F`, escolha o tom e a finalidade, e receba a versão revisada —
tudo em português brasileiro.

> 📖 A história por trás do projeto, com os detalhes de implementação:
> [Eloquente Text: humanize e reescreva textos com IA](https://blog.valdir.dev.br/eloquente-text)

## Funcionalidades

- **Atalho global (`Ctrl+Shift+F`)** — captura o texto selecionado em
  qualquer aplicativo (navegador, editor, WhatsApp Web etc.) e abre a
  janela do app já com o texto carregado.
- **Tom e finalidade configuráveis** — 10 tons (Formal, Informal, Técnico,
  Persuasivo...) e 13 finalidades (E-mail Profissional, WhatsApp,
  Relatório, Mensagem SMS, Prompt de IA...) combináveis livremente.
- **Modo Humanizar** — reescreve o texto evitando as marcas mais comuns de
  texto gerado por IA (clichês, travessões em excesso, listas forçadas
  etc.). Veja a seção [Modo Humanizar](#modo-humanizar) para detalhes.
- **Múltiplos provedores de IA** — OpenAI, DeepSeek, Anthropic Claude e
  Google Gemini, cada um com sua própria API key e lista de modelos
  cadastrados.
- **Histórico local** — cada processamento fica salvo (texto original,
  texto melhorado, tom, finalidade e provedor usado), com busca e
  exportação.
- **Estatísticas de uso** — total de requisições, tokens consumidos, tempo
  médio de resposta e distribuição por provedor.
- **Bandeja do sistema** — o app roda minimizado e some da barra de
  tarefas; fechar a janela não encerra o processo.

## Como funciona

1. Você seleciona um texto em qualquer aplicativo e pressiona
   `Ctrl+Shift+F`.
2. O app simula um `Ctrl+C`, lê a área de transferência e abre a janela
   principal já com o texto capturado.
3. Você escolhe o tom, a finalidade e, opcionalmente, ativa o Humanizar.
4. Ao clicar em "Melhorar Texto", o app envia o texto para o provedor de
   IA configurado e mostra o resultado.
5. O processamento é salvo automaticamente no histórico.

## Provedores de IA suportados

Você usa sua própria API key — o app não cobra nada nem intermedia
requisições, apenas chama a API do provedor escolhido diretamente do seu
computador. Os custos de uso da API são cobrados pelo próprio provedor.

| Provedor | Onde obter a API key |
|---|---|
| OpenAI | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| DeepSeek | [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys) |
| Anthropic Claude | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) |
| Google Gemini | [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) |

Na tela de Configurações você informa a API key, digita livremente o nome
do modelo desejado (ex.: `gpt-4o`, `claude-sonnet-5`, `gemini-1.5-pro`) e
pode opcionalmente fixar uma temperatura por modelo.

## Segurança e privacidade

- **Nada sai do seu computador, exceto a chamada para a API de IA que você
  escolheu.** Não há telemetria, analytics ou servidor próprio do app.
- **As API keys são criptografadas com AES-256** antes de serem gravadas
  no banco local (veja [`encryption_service.dart`](lib/data/encryption_service.dart)).
  A chave de criptografia é gerada uma vez por instalação e fica em
  `security.key`, ao lado do banco de dados — isso protege contra alguém
  copiar só o arquivo do banco, mas não substitui um cofre de segredos do
  sistema operacional.
- **Histórico e configurações ficam só localmente**, em SQLite, na pasta
  de documentos do usuário (`Documentos/EloquenteText/data/` — o caminho
  exato varia por sistema operacional). Você pode apagar tudo a qualquer
  momento pela própria interface.

## Modo Humanizar

O toggle **Humanizar**, na tela principal, adiciona ao prompt de sistema
as 35 categorias de marcas de texto gerado por IA catalogadas pelo projeto
[humanizer](https://github.com/blader/humanizer) (MIT) — que por sua vez
compila os ["Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
da WikiProject AI Cleanup da Wikipédia. A implementação
([`lib/ai/prompts/humanizer_instructions.dart`](lib/ai/prompts/humanizer_instructions.dart))
segue as
mesmas 35 categorias do catálogo original (alegações infladas, linguagem
de venda, fontes vagas, palavras batidas de IA, travessões e negrito em
excesso, sobras de chatbot, qualificadores em excesso, frases de efeito
forçadas etc.), incluindo as seções de falsos positivos ("o que não
sinalizar") e de detalhes que devem ser preservados para o texto continuar
soando humano. Em todos os casos, fatos, nomes, números e datas do texto
original nunca são alterados ou inventados.

O bloco de instruções é escrito em inglês (custa menos tokens e o modelo
segue as regras de forma mais confiável), mas as "palavras a evitar" de
cada padrão são dadas em português — é o que o modelo precisa reconhecer
no texto de saída — e a instrução final exige explicitamente que a
reescrita seja em português brasileiro.

### Prompts em inglês, custo otimizado

Todo o prompt — o de sistema (`buildSystemPrompt`) e o de usuário
(`buildUserPrompt`), em [`lib/ai/prompts/`](lib/ai/prompts) —, não só o do
Humanizar, segue essa mesma lógica: instruções em inglês, exigência de
resposta em português brasileiro reforçada duas vezes (como regra e como
aviso final), e os
valores de tom/finalidade — esses sim em português, pois são o vocabulário
fixo mostrado na interface.

Para a Anthropic, o prompt de sistema é enviado com
[cache de prompt](https://docs.anthropic.com/claude/docs/prompt-caching)
(`cache_control: ephemeral`), já que ele é idêntico em toda chamada com o
mesmo estado do toggle Humanizar — só o texto do usuário muda a cada
processamento. Isso reduz bastante o custo de quem processa vários textos
seguidos, principalmente com o Humanizar ativado (o bloco de 35 categorias
é grande). OpenAI, DeepSeek e Gemini já fazem esse tipo de cache de prefixo
repetido automaticamente, sem precisar de nada explícito no código.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.4 ou superior
  (canal stable), com suporte a desktop habilitado.
- Windows 10+ ou uma distribuição Linux com suporte a GTK 3 (para a build
  Linux). No Linux, instale também o `xdotool` (`sudo apt install xdotool`):
  é ele que permite ao atalho global copiar o texto selecionado em outro
  aplicativo.
- Uma API key de pelo menos um dos provedores listados acima.

## Rodando o projeto

```bash
flutter pub get
```

Windows:
```bash
flutter run -d windows
```

Linux:
```bash
flutter run -d linux
```

Na primeira execução, abra o menu da bandeja do sistema → **Configurações**
para escolher um provedor, colar sua API key e cadastrar um modelo.

### Gerando um executável

```bash
flutter build windows   # gera build/windows/x64/runner/Release/
flutter build linux     # gera build/linux/x64/release/bundle/
```

O resultado é uma pasta portátil: pode ser copiada para qualquer lugar
(inclusive um pendrive) sem instalador.

### Testes e análise estática

```bash
flutter analyze   # análise estática
flutter test      # testes (não precisam de API key nem de banco no disco)
dart format .     # formatação
```

Os testes cobrem os prompts, a montagem e a leitura das respostas de cada
provedor (com um cliente HTTP falso) e os repositórios (sobre um SQLite em
memória) — nenhuma chamada de rede real e nenhum arquivo seu é tocado.

## Estrutura do projeto

```
lib/
├── main.dart          # ponto de entrada: bootstrap() + runApp()
├── app/               # inicialização, tema e identidade do app
├── core/              # integrações com o SO: janela, bandeja, atalho global
├── models/            # tipos puros (tom, finalidade, resposta, histórico)
├── ai/                # prompts e um provedor por API
│   ├── prompts/       # sistema, usuário e instruções do modo Humanizar
│   └── providers/     # OpenAI, DeepSeek, Anthropic e Gemini
├── data/              # SQLite, migrações, repositórios e criptografia
└── ui/                # uma pasta por tela + widgets compartilhados
    ├── home/          # janela principal (entrada, opções, resultado)
    ├── history/       # histórico de processamentos
    ├── settings/      # provedor, API key e modelos
    ├── stats/         # painel de uso
    └── common/        # widgets usados por mais de uma tela
```

Cada camada só depende das de baixo: `ui/` conhece `ai/` e `data/`, que
conhecem `models/`, que não conhece ninguém. Os detalhes de cada pasta e as
receitas para adicionar um provedor de IA ou mudar o banco estão em
[`docs/ARQUITETURA.md`](docs/ARQUITETURA.md).

## Contribuindo

Contribuições são bem-vindas — o [guia de contribuição](CONTRIBUTING.md)
cobre como preparar o ambiente, o estilo de código adotado e o que o CI
verifica em cada PR (`flutter analyze`, `flutter test` e `dart format`).

Bons pontos de partida: um provedor de IA novo, testes de widget (a
interface ainda não tem), ou empacotamento (`.deb`, `.msi`, Flatpak).

## Licença

Distribuído sob a licença [MIT](LICENSE).
