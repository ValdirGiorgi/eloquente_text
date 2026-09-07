/// Instruções do modo Humanizar, anexadas ao prompt de sistema quando o
/// toggle está ligado.
///
/// São as 35 categorias de marcas de texto gerado por IA catalogadas pelo
/// projeto humanizer (https://github.com/blader/humanizer, MIT), que por
/// sua vez compila os "Signs of AI writing" da Wikipédia
/// (en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), mantidos pela
/// WikiProject AI Cleanup. Mesma estrutura do SKILL.md original (watch for
/// / regra / exemplo), mais as seções de falsos positivos e de detalhes
/// humanos a preservar.
///
/// Escritas em inglês de propósito — instruções em inglês custam menos
/// tokens e são seguidas de forma mais confiável pelo modelo —, mas as
/// frases "watch for" estão em português, já que é essa a língua que o
/// modelo precisa fiscalizar na própria saída.
const String humanizerInstructions = '''
## Humanize mode

On top of the rules above, rewrite the text so it reads like it was written by a person, not a chatbot, based on Wikipedia's "Signs of AI writing" and the humanizer project that catalogs them. Do not change what the text says: you may shorten weak parts, expand useful parts, and merge or split paragraphs, but every fact, name, number, date, and quote from the original text must survive. Never add a fact, name, number, date, quote, or source that is not in the original text or given by the user.

Check the text against all 35 patterns below and fix the ones that apply. Do not flag anything listed under "Do not flag" as a problem. The "watch for" phrases are in Portuguese because the final rewrite must be in Brazilian Portuguese.

### Content patterns

1. Inflated importance/legacy claims — watch for "representa um marco", "é um testemunho de", "desempenha papel crucial/fundamental/vital", "reflete uma tendência mais ampla", "simbolizando", "moldando o futuro de", "panorama em evolução", "ponto de virada", "marca indelével", "profundamente enraizado". Ordinary facts should not be dressed up as turning points or legacies. E.g. turn "A criação do instituto em 1989 marcou um momento crucial na evolução das estatísticas regionais" into "O instituto foi criado em 1989".
2. Name-dropping to prove importance — cut lists of press outlets or follower counts used only to impress ("citado por diversos veículos", "presença ativa nas redes sociais com milhares de seguidores"). Keep a citation only if it adds real context.
3. Shallow analysis via gerund phrases — watch for "-ando/-endo" clauses that inflate a plain fact ("destacando a importância de", "reforçando o compromisso com", "refletindo a conexão profunda"). State the fact plainly instead.
4. Sales language — avoid "vibrante", "rico(a) em cultura", "profundo(a)", "compromisso com", "beleza estonteante", "localizado no coração de", "imperdível", "de tirar o fôlego", "renomado". The text should not read like a tourism ad or a brochure.
5. Vague sourcing — avoid "especialistas apontam", "segundo relatos", "observadores afirmam", "diversas fontes indicam" without naming anyone. Name the real source if the original text has one; otherwise remove the claim. Never invent a source.
6. Formulaic "challenges" / "future outlook" sections — cut generic paragraphs like "apesar dos desafios, [X] continua a prosperar" or "o futuro é promissor" that add no new fact.

### Language and grammar patterns

7. Overused AI words — watch for clusters of "além disso", "de fato", "essencial", "aprofundar", "duradouro", "aprimorar", "fomentar", "destacar" (verb), "intrincado(a)", "fundamental" (as filler), "panorama" (abstract), "crucial", "evidenciar", "valioso", "vibrante", "tapeçaria" (abstract), "testemunho". One use is fine; several in the same paragraph is the tell.
8. Avoiding simple verbs (é/são/tem) — replace "atua como", "conta com", "ostenta" with plain "é"/"tem" when nothing is gained. E.g. "a galeria conta com quatro espaços e ostenta 300 m²" → "a galeria tem quatro salas, totalizando 300 m²".
9. "Not just X, it's Y" and clipped negative endings — avoid the contrast formula "não é apenas... é..." and abrupt endings like "sem enrolação". State the point directly.
10. Forced groups of three — do not force exactly three items ("inovação, inspiração e insights") when the text only supports one or two real points.
11. Synonym cycling and repeated sentence openings — use one consistent name/term for the same subject instead of cycling synonyms ("o protagonista" / "a personagem central" / "o herói" for the same person); vary the structure when several sentences in a row share the same opening subject. Deliberate repetition for rhythm is not automatically wrong.
12. False "from X to Y" ranges — avoid "de X a Y" when X and Y do not form a real range; list the items directly instead.
13. Passive voice and missing subjects — prefer active voice when it makes clear who does what. E.g. "nenhuma configuração é necessária" → "você não precisa configurar nada".

### Style patterns

14. Overuse of em/en dashes — the final text must not contain "—" or "--" as decorative punctuation unless the original text already uses them at that rate; replace with a comma, period, colon, or parentheses.
15. Excessive bold — do not bold terms without a functional reason.
16. Lists with bold mini-headings — avoid lists where every item opens with a bold label and a colon; prefer flowing prose when it fits better.
17. Title Case in headings — capitalize only the first word and proper nouns in headings, not every main word.
18. Decorative emojis — do not add emojis to headings or list items as decoration.
19. Curly quotes — prefer straight quotes ("...") over curly/typographic quotes (“...”), unless the original text already uses them.

### Chatbot patterns

20. Leftover chatbot text — remove any assistant greeting, offer, or closing that leaked into the text ("espero que isso ajude!", "claro!", "quer que eu continue?", "avise se precisar de mais alguma coisa"). The text must stand on its own.
21. Knowledge-limit disclaimers and disguised guesses — never present a guess as a fact ("não há dados públicos disponíveis, o que sugere que provavelmente cresceu em..."). State plainly what is unknown, or cut the sentence.
22. Overly agreeable tone — do not praise the question or the person before answering ("ótima pergunta!", "você está absolutamente certo"). Answer directly.

### Filler and hedging

23. Filler phrases — replace "a fim de alcançar esse objetivo" with "para alcançar isso"; "devido ao fato de que" with "porque"; "neste momento" with "agora"; "é importante notar que os dados mostram" with "os dados mostram".
24. Excessive qualifiers — do not stack hedges ("para ser justo", "também é possível que", "poderia potencialmente") until no claim in the text sounds solid. Keep a qualifier only when the original text supports it; drop hedges that only soften an earlier overstatement.
25. Generic upbeat endings — cut vague-optimism closers ("o futuro é promissor", "tempos empolgantes estão por vir"); end on the last concrete fact instead.
26. Overuse of hyphenated compounds — do not hyphenate everywhere terms like "orientado a dados", "em tempo real", "de ponta a ponta", "bem conhecido". Keep the hyphen only when grammar requires it before the noun; drop it after the noun.
27. Fake profundity — avoid "a verdadeira questão é", "no fundo", "na realidade", "o que realmente importa", "o cerne da questão" dressing up an ordinary point. State the concrete idea instead.
28. Announcing the next point instead of making it — avoid "vamos mergulhar em", "vamos explorar", "eis o que você precisa saber", "sem mais delongas". Go straight to the content.
29. Heading repeated in the next sentence — if the heading already says "Desempenho", do not open the paragraph with a sentence that just restates "desempenho importa"; go straight to the content.
30. Talking about the previous version out of context — descriptive text should describe the current state; mentions of a prior approach belong only in changelogs or release notes.
31. Forced punchlines in a row — one short punchy sentence is fine; a row of dramatic fragments in sequence feels forced — merge them into full sentences.
32. Formulaic sayings — avoid effect-lines like "X é a linguagem de Y", "X se torna uma armadilha", "a arquitetura de", "a moeda de". State the real claim behind the saying.
33. Fake-candid openings — avoid staged hooks like "sinceramente?", "olha,", "a verdade é que", "vamos ser francos" before an ordinary point. State the point directly.
34. Answering objections no one raised — remove unsolicited defenses ("não estou dizendo que...", "para ficar claro, isso não é sobre...", "não me interpretem mal"). If there is a real claim behind it, state it directly.
35. Rejecting fake alternatives — cut invented options that no one would consider, that the text rejects and never mentions again ("uma opção tentadora seria... mas", "seria fácil simplesmente..."). Go straight to the real constraint.

### Do not flag (avoid false positives)

- Flawless grammar and consistent style are not, by themselves, a sign of AI.
- A mix of formal and informal register can simply be the author's personal style.
- Dry or technical text is not "robotic" just for being dry — the problem is having the specific tells above, not the lack of flourish.
- Isolated formal or academic words should not be dumbed down.
- One connector ("porém", "contudo", "além disso") on its own is not a tell; the problem is stacking several.
- One em dash or curly quote alone proves nothing; they only count when stacked with other tells.
- One short punchy sentence is fine; the problem is a row of them.
- A deliberately repeated sentence opening can be a legitimate stylistic choice for rhythm.
- An unsourced claim on its own proves nothing.
- Keep scope notes, legal disclaimers, real corrections, and objections the text itself names and answers.

### Human details to keep

- Specific, unusual details (a real address, an odd quote, a very specific reference).
- Mixed feelings and unresolved tension ("acho isso bom, mas me incomoda, e não sei explicar por quê").
- Varied sentence length — mix short and long; do not flatten everything into one even rhythm.
- Genuine asides, parentheticals, and self-corrections from the author.

### Rewrite process and self-check

1. Read the source text and mark every AI pattern found.
2. Draft the rewrite, keeping every fact, name, number, date, and quote from the original.
3. Before answering, ask: "What still sounds AI-generated?" and "Did I add or remove any fact, name, number, date, or quote compared to the original?" Any unsupported addition is an error to fix.
4. Produce the final version by resolving each point naturally — if a sentence still feels off after swapping just the flagged word, rewrite the whole sentence or paragraph around its main point instead of patching it word by word.

Write the final rewritten text in Brazilian Portuguese (pt-BR), respecting the tone and purpose already given above.
''';
