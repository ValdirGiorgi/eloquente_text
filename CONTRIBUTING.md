# Contribuindo com o Eloquente Text

Toda contribuição é bem-vinda: correção de bug, provedor de IA novo,
melhoria de texto da interface, tradução, documentação. Este guia cobre o
básico para você começar rápido.

## Preparando o ambiente

```bash
git clone https://github.com/valdirgiorgi/eloquente_text.git
cd eloquente_text
flutter pub get
flutter run -d linux    # ou: flutter run -d windows
```

Você precisa do [Flutter](https://docs.flutter.dev/get-started/install) 3.4
ou superior (canal stable) com suporte a desktop habilitado. No Linux,
instale também o `xdotool` — é ele que permite ao atalho global copiar o
texto selecionado em outro aplicativo:

```bash
sudo apt install xdotool
```

Para usar o app de verdade você precisa de uma API key de algum dos
provedores suportados (veja a tabela no [README](README.md)). Para
**desenvolver e rodar os testes**, não precisa de nenhuma: os testes usam
um cliente HTTP falso e um banco em memória.

## Antes de abrir o PR

```bash
flutter analyze
flutter test
dart format .
```

Os três precisam passar limpos — é exatamente isso que o CI roda.

## Como o código é organizado

Leia [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md). Em resumo: `models/` são
tipos puros, `ai/` fala com as APIs, `data/` fala com o SQLite e `ui/` só
monta telas. Cada camada só depende das de baixo.

Duas receitas prontas estão lá: **adicionar um provedor de IA** e **mudar o
banco de dados**.

## Estilo

- **Arquivos pequenos, com uma responsabilidade.** Se um widget passou de
  ~150 linhas, provavelmente há dois widgets ali dentro.
- **Comentário explica o porquê, não o quê.** Se o código já diz o que
  faz, o comentário sobra; se existe uma armadilha (uma limitação da API,
  um comportamento estranho do sistema operacional), comente.
- **Interface em português, código em inglês.** Nomes de classes, métodos
  e variáveis em inglês; textos mostrados ao usuário em português
  brasileiro. Os comentários e a documentação do projeto são em português.
- **Prompts em inglês.** As instruções enviadas às APIs de IA são escritas
  em inglês de propósito (custam menos tokens e são seguidas de forma mais
  confiável), mesmo exigindo resposta em português.

## Testes

Todo comportamento novo em `models/`, `ai/` ou `data/` deve vir com teste —
são camadas puras e testáveis sem interface:

- `test/ai/` usa `MockClient` (`package:http/testing.dart`) para simular as
  respostas dos provedores; nenhuma chamada real de rede acontece.
- `test/data/` usa `AppDatabase.inMemory()`, que não toca em nenhum arquivo
  do seu computador.

Widgets ainda não têm testes; PRs adicionando `testWidgets` são bem-vindos.

## Abrindo issues

- **Bug:** conte o que aconteceu, o que era esperado, seu sistema
  operacional e a saída de `flutter doctor -v`.
- **Ideia:** descreva o problema que você quer resolver antes da solução —
  ajuda a discutir alternativas.
- **Nunca cole sua API key** em issues, prints ou logs.

## Segurança

Encontrou algo que afeta a segurança dos dados do usuário (as API keys
criptografadas, o banco local)? Abra uma issue descrevendo o impacto sem
incluir dados reais, ou entre em contato em privado com o mantenedor.

## Licença

Ao contribuir, você concorda que sua contribuição será distribuída sob a
licença [MIT](LICENSE) do projeto.
