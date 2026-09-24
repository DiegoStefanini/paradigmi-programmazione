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

== Calcolabilità e paradigmi

*Hilbert, Entscheidungsproblem* (problema della decisione): esiste una procedura *del tutto meccanica* che, data una qualunque formula della logica del primo ordine (un'affermazione matematica scritta in un linguaggio formale), dice se è un teorema, cioè se si può dimostrare?

Per rispondere bisogna prima dire cos'è una "procedura meccanica", cioè un *algoritmo*. Tre risposte diverse, quasi insieme:

#align(center, grid(columns: 3, gutter: 1em,
  ..(("Alonzo Church", "lambda calcolo", "1935"), ("Kurt Gödel, Stephen Kleene", "funzioni ricorsive", "1935"), ("Alan Turing", "macchina di Turing", "1936")).map(((chi, cosa, anno)) =>
    box(stroke: 0.6pt, inset: 8pt, width: 4.4cm, fill: rgb("#eef4ff"), radius: 4pt, align(center)[*#cosa* \ #text(9pt)[#chi, #anno]]))))

Com'è fatta la *macchina di Turing*:

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

I tre formalismi, anche se sono fatti in modo diversissimo, calcolano esattamente le stesse funzioni. Da qui la *tesi di Church-Turing*. Nella figura, i modelli meno potenti sono quelli che calcolano solo *funzioni totali* (danno sempre un risultato, per ogni input) e, ancora più dentro, le espressioni regolari:

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

Dai due modelli, Turing e Church, nascono due famiglie di linguaggi. Da Turing vengono i linguaggi *imperativi*, passando per la macchina di von Neumann:

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

  La generalità viene dal *programma memorizzato*: il programma sta in memoria come un dato qualsiasi, quindi la stessa macchina esegue qualunque programma basta caricarlo.
])

Un linguaggio "alla von Neumann" riproduce ad alto livello questa struttura:

#align(center, table(columns: 3, align: (right, center, left),
  [Nel linguaggio], [], [Nella macchina],
  [variabili], [↔], [celle di memoria (il nastro)],
  [istruzioni di controllo (if, cicli)], [↔], [test & jump (controllo una condizione e salto)],
  [assegnamento], [↔], [modifica dello stato (leggo e scrivo la memoria)],
))

*Backus*: l'assegnamento divide la programmazione in due mondi.
#align(center, grid(columns: 2, gutter: 1em,
  box(stroke: 0.6pt + verde, inset: 8pt, width: 6.5cm)[*espressioni* \ #text(9pt)[spazio matematico ordinato, con proprietà algebriche utili. Lì avviene la maggior parte del calcolo]],
  box(stroke: 0.6pt + red, inset: 8pt, width: 6.5cm)[*istruzioni* \ #text(9pt)[spazio disordinato, con poche proprietà utili. La programmazione strutturata prova a metterci un po' d'ordine]],
))

Da Church vengono invece i linguaggi *funzionali*.

*Programmazione funzionale*: il programma è una serie di *valutazioni di funzioni matematiche*. Punto di forza: niente *effetti collaterali*. Una funzione ha un effetto collaterale quando, oltre a restituire un valore, cambia qualcosa fuori da sé (una variabile globale, un file, lo schermo). Senza effetti collaterali una funzione con lo stesso input dà sempre lo stesso output, quindi è più facile verificare che il programma sia corretto e ottimizzarlo. Il λ-calcolo (Church, 1935) è il primo linguaggio funzionale.

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

== Sintassi dei λ-termini

Il λ-calcolo ha solo due operazioni. La prima è l'*astrazione*, cioè definire una funzione:

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

La *legge di corrispondenza* dice cosa fa la funzione su ogni input: qui $forall x. f(x) = x$, cioè a ogni $x$ associa $x$ stesso. È la *funzione identità*.

La seconda è l'*applicazione*. Applicare una funzione = darle un *parametro attuale* al posto del parametro formale. Immagina la funzione come una scatola:

#align(center, grid(columns: (auto, auto), gutter: 1.2em, align: (right + horizon, left + horizon),
  scatola($z$, $lambda x. x$, $z$), [*identità*: restituisce l'input così com'è],
  scatola($z$, $lambda x. y$, $y$), [*costante*: restituisce sempre $y$ #h(0.3em) ($forall x. f(x) = y$)],
  scatola($z, w$, $lambda x. lambda y. x$, $z$), [*selezione*: prende due argomenti e restituisce il primo],
))

La selezione passo per passo: $((lambda x. lambda y. x) z) w arrow.r (lambda y. z) w arrow.r z$. Nel primo passo metto $z$ al posto di $x$ nel corpo $lambda y. x$; nel secondo metto $w$ al posto di $y$ nel corpo $z$, ma $y$ non c'è, quindi $w$ sparisce e resta $z$.

#nota[$lambda x. lambda y. x$ ha legge di corrispondenza $forall x. f(x) = g$ dove $g(y) = x$: una funzione che restituisce una funzione. È un modo alternativo di scrivere $f(x, y) = x$ con una funzione di un solo argomento.]

Queste due operazioni, più le variabili, sono tutto il linguaggio. Un programma è un'espressione (*λ-espressione*). Ci sono solo tre modi di costruirla:

#align(center, box(stroke: 1pt + blu, inset: 12pt, radius: 4pt, grid(columns: 2, align: left, inset: 5pt,
  [$e ::= x$], [variabile],
  [$quad | space lambda x. e$], [astrazione funzionale (dichiarazione di funzione)],
  [$quad | space e space e$], [applicazione (chiamata di funzione)],
)))
#align(center, text(fill: red, weight: "bold")[Niente altro! La sintassi è finita.])

Si legge: un'espressione $e$ è una variabile, *oppure* ($|$) un'astrazione, *oppure* un'applicazione. La definizione è *ricorsiva*: dentro $lambda x. e$ e dentro $e space e$ ci sono altre espressioni, costruite con le stesse tre regole. Per esempio $(lambda x. x) y$ è un'applicazione di $lambda x. x$ (astrazione, con corpo la variabile $x$) alla variabile $y$.

$lambda x. e$ è una *funzione anonima*: non ha nome, e $x$ è la dichiarazione del suo parametro. Lo stesso concetto nei linguaggi:

#align(center, block(breakable: false, table(columns: 2,
  [Linguaggio], [$x mapsto x + 1$],
  [JavaScript], [`function(a){ return a + 1; }` oppure `a => a+1`],
  [OCaml], [`fun x -> x+1`],
  [Java (si chiamano lambda)], [`(int x) -> x + 1`],
)))

Da qui in poi useremo lettere come $e$, $e_1$, $e_2$, $e_3$. *Non* sono variabili del λ-calcolo: sono nomi che stanno per *un'espressione qualsiasi*, come in algebra $a + b$ vale per due numeri qualsiasi. Così una regola scritta con $e_1$ ed $e_2$ vale per tutte le espressioni.

Per esempio $e_1 e_2$ vuol dire "un'espressione seguita da un'altra", cioè un'*applicazione*: $e_1$ è la funzione che chiamo, $e_2$ è l'argomento che le passo (il parametro attuale). In JavaScript si scriverebbe `e1(e2)`. La funzione non deve per forza avere un nome: la sua definizione può stare *direttamente dentro* la chiamata.

$ underbrace((lambda x. (lambda y. x y)), e_1 = "la funzione") space underbrace((lambda z. z), e_2 = "l'argomento") $

Se si scrive tutto senza parentesi, però, non si capisce cosa va con cosa. $lambda x. x y$ è la funzione $lambda x. (x y)$ (prende $x$ e restituisce $x$ applicata a $y$) oppure $(lambda x. x) y$ (l'identità applicata a $y$)? Per decidere, e per non scrivere troppe parentesi, valgono due convenzioni (importanti):

#grid(columns: 2, gutter: 1em,
  box(stroke: 0.6pt, inset: 8pt, width: 100%, fill: rgb("#fff3c4"))[
    *1. Lo scope di $lambda$ va il più a destra possibile* \
    Il corpo di una $lambda$ è *tutto* quello che c'è dopo il punto, fino alla fine (o fino a una parentesi chiusa). \
    $lambda x. x y$ #h(0.3em) è #h(0.3em) $lambda x. (x y)$ \
    $lambda x. lambda y. x y$ #h(0.3em) è #h(0.3em) $lambda x. (lambda y. (x y))$],
  box(stroke: 0.6pt, inset: 8pt, width: 100%, fill: rgb("#fff3c4"))[
    *2. L'applicazione associa a sinistra* \
    Con più applicazioni di fila si parte da sinistra: prima $e_1$ applicata a $e_2$, poi il risultato applicato a $e_3$. Come `f(a)(b)` in JavaScript. \
    $e_1 e_2 e_3$ #h(0.3em) è #h(0.3em) $(e_1 e_2) e_3$],
)

La selezione vista sopra ne è un esempio: $(lambda x. lambda y. x) z w$ è $((lambda x. lambda y. x) z) w$, cioè prima passo $z$, poi $w$.

*Esercizio*: quali parentesi sono sottintese in $lambda x. x lambda y. x y z$?
+ Regola 1. Il corpo di $lambda x$ è tutto il resto, $x lambda y. x y z$; dentro, il corpo di $lambda y$ è $x y z$: #h(0.3em) $lambda x. (x lambda y. (x y z))$
+ Regola 2. $x y z$ diventa $(x y) z$; e $x lambda y. dots$ è $x$ applicata alla funzione $lambda y. dots$: #h(0.3em) $lambda x. (x (lambda y. ((x y) z)))$

Ogni termine si può disegnare come un *albero*, che segue l'annidamento completo delle parentesi. Serve a vedere quali passi di valutazione si possono fare. Nodo $lambda$: figlio sinistro il parametro, destro il corpo. Nodo \@ (applicazione): figli funzione e argomento.

#align(center, grid(columns: 3, gutter: 2.5em, align: bottom,
  [#albero(([$lambda$], [$x$], [$x$])) #align(center, text(9pt)[$lambda x. x$])],
  [#albero(([\@], ([$lambda$], [$x$], [$x$]), [$y$])) #align(center, text(9pt)[$(lambda x. x) y arrow.r y$])],
  [#albero(([$lambda$], [$x$], ([\@], [$x$], ([$lambda$], [$y$], ([\@], ([\@], [$x$], [$y$]), [$z$]))))) #align(center, text(9pt)[$lambda x. (x (lambda y. ((x y) z)))$])],
))

== Variabili libere e legate

$lambda$ è un *operatore di binding*: in $lambda x. e$ lega la $x$ dentro $e$ (il suo *scope*), come $forall x$ in $forall x. P$ nella logica. È l'*unico* modo di associare valori a variabili nel λ-calcolo.

- *Legata*: introdotta da un $lambda$ che la contiene. #text(fill: verde)[*verde*], la freccia punta al suo $lambda$.
- *Libera*: nessun $lambda$ la dichiara. #text(fill: red)[*rossa*].

#align(center, block(breakable: false, table(columns: (auto, 1fr), align: (center + horizon, left + horizon), inset: 8pt,
  [Espressione], [Chi è legato],
  legami(("λ", "x", ".", "x"), ((1, 3),)), [$x$ legata],
  legami(("λ", "x", ".", "λ", "y", ".", "(", "x", "y", "z", ")"), ((1, 7), (4, 8)), libere: (9,)), [$x$ e $y$ legate, $z$ libera],
  legami(("(", "λ", "f", ".", "f", "x", ")", "y"), ((2, 4),), libere: (5, 7)), [$f$ legata, $x$ e $y$ libere],
  legami(("(", "λ", "f", ".", "f", "x", ")", "f"), ((2, 4),), libere: (5, 7)), [la prima $f$ è legata; $x$ e *la seconda $f$ sono libere*: sta fuori dalle parentesi, fuori dallo scope di $lambda f$],
)))

Una stessa variabile può voler dire cose diverse in punti diversi:

#align(center, legami(("λ", "x", ".", "x", "(", "λ", "x", ".", "x", ")", "x"), ((1, 3), (6, 8), (1, 10))))

#align(center)[che con le parentesi esplicite è $lambda x. (x (lambda x. x) x)$]

La $x$ nel $lambda x$ interno è legata a *quel* $lambda$, non a quello esterno. Tre $x$, due significati: da qui nasce il conflitto di nomi.

Ecco il problema che questo crea. Applicando senza fare attenzione ai nomi:

#align(center, block(breakable: false, table(columns: 3, align: left,
  [], [Espressione], [Risultato],
  [ingenuo], [$(lambda x. lambda y. x y) y$], [$lambda y. y y$ #h(0.5em) #text(fill: red)[✗ sbagliato]],
  [rinomino $y$ in $z$], [$(lambda x. lambda z. x z) y$], [$lambda z. y z$ #h(0.5em) #text(fill: verde)[✓]],
)))

Le due espressioni di partenza sono *la stessa funzione* (ho solo cambiato il nome del parametro), ma i risultati si comportano in modo diverso. Nel primo caso la $y$ libera che passo come argomento finisce *catturata* dal $lambda y$ interno: è un *conflitto di nomi*.

$x$ in $lambda x. e$ è un segnaposto: si può rinominare con una variabile *fresca*, cioè un nome che non compare da nessuna parte nelle espressioni che stiamo trattando. È così che si risolve il conflitto di nomi, come nella riga «rinomino» della tabella.

Le variabili libere si possono definire in modo preciso, con una *definizione induttiva*: un caso per ogni elemento della sintassi.

#align(center, box(stroke: 1pt + verde, inset: 12pt, radius: 4pt, grid(columns: 2, align: left, column-gutter: 2em, row-gutter: 0.7em,
  [$"FV"(x) = {x}$], text(9pt)[variabile],
  [$"FV"(e_1 e_2) = "FV"(e_1) union "FV"(e_2)$], text(9pt)[applicazione: le libere di tutte e due],
  [$"FV"(lambda x. e) = "FV"(e) without {x}$], text(9pt)[astrazione: il $lambda$ lega $x$, la tolgo],
)))

FV sta per _Free Variables_. Una variabile che non è libera è *legata* (_bound_). Un termine senza variabili libere ($"FV"(e) = emptyset$) si dice *chiuso*; i termini chiusi si chiamano *combinatori*, il più semplice è l'identità $lambda x. x$.

*Esercizio*: $"FV"((lambda x. lambda y. x y)((lambda z. z) k))$
$ = "FV"(lambda x. lambda y. x y) union "FV"((lambda z. z) k) = emptyset union {k} = {k} $

Visto che un parametro è solo un segnaposto, cambiargli nome non cambia niente. $lambda a. a c$ e $lambda b. b c$ si dicono *α-equivalenti*: $a$ e $b$ non hanno un significato proprio, conta solo il *ruolo* che hanno nell'espressione. Lo stesso vale nei linguaggi:

#align(center, grid(columns: 3, gutter: 1.5em, align: horizon,
  `function(a){ return a + 1; }`, [è α-equivalente a], `function(b){ return b + 1; }`,
))

Espressioni α-equivalenti rappresentano *lo stesso programma*. Rinominare una variabile legata con una variabile fresca (che non compare nell'espressione) si chiama *α-conversione*. Serve a passare da $lambda x. x$ a $lambda z. z$, e soprattutto a togliere il conflitto di nomi visto sopra (_variable shadowing_):

#align(center, grid(columns: 3, gutter: 1.5em, align: horizon,
  legami(("λ", "x", ".", "x", "(", "λ", "x", ".", "x", ")", "x"), ((1, 3), (6, 8), (1, 10))),
  [$attach(arrow.r, t: alpha)$],
  legami(("λ", "x", ".", "x", "(", "λ", "z", ".", "z", ")", "x"), ((1, 3), (6, 8), (1, 10))),
))
#align(center, text(9pt)[i due termini sono equivalenti a meno di α-conversione, ma nel secondo ogni nome ha un solo significato])

== Sostituzione e β-riduzione

Cosa vuol dire *eseguire* (valutare) una λ-espressione? La valutazione, _eval_, fa solo una cosa: *chiamare funzioni*.

#align(center, box(stroke: 1pt + blu, inset: 10pt, radius: 4pt)[
  $"eval"((lambda x. e_1) e_2)$: #h(0.5em) rimpiazzo ogni occorrenza di $x$ in $e_1$ con $e_2$, poi valuto il termine che ne risulta.
])

È la chiamata di una funzione: eseguo il corpo $e_1$ dopo aver messo il *parametro attuale* $e_2$ al posto del *parametro formale* $x$.

La *sostituzione* si scrive $e_1 {x := e_2}$ (oppure $e_1 {e_2 slash x}$): è $e_1$ con ogni occorrenza *libera* di $x$ sostituita da $e_2$. Per esempio $x z {x := lambda y. y} = (lambda y. y) z$.

Il problema: e se $e_2$ contiene una variabile libera che in $e_1$ è legata? Sostituendo alla cieca finisce *catturata* dal $lambda$ di $e_1$, e legare una variabile libera cambia il significato. Esempio con le operazioni aritmetiche, per semplicità: $(lambda x. (x * y)) {y := (x + x)}$.

#align(center, table(columns: 2, align: left,
  [Come], [Risultato],
  [alla cieca], [$lambda x. (x * (x + x))$ #h(0.5em) #text(fill: red)[✗ le $x$ di $x + x$ ora sono il parametro]],
  [α-conversione, $z$ fresca], [$(lambda z. (z * y)) {y := (x + x)} = lambda z. (z * (x + x))$ #h(0.5em) #text(fill: verde)[✓]],
))

La soluzione è la *sostituzione che evita la cattura* (_capture-avoiding substitution_): prima di sostituire, se serve, rinomino con l'α-conversione. La definizione ha un caso per ogni elemento della sintassi:

#block(breakable: false, table(columns: (auto, auto, 1fr), align: (left, left, left), inset: 7pt,
  [], [Regola], [Perché],
  table.cell(rowspan: 2, fill: rgb("#eef4ff"))[variabile], [$x {x := e} equiv e$], [è proprio la variabile da sostituire],
  [$y {x := e} equiv y$ #h(0.5em) se $x != y$], [un'altra variabile non si tocca],
  table.cell(fill: rgb("#eef4ff"))[applicazione], [$(e_1 e_2){x := e} equiv (e_1 {x := e})(e_2 {x := e})$], [sostituisco da tutte e due le parti],
  table.cell(rowspan: 3, fill: rgb("#eef4ff"))[astrazione], [$(lambda x. e_1){x := e} equiv lambda x. e_1$], [qui $x$ è legata: la sostituzione vale solo per le variabili libere, quindi non cambia niente],
  [$(lambda y. e_1){x := e} equiv lambda y. (e_1 {x := e})$ \ se $y != x$ e $y in.not "FV"(e)$], [in $e$ non compare $y$: nessun rischio di conflitto],
  [$(lambda y. e_1){x := e} equiv lambda z. ((e_1 {y := z}){x := e})$ \ se $y != x$ e $y in "FV"(e)$, $z$ fresca], [la $y$ libera di $e$ verrebbe catturata: prima α-converto $y$ in $z$, poi sostituisco],
))

#block(sticky: true)["Fresca" qui vuol dire che non compare né in $e_1$ né in $e$. L'ultimo caso, disegnato: sostituire $x$ con $y$ nel corpo di $lambda x. lambda y. x y$.]

#align(center, grid(columns: 2, gutter: 4em, align: center + bottom,
  [#legami(("λ", "y", ".", "y", "y"), ((1, 3), (1, 4))) \ #text(9pt)[alla cieca: la $y$ arriva in un mondo dove esiste \ già una $y$ legata e diventa indistinguibile da lei #text(fill: red)[✗]]],
  [#legami(("λ", "z", ".", "y", "z"), ((1, 4),), libere: (3,)) \ #text(9pt)[prima rinomino $y$ in $z$: \ ora la $y$ resta libera #text(fill: verde)[✓]]],
))

Un esempio completo: $(lambda x. lambda y. ((lambda z. z) x)) y$. Il passo $(lambda y. ((lambda z. z) x)){x := y}$ fatto alla cieca *non va bene*: le due $y$ sono diverse ($y in "FV"(e)$). Quindi, con $k$ fresca:

$ (lambda y. ((lambda z. z) x)){x := y} = (lambda k. ((lambda z. z) x)){x := y} = lambda k. ((lambda z. z) y) $

*Esercizi*. L'espressione è sempre la stessa, cambia la variabile da sostituire ($attach(equiv, br: alpha)$ vuol dire "α-equivalente", cioè uguale a meno di rinominare):

#table(columns: (auto, 1fr), align: left,
  [Sostituzione], [Risultato],
  [$((lambda x. y x) w){x := lambda k. k x}$], [$(lambda x. y x) w$ #h(0.5em) #text(9pt)[l'unica $x$ è legata: $(lambda x. e_1){x := e} equiv lambda x. e_1$]],
  [$((lambda x. y x) w){y := lambda k. k x}$], [$attach(equiv, br: alpha) ((lambda z. y z) w){y := lambda k. k x} = (lambda z. (lambda k. k x) z) w$ \ #text(9pt)[la $x$ di $lambda k. k x$ è libera e verrebbe catturata da $lambda x$: rinomino]],
  [$((lambda x. y x) w){w := lambda k. k x}$], [$(lambda x. y x)(lambda k. k x)$ #h(0.5em) #text(9pt)[$w$ non è sotto nessun $lambda$: caso applicazione]],
)

Con la sostituzione si scrive la regola fondamentale del λ-calcolo, quella che lo rende un modello di calcolo universale, la *β-riduzione*:

#align(center, box(stroke: 1.5pt + red, inset: 12pt, radius: 4pt, text(14pt)[$(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$]))

- Cattura esattamente l'*applicazione di funzione*: $(lambda x. x) 3 arrow.r 3$.
- Il risultato è il corpo $e_1$ in cui il parametro formale $x$ è sostituito da copie dell'argomento $e_2$.
- Un *redex* (espressione riducibile) è una sottoespressione della forma $(lambda x. e_1) e_2$, a cui la regola si può applicare.

Esempio: $(lambda x. lambda z. x z) y$. Il parametro formale è $x$, il corpo è $e_1 = lambda z. x z$, il parametro attuale è $e_2 = y$:

#align(center, grid(columns: 3, gutter: 2em, align: horizon,
  albero(([\@], ([$lambda$], [$x$], ([$lambda$], [$z$], ([\@], [$x$], [$z$]))), [$y$])),
  [$arrow.r$ \ #text(9pt)[$e_1 {x := y}$]],
  albero(([$lambda$], [$z$], ([\@], [$y$], [$z$]))),
))
#align(center)[$(lambda x. lambda z. x z) y arrow.r lambda z. y z$]

Il λ-calcolo è di *ordine superiore*: una funzione può prendere funzioni come parametri e restituire funzioni come risultato, in modo naturale.

#block(breakable: false, width: 100%, table(columns: (auto, 1fr), align: (left, left),
  [Espressione], [Cosa fa],
  [$lambda x. x$], [identità],
  [$lambda y. (lambda x. x)$], [scarta l'argomento $y$ e restituisce l'identità: è una *funzione costante*],
  [$lambda f. f (lambda x. x)$], [data una funzione $f$, la *invoca sull'identità*],
))

#block(breakable: false, width: 100%, table(columns: (auto, 1fr), align: (left, left),
  [Applicazione], [Passi],
  [$(lambda x. x) y$], [$arrow.r y$],
  [$(lambda x. x) (lambda y. y)$], [$arrow.r lambda y. y$ #h(1em) #text(9pt)[l'identità applicata all'identità]],
  [$(lambda x. x y) z$], [$arrow.r z y$ #h(1em) #text(9pt)[prende una funzione $z$ e la applica a $y$]],
  [$(lambda x. x y)(lambda z. z)$], [$arrow.r (lambda z. z) y arrow.r y$ #h(1em) #text(9pt)[il parametro attuale è l'identità]],
  [$(lambda x. ((lambda y. y) x)) z$], [$arrow.r (lambda y. y) z arrow.r z$],
  [$(lambda f. f z)(lambda x. x)$], [$arrow.r (lambda x. x) z arrow.r z$ #h(1em) #text(9pt)[prende una funzione e la applica a $z$]],
  [$(lambda x. (x x))(lambda y. y)$], [$arrow.r (lambda y. y)(lambda y. y) arrow.r lambda y. y$ #h(1em) #text(9pt)[due termini uguali con ruoli diversi: funzione e argomento]],
  [$((lambda x. lambda y. x + y) 3) 5$], [$arrow.r (lambda y. 3 + y) 5 arrow.r 3 + 5 arrow.r 8$ #h(1em) #text(9pt)[(supponendo di avere il +)]],
  [$((lambda x. lambda y. x y)(lambda x. x)) z$], [$arrow.r (lambda y. (lambda x. x) y) z arrow.r (lambda x. x) z arrow.r z$ #h(1em) #text(9pt)[forma $e_1 e_2 e_3$]],
  [$(lambda x. lambda y. x y) z k$], [$arrow.r (lambda y. z y) k arrow.r z k$],
))

#nota[$(lambda y. 3 + y)$ è una funzione a sé: somma 3 a quello che le passi. Applicando una funzione di due argomenti a uno solo ottieni una funzione che aspetta l'altro.]

La valutazione va avanti scegliendo un redex e riducendolo. Quando non ci sono più redex l'espressione è in *forma normale β*: non si può più riscrivere con la β-riduzione, ed è il *risultato finale*, il *valore calcolato*. Per esempio $lambda x. x$ e $lambda t. lambda f. t$ sono valori: *le funzioni sono valori*.

#align(center, table(columns: 2, align: left,
  [Notazione], [Significato],
  [$e_1 arrow.r e_2$], [$e_2$ si ottiene da $e_1$ con *un* passo di riduzione],
  [$e_1 arrow.r.double e_2$], [$e_2$ si ottiene da $e_1$ con *zero o più* passi],
))

Un passo di β-riduzione è un passo di calcolo, quindi $arrow.r.double$ (la *chiusura riflessiva e transitiva* di $arrow.r$) rappresenta una computazione qualsiasi. Quando $e_1 arrow.r.double e_2$ si dice che $e_1$ è *β-riducibile* a $e_2$.

Con $arrow.r.double$ si definisce quando due espressioni sono "uguali". $e_1$ ed $e_2$ sono *β-equivalenti*, $e_1 attach(equiv, br: beta) e_2$, se:
+ sono identiche a meno di α-conversione, oppure
+ $e_1 arrow.r.double e_2$ oppure $e_2 arrow.r.double e_1$, oppure
+ $e_1 arrow.r.double e$ e anche $e_2 arrow.r.double e$ (arrivano alla stessa espressione).

#align(center, canvas(length: 1cm, {
  import draw: *
  content((0, 0), [$(lambda x. x) z$]); content((6, 0), [$(lambda x. lambda y. x) z w$])
  content((6, -1.2), [$(lambda y. z) w$])
  content((3, -2.4), box(stroke: 1pt + verde, inset: 5pt)[$z$])
  line((0.3, -0.3), (2.6, -2.1), mark: (end: "stealth"))
  line((6, -0.3), (6, -0.9), mark: (end: "stealth"))
  line((5.7, -1.5), (3.4, -2.2), mark: (end: "stealth"))
  content((3, 0), text(fill: verde)[$attach(equiv, br: beta)$])
}))
#align(center, text(9pt)[β-equivalenti per il terzo caso: tutte e due si riducono a $z$])

*Intuizione*: due espressioni sono β-equivalenti quando sono indistinguibili dal punto di vista del calcolo, cioè calcolano gli stessi risultati.

== Confluenza e non terminazione

Quando un'espressione contiene più redex, si può scegliere da quale cominciare. In $(lambda x. x)((lambda y. y) z)$ ce ne sono due:

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

Ma in generale l'ordine di valutazione può cambiare il risultato finale? Un altro esempio (usando il $+$):

#figura(canvas(length: 1cm, {
  import draw: *
  content((0, 0), box(stroke: 0.6pt, inset: 6pt)[$(lambda x. x + x)((lambda y. y) 5)$])
  content((-3.3, -1.8), box(stroke: 0.6pt, inset: 6pt)[$(lambda y. y) 5 + (lambda y. y) 5$])
  content((3.3, -1.8), box(stroke: 0.6pt, inset: 6pt)[$(lambda x. x + x) 5$])
  content((0, -3.3), box(stroke: 0.6pt, inset: 6pt)[$5 + 5$])
  content((0, -4.6), box(stroke: 1pt + verde, inset: 6pt)[$10$])
  line((-0.8, -0.35), (-2.6, -1.45), mark: (end: "stealth")); content((-2.6, -0.6), text(8pt)[redex esterno])
  line((0.8, -0.35), (2.6, -1.45), mark: (end: "stealth")); content((2.6, -0.6), text(8pt)[redex interno])
  line((-2.8, -2.15), (-0.5, -3), mark: (end: "stealth")); content((-2.4, -2.8), text(8pt)[due passi])
  line((2.8, -2.15), (0.5, -3), mark: (end: "stealth"))
  line((0, -3.65), (0, -4.25), mark: (end: "stealth"))
}), [Scegliendo prima il redex esterno si copia $(lambda y. y) 5$ e lo si riduce due volte; prima quello interno, una volta sola. Il risultato è lo stesso])

La risposta generale è il *teorema di Church-Rosser*: l'ordine in cui si scelgono le β-riduzioni *non influisce sul risultato finale*. Più precisamente: se a una stessa espressione si possono applicare due riduzioni (o sequenze di riduzioni) diverse, esiste un'espressione raggiungibile da entrambi i risultati con altre riduzioni (anche nessuna).

#grid(columns: (auto, 1fr), gutter: 2em, align: horizon,
figura(canvas(length: 1cm, {
  import draw: *
  content((0, 0), [$e$]); content((-1.3, -1.3), [$e_1$]); content((1.3, -1.3), [$e_2$]); content((0, -2.6), [$e'$])
  line((-0.2, -0.2), (-1.1, -1.1), stroke: 1.2pt + blu, mark: (end: "stealth"))
  line((0.2, -0.2), (1.1, -1.1), stroke: 1.2pt + blu, mark: (end: "stealth"))
  line((-1.1, -1.5), (-0.2, -2.4), stroke: (paint: red, dash: "dashed", thickness: 1.2pt), mark: (end: "stealth"))
  line((1.1, -1.5), (0.2, -2.4), stroke: (paint: red, dash: "dashed", thickness: 1.2pt), mark: (end: "stealth"))
}), [Proprietà di confluenza \ (o del diamante)]),
[Come due strade diverse fra le vie di una città che partono dallo stesso punto $e$: qualunque giro si faccia, ci si può sempre ritrovare nello stesso punto $e'$.

Per questo nell'esempio sopra entrambe le strade arrivano a $10$.])

Non sempre però si arriva a una forma normale. Il combinatore

$ Omega = (lambda x. x x)(lambda x. x x) $

contiene un solo redex, e ridurlo dà di nuovo $Omega$: la funzione $lambda x. x x$ applica il suo argomento a se stesso, e l'argomento è proprio $lambda x. x x$.

#align(center, canvas(length: 1cm, {
  import draw: *
  content((0, 0), [$(lambda x. x x)(lambda x. x x)$])
  line((1.9, 0), (3, 0), mark: (end: "stealth")); content((2.45, 0.3), text(8pt)[$beta$])
  content((4.9, 0), [$(lambda x. x x)(lambda x. x x)$])
  line((6.8, 0), (7.9, 0), mark: (end: "stealth")); content((8.4, 0), [$dots.c$])
  bezier((4.9, -0.35), (0, -0.35), (2.45, -1.4), stroke: (paint: red, dash: "dashed"), mark: (end: "stealth"))
  content((2.45, -1.2), text(9pt, fill: red)[*loop!* è di nuovo $Omega$])
}))

$Omega$ non si può ridurre in forma normale: è un combinatore *divergente*, l'equivalente di un ciclo infinito.

Una stessa espressione può *terminare* facendo certe scelte di riduzione e *non terminare* facendone altre. Per esempio $(lambda x. y) Omega$:

#figura(canvas(length: 1cm, {
  import draw: *
  for k in range(4) {
    content((k * 2.6, 0), [$(lambda x. y) Omega$])
    line((k * 2.6 + 0.8, 0), (k * 2.6 + 1.7, 0), mark: (end: "stealth"))
    line((k * 2.6 + 0.3, 0.3), (k * 2.6 + 0.9, 1), stroke: verde, mark: (end: "stealth"))
    content((k * 2.6 + 1.1, 1.25), text(fill: verde)[$y$])
  }
  content((10.6, 0), [$dots.c$])
}), [In orizzontale riduco dentro $Omega$ e resto sempre fermo; in qualunque momento posso invece applicare $lambda x. y$, che butta via l'argomento e dà $y$])

Church-Rosser garantisce che *in tutti i casi in cui la riduzione termina, il risultato è lo stesso*: non possono esserci risultati diversi.
