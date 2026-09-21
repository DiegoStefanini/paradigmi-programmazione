#import "@preview/cetz:0.4.2": canvas, draw, tree

#set document(title: "Paradigmi di Programmazione — Dispensa")
#set page(paper: "a4", margin: 2.2cm, numbering: "1")
#set text(lang: "it", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => { pagebreak(weak: true); it }
#show raw.where(block: true): block.with(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)
#show raw.where(block: false): box.with(fill: luma(240), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt)
#set table(stroke: 0.5pt + luma(180), inset: 6pt)
#show table.cell.where(y: 0): strong

#let blu = rgb("#3b6fd8")
#let verde = rgb("#2e9e5b")
#let grigio = luma(170)

// osservazione del prof, trappola
#let nota(body) = block(
  fill: rgb("#eef4ff"), stroke: (left: 3pt + blu),
  inset: 10pt, width: 100%, body,
)
// prerequisito non spiegato in aula, aggiunto su richiesta
#let base(titolo, body) = block(
  fill: rgb("#eefaf2"), stroke: (left: 3pt + verde),
  inset: 10pt, width: 100%,
)[*Da sapere — #titolo* #h(0.3em) #text(8pt, fill: verde)[(aggiunto, non spiegato in aula)] \ #body]

#let mono(s) = text(font: "DejaVu Sans Mono", s)
// conto in colonna: righe allineate a destra, riga sopra il risultato
#let conto(op: "+", sopra: (), ..righe) = {
  let r = righe.pos()
  let celle = ()
  for s in sopra { celle += ([], text(fill: grigio, mono(s))) }
  for (i, x) in r.slice(0, -1).enumerate() {
    if i == 2 { celle.push(grid.hline(start: 1, stroke: 0.5pt)) }
    celle += (if i == 1 { op } else { [] }, mono(x))
  }
  celle += (grid.hline(start: 1, stroke: 0.8pt), [], strong(mono(r.last())))
  box(grid(columns: 2, align: right, inset: (x: 2pt, y: 3pt), ..celle))
}
// passaggi etichettati: ((etichetta, bit), ...), riga sopra l'ultimo
#let passi(..righe) = {
  let r = righe.pos()
  let celle = ()
  for (i, (e, x)) in r.enumerate() {
    if i == r.len() - 1 { celle.push(grid.hline(stroke: 0.8pt)) }
    celle += (text(8pt, fill: gray, e), if i == r.len() - 1 { strong(mono(x)) } else { mono(x) })
  }
  box(grid(columns: 2, align: (left, right), inset: (x: 3pt, y: 3pt), ..celle))
}
// pila di livelli: ogni elemento è (testo, colore di sfondo)
#let pila(larghezza: 3.4cm, ..livelli) = stack(..livelli.pos().map(((t, c)) =>
  box(width: larghezza, inset: 5pt, stroke: 0.6pt, fill: c, align(center, text(9pt, t)))))
#let figura(corpo, didascalia) = figure(corpo, caption: didascalia, kind: image, supplement: none)

// espressione con i legami disegnati: sim = simboli, archi = (binder, occorrenza), libere = indici in rosso
#let legami(sim, archi, libere: ()) = canvas(length: 0.36cm, {
  import draw: *
  for (k, s) in sim.enumerate() {
    let col = if k in libere { red } else if archi.any(((a, b)) => a == k or b == k) { verde } else { black }
    content((k, 0), text(13pt, fill: col, weight: if col == black { "regular" } else { "bold" }, s))
  }
  for (a, b) in archi {
    bezier((b, 0.6), (a, 0.6), ((a + b) / 2, 0.6 + 0.35 * (b - a)), stroke: 0.7pt + verde, mark: (end: "stealth"))
  }
})
// scatola: input → [funzione] → output
#let scatola(ingresso, f, uscita) = align(center, stack(dir: ltr, spacing: 0.7em,
  align(horizon, text(13pt, ingresso)), align(horizon)[→],
  box(stroke: 1pt + blu, fill: rgb("#eef4ff"), inset: 10pt, radius: 4pt, text(13pt, f)),
  align(horizon)[→], align(horizon, text(13pt, uscita))))
#let albero(t) = canvas(length: 0.8cm, {
  import draw: *
  tree.tree(t, spread: 0.9, grow: 1.1, draw-node: (node, ..) => content((), text(fill: blu, node.content)))
})

#align(center)[
  #v(4cm)
  #text(24pt, weight: "bold")[Paradigmi di Programmazione]
  #v(0.3cm)
  #text(14pt)[Diego Stefanini — prof.ssa Chiara Bodei, a.a. 2026-27]
]
#v(1cm)
#outline(depth: 2)

= Il lambda calcolo

== Da dove viene: la calcolabilità

*Hilbert, Entscheidungsproblem* (problema della decisione): esiste una procedura *del tutto meccanica* che, data una qualunque formula della logica del primo ordine, dice se è un teorema?

Per rispondere bisogna prima dire cos'è una "procedura meccanica", cioè un *algoritmo*. Tre risposte diverse, quasi insieme:

#align(center, grid(columns: 3, gutter: 1em,
  ..(("Alonzo Church", "lambda calcolo", "1935"), ("Kurt Gödel, Stephen Kleene", "funzioni ricorsive", "1935"), ("Alan Turing", "macchina di Turing", "1936")).map(((chi, cosa, anno)) =>
    box(stroke: 0.6pt, inset: 8pt, width: 4.4cm, fill: rgb("#eef4ff"), radius: 4pt, align(center)[*#cosa* \ #text(9pt)[#chi, #anno]]))))

=== La macchina di Turing

#grid(columns: (1.3fr, 1fr), gutter: 1.5em, align: horizon,
canvas(length: 0.7cm, {
  import draw: *
  let simboli = ("B", "a", "b", "a", "B", "B", "")
  for (k, s) in simboli.enumerate() { rect((k, 0), (k + 1, 1)); content((k + 0.5, 0.5), s) }
  content((7.6, 0.5), [...])
  content((3.5, 1.6), text(8pt)[nastro potenzialmente infinito])
  line((1.5, -0.1), (1.5, -1.1), mark: (start: "stealth"), stroke: 1.2pt + red)
  content((2.5, -0.6), text(8pt, fill: red)[testina])
  rect((0.3, -1.2), (2.7, -2.4), radius: 0.2, fill: rgb("#eef4ff"))
  content((1.5, -1.8), text(9pt)[controllo \ finito])
}),
[
  - Macchina *ideale*, non fisica: legge e scrive simboli su un nastro, secondo regole fissate.
  - Esempio di regola: _legge a, riscrive a e si sposta a destra_.
  - È il modello astratto di una macchina che esegue algoritmi.
])

*Macchina di Turing Universale* (UTM): una macchina di Turing che, data la *descrizione* di un'altra macchina e i suoi dati, la simula. È il modello teorico del computer: il programma è un dato.

Con la UTM Turing risponde *no* all'Entscheidungsproblem: esistono problemi che nessuna macchina di calcolo può risolvere.

=== Tesi di Church-Turing

#grid(columns: (1fr, 1fr), gutter: 1.5em, align: horizon,
canvas(length: 0.8cm, {
  import draw: *
  rect((0, 0), (9, 4.6), radius: 0.3, fill: rgb("#eef4ff"))
  content((4.5, 4.05), text(9pt)[*macchina di Turing* = λ-calcolo = funzioni ricorsive])
  rect((0.3, 0.3), (8.7, 3.4), radius: 0.3, fill: rgb("#dbe7ff"))
  content((4.5, 2.9), text(8pt)[macchine che terminano sempre (funzioni totali)])
  rect((0.7, 0.6), (8.3, 2.3), radius: 0.3, fill: rgb("#c4d6ff"))
  content((4.5, 1.45), text(8pt)[espressioni regolari \ (automi a stati finiti)])
  content((4.5, -0.5), text(8pt, fill: gray)[più è interno, meno è potente])
}),
[
  Se una funzione è calcolabile con un qualunque formalismo, allora esiste una macchina di Turing che la calcola.

  È *indimostrabile* (i formalismi possibili sono infiniti) ma universalmente accettata: non si conosce nessun modello più potente.

  Un linguaggio è *Turing completo* se calcola tutto ciò che calcola una macchina di Turing. Si dimostra scrivendo nel linguaggio un programma che *simula* una macchina di Turing.
])

== Due famiglie di linguaggi

=== Turing → von Neumann → linguaggi imperativi

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
canvas(length: 0.8cm, {
  import draw: *
  rect((0, 2), (3.4, 4), fill: rgb("#fff3c4")); content((1.7, 3), align(center)[*Memoria* \ #text(8pt)[programmi + dati]])
  rect((4.5, 1.2), (9.5, 4.8), radius: 0.2)
  content((7, 4.4), [*CPU*])
  rect((4.8, 2.9), (9.2, 3.9), fill: rgb("#eef4ff")); content((7, 3.4), text(8pt)[unità di controllo])
  rect((4.8, 1.5), (9.2, 2.5), fill: rgb("#eef4ff")); content((7, 2.0), text(8pt)[unità aritmetico-logica])
  line((3.5, 3), (4.4, 3), mark: (start: "stealth", end: "stealth"))
  rect((4.8, -0.4), (9.2, 0.6)); content((7, 0.1), text(8pt)[I/O])
  line((7, 0.7), (7, 1.1), mark: (start: "stealth", end: "stealth"))
}),
[
  *Architettura di von Neumann*, ispirata alla macchina di Turing ma concreta:
  - *memoria* con programmi e dati;
  - *CPU* che preleva un'istruzione alla volta, la interpreta e la esegue.

  La generalità viene dal *programma memorizzato*.
])

Un linguaggio "alla von Neumann" riproduce ad alto livello questa struttura:

#align(center, table(columns: 3, align: (right, center, left),
  [Nel linguaggio], [], [Nella macchina],
  [variabili], [↔], [celle di memoria (il nastro)],
  [istruzioni di controllo (if, cicli)], [↔], [test & jump],
  [assegnamento], [↔], [modifica dello stato (fetch & store)],
))

*Backus*: l'assegnamento divide la programmazione in due mondi.
#align(center, grid(columns: 2, gutter: 1em,
  box(stroke: 0.6pt + verde, inset: 8pt, width: 6.5cm)[*espressioni* \ #text(9pt)[spazio matematico ordinato, con proprietà algebriche utili. Lì avviene la maggior parte del calcolo]],
  box(stroke: 0.6pt + red, inset: 8pt, width: 6.5cm)[*istruzioni* \ #text(9pt)[spazio disordinato, con poche proprietà utili. La programmazione strutturata prova a metterci un po' d'ordine]],
))

=== Church → linguaggi funzionali

*Programmazione funzionale*: il programma è una serie di *valutazioni di funzioni matematiche*. Punto di forza: niente *effetti collaterali*, quindi è più facile verificare che il programma sia corretto e ottimizzarlo. Il λ-calcolo (Church, 1935) è il primo linguaggio funzionale.

#figura(canvas(length: 0.5cm, {
  import draw: *
  line((0, 0), (0, -14), stroke: 1pt, mark: (end: "stealth"))
  line((14, 0), (14, -14), stroke: 1pt, mark: (end: "stealth"))
  content((0, 0.8), [*linguaggi "di Turing"*]); content((14, 0.8), [*linguaggi "di Church"*])
  let y(a) = -(a - 1955) * 0.36
  for (a, t) in ((1957, "FORTRAN"), (1959, "COBOL, ALGOL"), (1962, "SIMULA"), (1972, "C, Smalltalk"), (1979, "C++"), (1991, "Python"), (1995, "Java")) {
    circle((0, y(a)), radius: 0.12, fill: black); content((0.5, y(a)), anchor: "west", text(9pt)[#a — #t])
  }
  for (a, t) in ((1959, "LISP"), (1966, "ISWIM"), (1972, "Prolog"), (1978, "ML"), (1990, "Haskell")) {
    circle((14, y(a)), radius: 0.12, fill: blu); content((14.5, y(a)), anchor: "west", text(9pt, fill: blu)[#a — #t])
  }
}), [Le due linee di discendenza])

== Astrazione funzionale

#align(center, canvas(length: 1cm, {
  import draw: *
  content((0, 0), text(30pt, fill: red)[$lambda$])
  content((0.7, 0), text(30pt, fill: blu)[$x$])
  content((1.2, 0), text(30pt)[.])
  content((1.8, 0), text(30pt, fill: verde)[$x$])
  line((0, -0.5), (-1.2, -1.3), mark: (start: "stealth")); content((-1.8, -1.6), text(9pt, fill: red)[$lambda$ introduce la funzione])
  line((0.7, 0.55), (-0.3, 1.4), mark: (start: "stealth")); content((-1.2, 1.8), text(9pt, fill: blu)[argomento (parametro formale)])
  line((1.2, -0.3), (1.6, -1.3), mark: (start: "stealth")); content((2.2, -1.6), text(9pt)[il punto separa variabile e corpo])
  line((1.9, 0.55), (3.2, 1.4), mark: (start: "stealth")); content((4.6, 1.8), text(9pt, fill: verde)[corpo: calcolato sull'input dà l'output])
}))

Legge di corrispondenza: $forall x. f(x) = x$. È la *funzione identità*.

== Applicazione

Applicare una funzione = darle un *parametro attuale* al posto del parametro formale. Immagina la funzione come una scatola:

#align(center, grid(columns: (auto, auto), gutter: 1.2em, align: (right + horizon, left + horizon),
  scatola($z$, $lambda x. x$, $z$), [*identità*: restituisce l'input così com'è],
  scatola($z$, $lambda x. y$, $y$), [*costante*: restituisce sempre $y$ #h(0.3em) ($forall x. f(x) = y$)],
  scatola($z, w$, $lambda x. lambda y. x$, $z$), [*selezione*: prende due argomenti e restituisce il primo],
))

La selezione passo per passo: $((lambda x. lambda y. x) z) w arrow.r (lambda y. z) w arrow.r z$.

#nota[$lambda x. lambda y. x$ ha legge di corrispondenza $forall x. f(x) = g$ dove $g(y) = x$: una funzione che restituisce una funzione. È un modo alternativo di scrivere $f(x, y) = x$ con una funzione di un solo argomento.]

== Sintassi

Un programma è un'espressione (*λ-espressione*). Ci sono solo tre modi di costruirla:

#align(center, box(stroke: 1pt + blu, inset: 12pt, radius: 4pt, grid(columns: 2, align: left, inset: 5pt,
  [$e ::= x$], [variabile],
  [$quad | space lambda x. e$], [astrazione funzionale (dichiarazione di funzione)],
  [$quad | space e space e$], [applicazione (chiamata di funzione)],
)))
#align(center, text(fill: red, weight: "bold")[Niente altro! La sintassi è finita.])

=== $lambda x. e$ è una funzione anonima

Non ha nome; $x$ è la dichiarazione del suo parametro. Lo stesso concetto nei linguaggi:

#align(center, table(columns: 2,
  [Linguaggio], [$x mapsto x + 1$],
  [JavaScript], [`function(a){ return a + 1; }` oppure `a => a+1`],
  [OCaml], [`fun x -> x+1`],
  [Java (si chiamano lambda)], [`(int x) -> x + 1`],
))

In $e_1 e_2$ la funzione $e_1$ è applicata all'argomento $e_2$, come una chiamata in JavaScript: $e_1$ definisce la funzione, $e_2$ il parametro attuale. La definizione può stare *direttamente dentro* la chiamata: $underbrace((lambda x. (lambda y. x y)), e_1) underbrace((lambda z. z), e_2)$.

== Esempi

#table(columns: (auto, 1fr), align: (left, left),
  [Espressione], [Cosa fa],
  [$lambda x. x$], [identità],
  [$lambda y. (lambda x. x)$], [scarta l'argomento $y$ e restituisce l'identità: è una *funzione costante*],
  [$lambda f. f (lambda x. x)$], [data una funzione $f$, la *invoca sull'identità*],
)

#table(columns: (auto, 1fr), align: (left, left),
  [Applicazione], [Passi],
  [$(lambda x. x) y$], [$arrow.r y$],
  [$(lambda x. ((lambda y. y) x)) z$], [$arrow.r (lambda y. y) z arrow.r z$],
  [$(lambda f. f z)(lambda x. x)$], [$arrow.r (lambda x. x) z arrow.r z$ #h(1em) #text(9pt)[prende una funzione e la applica a $z$]],
  [$(lambda x. (x x))(lambda y. y)$], [$arrow.r (lambda y. y)(lambda y. y) arrow.r lambda y. y$ #h(1em) #text(9pt)[due termini uguali con ruoli diversi: funzione e argomento]],
  [$((lambda x. lambda y. x + y) 3) 5$], [$arrow.r (lambda y. 3 + y) 5 arrow.r 3 + 5 arrow.r 8$ #h(1em) #text(9pt)[(supponendo di avere il +)]],
  [$((lambda x. lambda y. x y)(lambda x. x)) z$], [$arrow.r (lambda y. (lambda x. x) y) z arrow.r (lambda x. x) z arrow.r z$ #h(1em) #text(9pt)[forma $e_1 e_2 e_3$]],
  [$(lambda x. lambda y. x y) z k$], [$arrow.r (lambda y. z y) k arrow.r z k$],
)

#nota[$(lambda y. 3 + y)$ è una funzione a sé: somma 3 a quello che le passi. Applicando una funzione di due argomenti a uno solo ottieni una funzione che aspetta l'altro.]

=== Attenzione 1: quale redex scelgo?

Un *redex* è un pezzo della forma $(lambda x. e) e'$, pronto per essere applicato. In $(lambda x. x)((lambda y. y) z)$ ce ne sono due:

#figura(canvas(length: 1cm, {
  import draw: *
  content((0, 0), box(stroke: 0.6pt, inset: 6pt)[$(lambda x. x)((lambda y. y) z)$])
  content((-3, -1.8), box(stroke: 0.6pt, inset: 6pt)[$(lambda y. y) z$])
  content((3, -1.8), box(stroke: 0.6pt, inset: 6pt)[$(lambda x. x) z$])
  content((0, -3.4), box(stroke: 1pt + verde, inset: 6pt)[$z$])
  line((-0.8, -0.35), (-2.5, -1.45), mark: (end: "stealth")); content((-2.6, -0.7), text(8pt)[redex più esterno])
  line((0.8, -0.35), (2.5, -1.45), mark: (end: "stealth")); content((2.6, -0.7), text(8pt)[redex più interno])
  line((-2.5, -2.15), (-0.4, -3.1), mark: (end: "stealth"))
  line((2.5, -2.15), (0.4, -3.1), mark: (end: "stealth"))
}), [Strade diverse, stesso risultato])

=== Attenzione 2: conflitto di nomi

#align(center, table(columns: 3, align: left,
  [], [Espressione], [Risultato],
  [ingenuo], [$(lambda x. lambda y. x y) y$], [$lambda y. y y$ #h(0.5em) #text(fill: red)[✗ sbagliato]],
  [rinomino $y$ in $z$], [$(lambda x. lambda z. x z) y$], [$lambda z. y z$ #h(0.5em) #text(fill: verde)[✓]],
))

Le due espressioni di partenza sono *la stessa funzione* (ho solo cambiato il nome del parametro), ma i risultati si comportano in modo diverso. Nel primo caso la $y$ libera che passo come argomento finisce *catturata* dal $lambda y$ interno: è un *conflitto di nomi*.

== Convenzioni sintattiche (importanti)

#grid(columns: 2, gutter: 1em,
  box(stroke: 0.6pt, inset: 8pt, width: 100%, fill: rgb("#fff3c4"))[
    *1. Lo scope di $lambda$ va il più a destra possibile* \
    $lambda x. lambda y. x y$ #h(0.3em) è #h(0.3em) $lambda x. (lambda y. (x y))$],
  box(stroke: 0.6pt, inset: 8pt, width: 100%, fill: rgb("#fff3c4"))[
    *2. L'applicazione associa a sinistra* \
    $e_1 e_2 e_3$ #h(0.3em) è #h(0.3em) $(e_1 e_2) e_3$],
)

*Esercizio*: quali parentesi sono sottintese in $lambda x. x lambda y. x y z$?
+ lo scope di $lambda$ va il più a destra possibile: $lambda x. (x lambda y. (x y z))$
+ l'applicazione associa a sinistra: $lambda x. (x (lambda y. ((x y) z)))$

== Alberi

L'albero segue l'annidamento completo delle parentesi. Serve a vedere quali passi di valutazione si possono fare. Nodo $lambda$: figlio sinistro il parametro, destro il corpo. Nodo \@ (applicazione): figli funzione e argomento.

#align(center, grid(columns: 3, gutter: 2.5em, align: bottom,
  [#albero(([$lambda$], [$x$], [$x$])) #align(center, text(9pt)[$lambda x. x$])],
  [#albero(([\@], ([$lambda$], [$x$], [$x$]), [$y$])) #align(center, text(9pt)[$(lambda x. x) y arrow.r y$])],
  [#albero(([$lambda$], [$x$], ([\@], [$x$], ([$lambda$], [$y$], ([\@], ([\@], [$x$], [$y$]), [$z$]))))) #align(center, text(9pt)[$lambda x. (x (lambda y. ((x y) z)))$])],
))

== Variabili libere e legate

$lambda$ è un *operatore di binding*: in $lambda x. e$ lega la $x$ dentro $e$ (il suo *scope*), come $forall x$ in $forall x. P$ nella logica. È l'*unico* modo di associare valori a variabili nel λ-calcolo.

- *Legata*: introdotta da un $lambda$ che la contiene. #text(fill: verde)[*verde*], la freccia punta al suo $lambda$.
- *Libera*: nessun $lambda$ la dichiara. #text(fill: red)[*rossa*].

$x$ in $lambda x. e$ è un segnaposto: si può rinominare con una variabile *fresca*, cioè un nome che non compare da nessuna parte nelle espressioni che stiamo trattando. È quello che risolve il conflitto di nomi.

#align(center, table(columns: (auto, 1fr), align: (center + horizon, left + horizon), inset: 8pt,
  [Espressione], [Chi è legato],
  legami(("λ", "x", ".", "x"), ((1, 3),)), [$x$ legata],
  legami(("λ", "x", ".", "λ", "y", ".", "(", "x", "y", "z", ")"), ((1, 7), (4, 8)), libere: (9,)), [$x$ e $y$ legate, $z$ libera],
  legami(("(", "λ", "f", ".", "f", "x", ")", "y"), ((2, 4),), libere: (5, 7)), [$f$ legata, $x$ e $y$ libere],
  legami(("(", "λ", "f", ".", "f", "x", ")", "f"), ((2, 4),), libere: (5, 7)), [la prima $f$ è legata; $x$ e *la seconda $f$ sono libere*: sta fuori dalle parentesi, fuori dallo scope di $lambda f$],
))

=== Attenzione: scope annidati

Una stessa variabile può voler dire cose diverse in punti diversi:

#align(center, legami(("λ", "x", ".", "x", "(", "λ", "x", ".", "x", ")", "x"), ((1, 3), (6, 8), (1, 10))))

#align(center)[che con le parentesi esplicite è $lambda x. (x (lambda x. x) x)$]

La $x$ nel $lambda x$ interno è legata a *quel* $lambda$, non a quello esterno. Tre $x$, due significati: da qui nasce il conflitto di nomi.
