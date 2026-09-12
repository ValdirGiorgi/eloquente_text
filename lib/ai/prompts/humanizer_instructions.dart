import '../../models/language.dart';

/// Instruções do modo Humanizar, anexadas ao prompt de sistema quando o
/// toggle está ligado — uma por idioma de saída suportado.
///
/// São as 35 categorias de marcas de texto gerado por IA catalogadas pelo
/// projeto humanizer (https://github.com/blader/humanizer, MIT), que por
/// sua vez compila os "Signs of AI writing" da Wikipédia
/// (en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), mantidos pela
/// WikiProject AI Cleanup. Mesma estrutura do SKILL.md original (watch for
/// / regra / exemplo), mais as seções de falsos positivos e de detalhes
/// humanos a preservar.
///
/// Cada bloco troca só os exemplos de "watch for" e a frase final pelo
/// idioma de saída correspondente — os tells de IA em espanhol e inglês são
/// os equivalentes reais catalogados para essas línguas, não uma tradução
/// literal dos exemplos em português.
///
/// Escritas em inglês de propósito — instruções em inglês custam menos
/// tokens e são seguidas de forma mais confiável pelo modelo.
String humanizerInstructionsFor(Language language) {
  switch (language) {
    case Language.portuguese:
      return _humanizerInstructionsPt;
    case Language.spanish:
      return _humanizerInstructionsEs;
    case Language.english:
      return _humanizerInstructionsEn;
  }
}

const String _humanizerInstructionsPt = '''
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

const String _humanizerInstructionsEs = '''
## Humanize mode

On top of the rules above, rewrite the text so it reads like it was written by a person, not a chatbot, based on Wikipedia's "Signs of AI writing" and the humanizer project that catalogs them. Do not change what the text says: you may shorten weak parts, expand useful parts, and merge or split paragraphs, but every fact, name, number, date, and quote from the original text must survive. Never add a fact, name, number, date, quote, or source that is not in the original text or given by the user.

Check the text against all 35 patterns below and fix the ones that apply. Do not flag anything listed under "Do not flag" as a problem. The "watch for" phrases are in Spanish because the final rewrite must be in Spanish.

### Content patterns

1. Inflated importance/legacy claims — watch for "representa un hito", "es un testimonio de", "desempeña un papel crucial/fundamental/vital", "refleja una tendencia más amplia", "simbolizando", "moldeando el futuro de", "panorama en constante evolución", "punto de inflexión", "huella indeleble", "profundamente arraigado". Ordinary facts should not be dressed up as turning points or legacies. E.g. turn "La creación del instituto en 1989 marcó un momento crucial en la evolución de las estadísticas regionales" into "El instituto fue creado en 1989".
2. Name-dropping to prove importance — cut lists of press outlets or follower counts used only to impress ("citado por diversos medios", "presencia activa en redes sociales con miles de seguidores"). Keep a citation only if it adds real context.
3. Shallow analysis via gerund phrases — watch for "-ando/-endo" clauses that inflate a plain fact ("destacando la importancia de", "reforzando el compromiso con", "reflejando la profunda conexión"). State the fact plainly instead.
4. Sales language — avoid "vibrante", "rico(a) en cultura", "profundo(a)", "compromiso con", "belleza impresionante", "ubicado en el corazón de", "imperdible", "que quita el aliento", "reconocido/de renombre". The text should not read like a tourism ad or a brochure.
5. Vague sourcing — avoid "los expertos señalan", "según informes", "observadores afirman", "diversas fuentes indican" without naming anyone. Name the real source if the original text has one; otherwise remove the claim. Never invent a source.
6. Formulaic "challenges" / "future outlook" sections — cut generic paragraphs like "a pesar de los desafíos, [X] sigue prosperando" or "el futuro es prometedor" that add no new fact.

### Language and grammar patterns

7. Overused AI words — watch for clusters of "además", "de hecho", "esencial", "profundizar", "duradero", "optimizar", "fomentar", "destacar" (verb), "intrincado(a)", "fundamental" (as filler), "panorama" (abstract), "crucial", "evidenciar", "valioso", "vibrante", "tapiz" (abstract), "testimonio". One use is fine; several in the same paragraph is the tell.
8. Avoiding simple verbs (es/son/tiene) — replace "actúa como", "cuenta con", "ostenta" with plain "es"/"tiene" when nothing is gained. E.g. "la galería cuenta con cuatro salas y ostenta 300 m²" → "la galería tiene cuatro salas, con un total de 300 m²".
9. "Not just X, it's Y" and clipped negative endings — avoid the contrast formula "no es solo... es..." and abrupt endings like "sin rodeos". State the point directly.
10. Forced groups of three — do not force exactly three items ("innovación, inspiración e ideas") when the text only supports one or two real points.
11. Synonym cycling and repeated sentence openings — use one consistent name/term for the same subject instead of cycling synonyms ("el protagonista" / "el personaje central" / "el héroe" for the same person); vary the structure when several sentences in a row share the same opening subject. Deliberate repetition for rhythm is not automatically wrong.
12. False "from X to Y" ranges — avoid "de X a Y" when X and Y do not form a real range; list the items directly instead.
13. Passive voice and missing subjects — prefer active voice when it makes clear who does what. E.g. "no se requiere ninguna configuración" → "no necesitas configurar nada".

### Style patterns

14. Overuse of em/en dashes — the final text must not contain "—" or "--" as decorative punctuation unless the original text already uses them at that rate; replace with a comma, period, colon, or parentheses.
15. Excessive bold — do not bold terms without a functional reason.
16. Lists with bold mini-headings — avoid lists where every item opens with a bold label and a colon; prefer flowing prose when it fits better.
17. Title Case in headings — capitalize only the first word and proper nouns in headings, not every main word.
18. Decorative emojis — do not add emojis to headings or list items as decoration.
19. Curly quotes — prefer straight quotes ("...") over curly/typographic quotes (“...”), unless the original text already uses them.

### Chatbot patterns

20. Leftover chatbot text — remove any assistant greeting, offer, or closing that leaked into the text ("¡espero que esto ayude!", "¡claro!", "¿quieres que continúe?", "avísame si necesitas algo más"). The text must stand on its own.
21. Knowledge-limit disclaimers and disguised guesses — never present a guess as a fact ("no hay datos públicos disponibles, lo que sugiere que probablemente creció en..."). State plainly what is unknown, or cut the sentence.
22. Overly agreeable tone — do not praise the question or the person before answering ("¡excelente pregunta!", "tienes toda la razón"). Answer directly.

### Filler and hedging

23. Filler phrases — replace "con el fin de lograr ese objetivo" with "para lograrlo"; "debido al hecho de que" with "porque"; "en este momento" with "ahora"; "es importante señalar que los datos muestran" with "los datos muestran".
24. Excessive qualifiers — do not stack hedges ("para ser justos", "también es posible que", "podría potencialmente") until no claim in the text sounds solid. Keep a qualifier only when the original text supports it; drop hedges that only soften an earlier overstatement.
25. Generic upbeat endings — cut vague-optimism closers ("el futuro es prometedor", "vienen tiempos emocionantes"); end on the last concrete fact instead.
26. Overuse of hyphenated compounds — do not hyphenate everywhere terms like "orientado a datos", "en tiempo real", "de extremo a extremo", "bien conocido". Keep the hyphen only when grammar requires it before the noun; drop it after the noun.
27. Fake profundity — avoid "la verdadera cuestión es", "en el fondo", "en realidad", "lo que realmente importa", "la clave del asunto" dressing up an ordinary point. State the concrete idea instead.
28. Announcing the next point instead of making it — avoid "vamos a profundizar en", "exploremos", "esto es lo que necesitas saber", "sin más preámbulos". Go straight to the content.
29. Heading repeated in the next sentence — if the heading already says "Rendimiento", do not open the paragraph with a sentence that just restates "el rendimiento importa"; go straight to the content.
30. Talking about the previous version out of context — descriptive text should describe the current state; mentions of a prior approach belong only in changelogs or release notes.
31. Forced punchlines in a row — one short punchy sentence is fine; a row of dramatic fragments in sequence feels forced — merge them into full sentences.
32. Formulaic sayings — avoid effect-lines like "X es el lenguaje de Y", "X se convierte en una trampa", "la arquitectura de", "la moneda de". State the real claim behind the saying.
33. Fake-candid openings — avoid staged hooks like "¿sinceramente?", "mira,", "la verdad es que", "seamos francos" before an ordinary point. State the point directly.
34. Answering objections no one raised — remove unsolicited defenses ("no estoy diciendo que...", "para que quede claro, esto no se trata de...", "no me malinterpretes"). If there is a real claim behind it, state it directly.
35. Rejecting fake alternatives — cut invented options that no one would consider, that the text rejects and never mentions again ("una opción tentadora sería... pero", "sería fácil simplemente..."). Go straight to the real constraint.

### Do not flag (avoid false positives)

- Flawless grammar and consistent style are not, by themselves, a sign of AI.
- A mix of formal and informal register can simply be the author's personal style.
- Dry or technical text is not "robotic" just for being dry — the problem is having the specific tells above, not the lack of flourish.
- Isolated formal or academic words should not be dumbed down.
- One connector ("sin embargo", "no obstante", "además") on its own is not a tell; the problem is stacking several.
- One em dash or curly quote alone proves nothing; they only count when stacked with other tells.
- One short punchy sentence is fine; the problem is a row of them.
- A deliberately repeated sentence opening can be a legitimate stylistic choice for rhythm.
- An unsourced claim on its own proves nothing.
- Keep scope notes, legal disclaimers, real corrections, and objections the text itself names and answers.

### Human details to keep

- Specific, unusual details (a real address, an odd quote, a very specific reference).
- Mixed feelings and unresolved tension ("creo que esto es bueno, pero me incomoda, y no sé explicar por qué").
- Varied sentence length — mix short and long; do not flatten everything into one even rhythm.
- Genuine asides, parentheticals, and self-corrections from the author.

### Rewrite process and self-check

1. Read the source text and mark every AI pattern found.
2. Draft the rewrite, keeping every fact, name, number, date, and quote from the original.
3. Before answering, ask: "What still sounds AI-generated?" and "Did I add or remove any fact, name, number, date, or quote compared to the original?" Any unsupported addition is an error to fix.
4. Produce the final version by resolving each point naturally — if a sentence still feels off after swapping just the flagged word, rewrite the whole sentence or paragraph around its main point instead of patching it word by word.

Write the final rewritten text in Spanish (es), respecting the tone and purpose already given above.
''';

const String _humanizerInstructionsEn = '''
## Humanize mode

On top of the rules above, rewrite the text so it reads like it was written by a person, not a chatbot, based on Wikipedia's "Signs of AI writing" and the humanizer project that catalogs them. Do not change what the text says: you may shorten weak parts, expand useful parts, and merge or split paragraphs, but every fact, name, number, date, and quote from the original text must survive. Never add a fact, name, number, date, quote, or source that is not in the original text or given by the user.

Check the text against all 35 patterns below and fix the ones that apply. Do not flag anything listed under "Do not flag" as a problem.

### Content patterns

1. Inflated importance/legacy claims — watch for "stands as a testament to", "represents a milestone", "plays a crucial/pivotal/vital role", "reflects a broader trend", "symbolizing", "shaping the future of", "evolving landscape", "turning point", "indelible mark", "deeply rooted". Ordinary facts should not be dressed up as turning points or legacies. E.g. turn "The institute's founding in 1989 marked a pivotal moment in the evolution of regional statistics" into "The institute was founded in 1989".
2. Name-dropping to prove importance — cut lists of press outlets or follower counts used only to impress ("featured in numerous outlets", "an active social media presence with thousands of followers"). Keep a citation only if it adds real context.
3. Shallow analysis via gerund phrases — watch for "-ing" clauses that inflate a plain fact ("highlighting the importance of", "underscoring the commitment to", "reflecting the deep connection"). State the fact plainly instead.
4. Sales language — avoid "vibrant", "rich cultural heritage", "profound", "commitment to", "stunning beauty", "nestled in the heart of", "must-see", "breathtaking", "renowned". The text should not read like a tourism ad or a brochure.
5. Vague sourcing — avoid "experts point out", "reports suggest", "observers say", "sources indicate" without naming anyone. Name the real source if the original text has one; otherwise remove the claim. Never invent a source.
6. Formulaic "challenges" / "future outlook" sections — cut generic paragraphs like "despite these challenges, [X] continues to thrive" or "the future looks promising" that add no new fact.

### Language and grammar patterns

7. Overused AI words — watch for clusters of "moreover", "indeed", "essential", "delve into", "enduring", "enhance", "foster", "highlight" (verb), "intricate", "crucial" (as filler), "landscape" (abstract), "pivotal", "underscore", "valuable", "vibrant", "tapestry" (abstract), "testament". One use is fine; several in the same paragraph is the tell.
8. Avoiding simple verbs (is/are/has) — replace "serves as", "boasts", "features" with plain "is"/"has" when nothing is gained. E.g. "the gallery boasts four rooms and features 300 m²" → "the gallery has four rooms, totaling 300 m²".
9. "Not just X, it's Y" and clipped negative endings — avoid the contrast formula "it's not just... it's..." and abrupt endings like "no fluff". State the point directly.
10. Forced groups of three — do not force exactly three items ("innovation, inspiration, and insight") when the text only supports one or two real points.
11. Synonym cycling and repeated sentence openings — use one consistent name/term for the same subject instead of cycling synonyms ("the protagonist" / "the central character" / "the hero" for the same person); vary the structure when several sentences in a row share the same opening subject. Deliberate repetition for rhythm is not automatically wrong.
12. False "from X to Y" ranges — avoid "from X to Y" when X and Y do not form a real range; list the items directly instead.
13. Passive voice and missing subjects — prefer active voice when it makes clear who does what. E.g. "no configuration is required" → "you don't need to configure anything".

### Style patterns

14. Overuse of em/en dashes — the final text must not contain "—" or "--" as decorative punctuation unless the original text already uses them at that rate; replace with a comma, period, colon, or parentheses.
15. Excessive bold — do not bold terms without a functional reason.
16. Lists with bold mini-headings — avoid lists where every item opens with a bold label and a colon; prefer flowing prose when it fits better.
17. Title Case in headings — capitalize only the first word and proper nouns in headings, not every main word.
18. Decorative emojis — do not add emojis to headings or list items as decoration.
19. Curly quotes — prefer straight quotes ("...") over curly/typographic quotes (“...”), unless the original text already uses them.

### Chatbot patterns

20. Leftover chatbot text — remove any assistant greeting, offer, or closing that leaked into the text ("I hope this helps!", "certainly!", "would you like me to continue?", "let me know if you need anything else"). The text must stand on its own.
21. Knowledge-limit disclaimers and disguised guesses — never present a guess as a fact ("there is no public data available, which suggests it likely grew by..."). State plainly what is unknown, or cut the sentence.
22. Overly agreeable tone — do not praise the question or the person before answering ("great question!", "you're absolutely right"). Answer directly.

### Filler and hedging

23. Filler phrases — replace "in order to achieve this goal" with "to achieve this"; "due to the fact that" with "because"; "at this point in time" with "now"; "it's important to note that the data shows" with "the data shows".
24. Excessive qualifiers — do not stack hedges ("to be fair", "it's also possible that", "could potentially") until no claim in the text sounds solid. Keep a qualifier only when the original text supports it; drop hedges that only soften an earlier overstatement.
25. Generic upbeat endings — cut vague-optimism closers ("the future looks bright", "exciting times lie ahead"); end on the last concrete fact instead.
26. Overuse of hyphenated compounds — do not hyphenate everywhere terms like "data-driven", "real-time", "end-to-end", "well-known". Keep the hyphen only when grammar requires it before the noun; drop it after the noun.
27. Fake profundity — avoid "the real question is", "at its core", "in reality", "what truly matters", "the heart of the matter" dressing up an ordinary point. State the concrete idea instead.
28. Announcing the next point instead of making it — avoid "let's dive into", "let's explore", "here's what you need to know", "without further ado". Go straight to the content.
29. Heading repeated in the next sentence — if the heading already says "Performance", do not open the paragraph with a sentence that just restates "performance matters"; go straight to the content.
30. Talking about the previous version out of context — descriptive text should describe the current state; mentions of a prior approach belong only in changelogs or release notes.
31. Forced punchlines in a row — one short punchy sentence is fine; a row of dramatic fragments in sequence feels forced — merge them into full sentences.
32. Formulaic sayings — avoid effect-lines like "X is the language of Y", "X becomes a trap", "the architecture of", "the currency of". State the real claim behind the saying.
33. Fake-candid openings — avoid staged hooks like "honestly?", "look,", "the truth is", "let's be frank" before an ordinary point. State the point directly.
34. Answering objections no one raised — remove unsolicited defenses ("I'm not saying that...", "to be clear, this isn't about...", "don't get me wrong"). If there is a real claim behind it, state it directly.
35. Rejecting fake alternatives — cut invented options that no one would consider, that the text rejects and never mentions again ("one tempting option would be... but", "it would be easy to simply..."). Go straight to the real constraint.

### Do not flag (avoid false positives)

- Flawless grammar and consistent style are not, by themselves, a sign of AI.
- A mix of formal and informal register can simply be the author's personal style.
- Dry or technical text is not "robotic" just for being dry — the problem is having the specific tells above, not the lack of flourish.
- Isolated formal or academic words should not be dumbed down.
- One connector ("however", "furthermore", "moreover") on its own is not a tell; the problem is stacking several.
- One em dash or curly quote alone proves nothing; they only count when stacked with other tells.
- One short punchy sentence is fine; the problem is a row of them.
- A deliberately repeated sentence opening can be a legitimate stylistic choice for rhythm.
- An unsourced claim on its own proves nothing.
- Keep scope notes, legal disclaimers, real corrections, and objections the text itself names and answers.

### Human details to keep

- Specific, unusual details (a real address, an odd quote, a very specific reference).
- Mixed feelings and unresolved tension ("I think this is good, but it bothers me, and I can't explain why").
- Varied sentence length — mix short and long; do not flatten everything into one even rhythm.
- Genuine asides, parentheticals, and self-corrections from the author.

### Rewrite process and self-check

1. Read the source text and mark every AI pattern found.
2. Draft the rewrite, keeping every fact, name, number, date, and quote from the original.
3. Before answering, ask: "What still sounds AI-generated?" and "Did I add or remove any fact, name, number, date, or quote compared to the original?" Any unsupported addition is an error to fix.
4. Produce the final version by resolving each point naturally — if a sentence still feels off after swapping just the flagged word, rewrite the whole sentence or paragraph around its main point instead of patching it word by word.

Write the final rewritten text in English (en), respecting the tone and purpose already given above.
''';
