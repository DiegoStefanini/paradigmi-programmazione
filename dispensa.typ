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
// nomi di più lettere usabili nelle formule
#let (TRUE, FALSE, NOT, IF, SUCC, PLUS, TIMES, ISZERO, Twice, Comp, iff, thn, els) = ("TRUE", "FALSE", "NOT", "IF", "SUCC", "PLUS", "TIMES", "ISZERO", "Twice", "Comp", "if", "then", "else").map(math.op)
// regola di inferenza: sopra la riga l'ipotesi, sotto la conclusione
#let regola(sopra, sotto) = $display(frac(sopra, sotto))$
// riquadro con un insieme di regole
#let regole(titolo, colore, ..r) = box(stroke: 1pt + colore, inset: 9pt, radius: 4pt, width: 100%, align(center)[
  #text(fill: colore, weight: "bold", titolo) #v(0.2em)
  #r.pos().join(v(0.5em))])
// corpo del numerale di Church n: s applicata n volte a z
#let church(n) = if n == 0 { $z$ } else if n == 1 { $s z$ } else { $s (#church(n - 1))$ }
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

Queste due operazioni, più le variabili, sono tutto il linguaggio. Un programma è un'espressione (*λ-espressione*). Ci sono solo tre modi di costruirla:

#align(center, box(stroke: 1pt + blu, inset: 12pt, radius: 4pt, grid(columns: 2, align: left, inset: 5pt,
  [$e ::= x$], [variabile],
  [$quad | space lambda x. e$], [astrazione funzionale (dichiarazione di funzione)],
  [$quad | space e space e$], [applicazione (chiamata di funzione)],
)))

Si legge: un'espressione $e$ è una variabile, *oppure* ($|$) un'astrazione, *oppure* un'applicazione. La definizione è *ricorsiva*: dentro $lambda x. e$ e dentro $e space e$ ci sono altre espressioni, costruite con le stesse tre regole. Per esempio $(lambda x. x) y$ è un'applicazione di $lambda x. x$ (astrazione, con corpo la variabile $x$) alla variabile $y$.

$lambda x. e$ è una *funzione anonima*: non ha nome, e $x$ è la dichiarazione del suo parametro. Lo stesso concetto nei linguaggi:

#align(center, block(breakable: false, table(columns: 2,
  [Linguaggio], [$x mapsto x + 1$],
  [JavaScript], [`function(a){ return a + 1; }` oppure `a => a+1`],
  [OCaml], [`fun x -> x+1`],
  [Java (si chiamano lambda)], [`(int x) -> x + 1`],
)))

Da qui in poi useremo lettere come $e$, $e_1$, $e_2$, $e_3$. *Non* sono variabili del λ-calcolo: sono nomi che stanno per *un'espressione qualsiasi*, come in algebra $a + b$ vale per due numeri qualsiasi.

In $e_1 e_2$, $e_1$ è la funzione che chiamo ed $e_2$ l'argomento che le passo (in JavaScript `e1(e2)`). La funzione non deve per forza avere un nome: la sua definizione può stare *direttamente dentro* la chiamata.

$ underbrace((lambda x. (lambda y. x y)), e_1 = "la funzione") space underbrace((lambda z. z), e_2 = "l'argomento") $

Senza parentesi $lambda x. x y$ è ambiguo: è $lambda x. (x y)$ (prende $x$ e restituisce $x$ applicata a $y$) oppure $(lambda x. x) y$ (l'identità applicata a $y$)? Decidono due convenzioni (importanti), che servono anche a scrivere meno parentesi:

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

Applicando senza fare attenzione ai nomi nasce un problema:

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

Cambiare nome a un parametro non cambia niente: $lambda a. a c$ e $lambda b. b c$ si dicono *α-equivalenti*, perché $a$ e $b$ contano solo per il *ruolo* che hanno nell'espressione. Lo stesso vale nei linguaggi:

#align(center, grid(columns: 3, gutter: 1.5em, align: horizon,
  `function(a){ return a + 1; }`, [è α-equivalente a], `function(b){ return b + 1; }`,
))

Espressioni α-equivalenti rappresentano *lo stesso programma*. Rinominare una variabile legata con una variabile fresca si chiama *α-conversione*. Serve a passare da $lambda x. x$ a $lambda z. z$, e soprattutto a togliere il conflitto di nomi visto sopra (_variable shadowing_):

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

$ (lambda y. ((lambda z. z) x)){x := y} attach(equiv, br: alpha) (lambda k. ((lambda z. z) x)){x := y} = lambda k. ((lambda z. z) y) $

*Esercizi*. L'espressione è sempre la stessa, cambia la variabile da sostituire ($attach(equiv, br: alpha)$ vuol dire "α-equivalente", cioè uguale a meno di rinominare):

#table(columns: (auto, 1fr), align: left,
  [Sostituzione], [Risultato],
  [$((lambda x. y x) w){x := lambda k. k x}$], [$(lambda x. y x) w$ #h(0.5em) #text(9pt)[l'unica $x$ è legata: $(lambda x. e_1){x := e} equiv lambda x. e_1$]],
  [$((lambda x. y x) w){y := lambda k. k x}$], [$attach(equiv, br: alpha) ((lambda z. y z) w){y := lambda k. k x} = (lambda z. (lambda k. k x) z) w$ \ #text(9pt)[la $x$ di $lambda k. k x$ è libera e verrebbe catturata da $lambda x$: rinomino]],
  [$((lambda x. y x) w){w := lambda k. k x}$], [$(lambda x. y x)(lambda k. k x)$ #h(0.5em) #text(9pt)[$w$ non è sotto nessun $lambda$: caso applicazione]],
)

Con la sostituzione si scrive la regola fondamentale del λ-calcolo, la *β-riduzione*:

#align(center, box(stroke: 1.5pt + red, inset: 12pt, radius: 4pt, text(14pt)[$(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$]))

- Cattura esattamente l'*applicazione di funzione*: $(lambda x. x) 3 arrow.r 3$.
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

La valutazione va avanti scegliendo un redex e riducendolo. Quando non ci sono più redex l'espressione è in *forma normale β*: non si può più riscrivere con la β-riduzione, ed è il *risultato finale*, il *valore calcolato*. Per esempio $lambda x. x$ e $lambda t. lambda f. t$ sono valori: *le funzioni sono valori*.

#align(center, table(columns: 2, align: left,
  [Notazione], [Significato],
  [$e_1 arrow.r e_2$], [$e_2$ si ottiene da $e_1$ con *un* passo di riduzione],
  [$e_1 arrow.r.double e_2$], [$e_2$ si ottiene da $e_1$ con *zero o più* passi],
))

Un passo di β-riduzione è un passo di calcolo, quindi $arrow.r.double$ (la *chiusura riflessiva e transitiva* di $arrow.r$) rappresenta una computazione qualsiasi. Quando $e_1 arrow.r.double e_2$ si dice che $e_1$ è *β-riducibile* a $e_2$.

#block(breakable: false)[Con $arrow.r.double$ si definisce quando due espressioni sono "uguali". $e_1$ ed $e_2$ sono *β-equivalenti*, $e_1 attach(equiv, br: beta) e_2$, se:
+ sono identiche a meno di α-conversione, oppure
+ $e_1 arrow.r.double e_2$ oppure $e_2 arrow.r.double e_1$, oppure
+ $e_1 arrow.r.double e$ e anche $e_2 arrow.r.double e$ (arrivano alla stessa espressione).]

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

== Ordine di riduzione e strategie

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
[Per questo nell'esempio sopra entrambe le strade arrivano a $10$.])

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

Le scelte possibili sono di tre tipi. In $(lambda x. ((lambda y. y) x))((lambda z. z) k)$:

#figura(canvas(length: 1cm, {
  import draw: *
  content((0, 0), box(stroke: 0.6pt, inset: 6pt)[$(lambda x. ((lambda y. y) x))((lambda z. z) k)$])
  let rami = ((-5.2, [valuto il corpo], $(lambda x. x)((lambda z. z) k)$, red),
              (0, [non valuto l'argomento], $(lambda y. y)((lambda z. z) k)$, blu),
              (5.2, [valuto l'argomento], $(lambda x. ((lambda y. y) x)) k$, verde))
  for (x, t, e, c) in rami {
    line((x * 0.25, -0.45), (x * 0.85, -1.75), stroke: c, mark: (end: "stealth"))
    content((x, -1.2), box(fill: white, inset: 2pt, text(8pt, fill: c, t)))
    content((x, -2.2), box(stroke: 0.6pt + c, inset: 6pt, e))
    line((x * 0.85, -2.65), (x * 0.12, -3.75), stroke: c, mark: (end: "stealth"))
  }
  content((0, -4.1), box(stroke: 1pt + verde, inset: 6pt)[$k$])
}), [Tre scelte diverse, stesso risultato $k$])

Succede lo stesso in un linguaggio. Con `function f(x) { 3+2 + x }` e la chiamata `f(2+1)` posso calcolare l'argomento prima di passarlo (`f(3)`), passarlo non calcolato e lasciarlo alla funzione (`f(2+1)`), oppure semplificare il corpo (`5 + x`).

Una *strategia di valutazione* fissa quale scelta fare. Valutare un'applicazione $(lambda x. e) e'$ ha tre passi: valuto l'espressione che definisce la funzione, passo il parametro, valuto il corpo. Le due strategie cambiano il secondo passo, il *passaggio dei parametri*:

#align(center, block(breakable: false, table(columns: 3, align: left,
  [], [Call-by-value (CBV), _eager_], [Call-by-name (CBN), _lazy_],
  [Cosa fa con l'argomento $e'$], [lo valuta *prima* della β-riduzione], [fa *subito* la β-riduzione],
  [Al posto di $x$ finisce], [il *valore* dell'argomento], [l'*espressione non valutata*],
  [Redex scelto], [il più interno], [il più esterno],
  [Linguaggi], [OCaml e la maggior parte], [Haskell],
)))

Le strategie si scrivono con *regole*: sopra la riga l'ipotesi, sotto la conclusione. La prima a sinistra dice: se $e_1$ fa un passo e diventa $e'$, allora $e_1 e_2$ diventa $e' e_2$.

#grid(columns: (1.25fr, 1fr, 1fr), gutter: 0.6em,
  regole([Standard (senza strategia)], red,
    $(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$,
    [#regola($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$) #h(0.8em) #regola($e_2 arrow.r e'$, $e_1 e_2 arrow.r e_1 e'$)],
    regola($e arrow.r e'$, $lambda x. e arrow.r lambda x. e'$)),
  regole([Call-by-value], verde,
    $(lambda x. e_1) v_2 arrow.r e_1 {x := v_2}$,
    regola($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$),
    regola($e_2 arrow.r e'$, $v_1 e_2 arrow.r v_1 e'$)),
  regole([Call-by-name], blu,
    $(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$,
    regola($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$)),
)

- *Standard*: qualsiasi redex si può ridurre in qualsiasi momento, anche dentro il corpo di una funzione (terza riga). Non è deterministica.
- *Call-by-value*: $v$ sta per un *valore*, cioè un'espressione già valutata. La β-riduzione scatta solo quando l'argomento è un valore $v_2$; l'argomento $e_2$ si riduce solo quando la funzione è già un valore $v_1$.
- *Call-by-name*: si riduce la parte funzione finché diventa $lambda x. e_1$, poi si applica. L'argomento non si tocca.

#nota[CBV e CBN *non hanno la regola che riduce il corpo di una funzione*. Quindi $lambda x. ((lambda y. y) z)$ con la riduzione standard diventa $lambda x. z$, con le due strategie resta così com'è: per loro una funzione è già un valore, anche se dentro ha un redex. È quello che succede nei linguaggi: il corpo di una funzione non viene eseguito finché la funzione non viene chiamata.]

La stessa espressione con le due strategie (usando numeri e $+$):

#grid(columns: (1fr, 1fr), gutter: 1em,
  box(stroke: 0.6pt + verde, inset: 8pt, width: 100%)[
    #text(fill: verde)[*Call-by-value*: redex più interno] #v(0.1em)
    $&(lambda x. lambda y. y x)(5 + 2)(lambda x. x + 1) \
     arrow.r &(lambda x. lambda y. y x) 7 (lambda x. x + 1) \
     arrow.r &(lambda y. y 7)(lambda x. x + 1) \
     arrow.r &(lambda x. x + 1) 7 \
     arrow.r &7 + 1 arrow.r 8$],
  box(stroke: 0.6pt + blu, inset: 8pt, width: 100%)[
    #text(fill: blu)[*Call-by-name*: redex più esterno] #v(0.1em)
    $&(lambda x. lambda y. y x)(5 + 2)(lambda x. x + 1) \
     arrow.r &(lambda y. y (5 + 2))(lambda x. x + 1) \
     arrow.r &(lambda x. x + 1)(5 + 2) \
     arrow.r &(5 + 2) + 1 \
     arrow.r &7 + 1 arrow.r 8$],
)

Conta quale strategia si sceglie?
- Se la valutazione termina, *no*: per la confluenza il risultato è lo stesso.
- La CBV valuta ogni argomento *una volta sola*. La CBN lo valuta *solo se serve*, ma può valutarlo più volte: è la strada di sinistra nella figura di $(lambda x. x + x)((lambda y. y) 5)$.
- La CBN *termina ogni volta che è possibile*; la CBV può non terminare anche quando la CBN termina. In $(lambda x. y) Omega$ la CBN applica subito $lambda x. y$ e dà $y$; la CBV deve prima valutare l'argomento $Omega$ e non finisce mai. Non contraddice la confluenza, che dice che una strada verso il termine comune *esiste*, non quale strategia la trova.

= Programmare nel lambda calcolo

== Funzioni con più argomenti

Nel λ-calcolo ogni funzione prende *un solo argomento*. Una funzione di due argomenti si scrive come *catena* di funzioni di un argomento, come la selezione $lambda x. lambda y. x$: la prima prende $x$ e restituisce una funzione che prende $y$.

#align(center, box(stroke: 1pt + blu, inset: 10pt, radius: 4pt)[
  $lambda x. (lambda y. x y)$ #h(2em) da #h(0.4em) $f : (X times Y) arrow.r Z$ #h(0.4em) a #h(0.4em) $g : X arrow.r (Y arrow.r Z)$
])

Questa trasformazione si chiama *currying* (dal logico Haskell Curry). $g$ prende un $X$ e restituisce una funzione da $Y$ a $Z$, e calcola gli stessi risultati di $f$:

$ (lambda x. lambda y. x + y) 10 arrow.r lambda y. 10 + y #h(3em) (lambda y. 10 + y) 5 = 15 $

$lambda y. 10 + y$ è una funzione a sé: somma 10 a quello che le passi. Dare a una funzione solo il primo argomento si chiama *applicazione parziale*: ottieni una funzione che aspetta gli altri.

L'espressività non cambia, il risultato è lo stesso che avrei con due parametri insieme:

#align(center, table(columns: 2, align: left,
  [Definizione], [Chiamata],
  [$F = lambda (x, y). e$], [$F(e_1, e_2) arrow.r e {x := e_1}{y := e_2}$],
  [$F = lambda x. lambda y. e$], [$(F e_1) e_2 arrow.r (lambda y. e){x := e_1} e_2 arrow.r e {x := e_1}{y := e_2}$],
))

In JavaScript, `curry` prende una funzione `f` che vuole due argomenti insieme e restituisce una funzione che li prende uno alla volta (nota le funzioni annidate):

#grid(columns: (1fr, 1fr), gutter: 1em,
```js
function curry(f) {
  return function(a) {
    return function(b) {
      return f(a, b);
    };
  };
}
```,
```js
function sum(a, b) { return a + b; }

let curriedSum = curry(sum);
let h = curriedSum(1); // somma sempre 1
alert( h(2) );         // 3
alert( curriedSum(1)(2) ); // 3
```)

`sum` passa da `Int × Int → Int` a `Int → (Int → Int)`. I vantaggi del currying:
- *uniformità*: ogni funzione ha un solo argomento, non serve una regola a parte per più argomenti;
- *applicazione parziale*: funzioni specializzate (come `h`) senza costrutti in più;
- *minimalità*: astrazione e applicazione bastano per funzioni con qualsiasi numero di argomenti.

Tutto questo si regge sull'*ordine superiore* (_higher order_). Altri due esempi: $Twice$ prende una funzione e la applica due volte:

$ Twice = lambda f. lambda x. f (f x) $
$ Twice (lambda y. y + y) 2 arrow.r.double (lambda y. y + y)((lambda y. y + y) 2) arrow.r.double (lambda y. y + y) 4 arrow.r.double 8 $

$Comp$ è la *composizione* $f compose g$: prende due funzioni e ne restituisce una nuova che applica prima $g$ e poi $f$. Ha tipo $(B arrow.r C) times (A arrow.r B) arrow.r (A arrow.r C)$.

#align(center, grid(columns: 2, gutter: 3em, align: horizon,
  $Comp = lambda f. lambda g. lambda x. f (g x)$,
  stack(dir: ltr, spacing: 0.6em,
    ..($x$, [→], box(stroke: 1pt + blu, fill: rgb("#eef4ff"), inset: 8pt, radius: 4pt, $g$), [→], $g x$, [→],
       box(stroke: 1pt + blu, fill: rgb("#eef4ff"), inset: 8pt, radius: 4pt, $f$), [→], $f (g x)$).map(c => align(horizon, c))),
))

== Ricorsione: il combinatore Y

Nel λ-calcolo non c'è un meccanismo per la ricorsione: le funzioni sono anonime, quindi una funzione non ha un nome con cui richiamare se stessa. Il problema si aggira con il *combinatore di punto fisso* $Y$.

Un *punto fisso* di una funzione $F$ è un termine $p$ tale che $F(p) = p$. $Y$ è una funzione di ordine superiore che, data $F$, ne costruisce un punto fisso:

#align(center, box(stroke: 1.5pt + red, inset: 12pt, radius: 4pt)[
  $Y = lambda f. (lambda x. f (x x))(lambda x. f (x x))$ #h(3em) $Y F attach(equiv, br: beta) F (Y F)$
])

Perché vale la proprietà: $Y F$ e $F (Y F)$ si riducono allo stesso termine.

#align(center, canvas(length: 1cm, {
  import draw: *
  content((0, 0), [$Y F$]); content((9, 0), [$F (Y F)$])
  content((0, -1.3), [$(lambda x. F (x x))(lambda x. F (x x))$])
  content((4.5, -2.8), box(stroke: 1pt + verde, inset: 6pt)[$F ((lambda x. F (x x))(lambda x. F (x x)))$])
  line((0, -0.3), (0, -1), mark: (end: "stealth")); content((1.6, -0.65), text(8pt)[metto $F$ al posto di $f$])
  line((0.6, -1.65), (2.3, -2.4), mark: (end: "stealth"))
  line((8.8, -0.3), (6.6, -2.35), mark: (end: "stealth")); content((9.6, -1.3), text(8pt)[riduco $Y F$ \ dentro $F(...)$])
  content((4.5, 0), text(fill: verde)[$attach(equiv, br: beta)$])
}))

Nel secondo passo $lambda x. F (x x)$ è passata a se stessa come argomento: ogni $x x$ diventa una nuova copia del termine di partenza, con una $F$ davanti. Continuando si ottiene $F (F (dots))$: una "copia infinita" della funzione.

Per definire una funzione ricorsiva $F = chevron.l "corpo che contiene" F chevron.r$ si fanno due passi:
+ si scrive $G = lambda f. chevron.l "espressione che contiene" f chevron.r$: il nome della funzione diventa un parametro;
+ si definisce $F = Y G$.

Allora $F = Y G attach(equiv, br: beta) G (Y G)$, cioè l'espressione con $Y G$ al posto di $f$; e dentro, di nuovo, $Y G attach(equiv, br: beta) G (Y G)$. $Y$ "srotola" la definizione una chiamata alla volta, senza usare il nome della funzione. Il caso che ferma la ricorsione lo deve mettere il programmatore.

*Esempio: fattoriale* (supponendo di avere numeri, $iff$, $n = 0$, $n - 1$, $*$).

$ G = lambda f. lambda n. iff (n = 0) thn 1 els n * f (n - 1) $

Calcolo $Y G 1$. Per brevità $W = (lambda x. G (x x))(lambda x. G (x x))$, il termine che si ricopia:

#block(breakable: false, $
  Y G 1 &arrow.r W 1 \
  &arrow.r G W 1 \
  &arrow.r (lambda n. iff (n = 0) thn 1 els n * W (n - 1)) 1 \
  &arrow.r iff (1 = 0) thn 1 els 1 * W (1 - 1) \
  &arrow.r^* 1 * W 0 \
  &arrow.r 1 * G W 0 \
  &arrow.r 1 * (lambda n. iff (n = 0) thn 1 els n * W (n - 1)) 0 \
  &arrow.r 1 * (iff (0 = 0) thn 1 els 0 * W (0 - 1)) \
  &arrow.r^* 1 * 1 = 1
$)

Nell'ultimo $iff$ la condizione è vera: $W (0 - 1)$ non viene mai calcolato e la ricorsione si ferma.

#nota[$Y$ funziona con la *call-by-name*, che non valuta subito gli argomenti: in $F (x x)$ l'argomento $x x$ viene ridotto solo se e quando serve nel corpo di $F$. Con la call-by-value $x x$ verrebbe valutato subito, e sarebbe un loop infinito.]

Per questo in JavaScript, che è call-by-value, $Y$ è un po' diverso. `x(x)` diventa `y => x(x)(y)`: non è più un valore da calcolare subito ma una funzione che aspetta ancora l'argomento `y`, e la ricorsione parte solo quando `f` viene davvero chiamata.

```js
const Y = f => (x => x(x))(x => f(y => x(x)(y)));
const factorial = f => (x => (x === 1 ? 1 : x * f(x - 1)));
const YFactorial = Y(factorial)(10);
```

== Codifiche: booleani e numeri

Il λ-calcolo puro ha solo funzioni. Booleani, condizionali e numeri (quello che serve per essere Turing-equivalenti) si ottengono con le *codifiche*. L'idea: non guardare cosa un valore *rappresenta* ma cosa ci si può *fare*, e descrivere quell'uso con una funzione.

Con un *booleano* si fa una scelta fra due alternative. Quindi un booleano è una funzione che, date due scelte, ne seleziona una:

#align(center, box(stroke: 1pt + blu, inset: 10pt, radius: 4pt, grid(columns: 2, column-gutter: 3em, row-gutter: 0.7em, align: left,
  $TRUE = lambda t. lambda f. t$, $TRUE a b arrow.r.double a$,
  $FALSE = lambda t. lambda f. f$, $FALSE a b arrow.r.double b$,
)))

Da qui gli operatori logici: $NOT$ applica il booleano $b$ alle due scelte $FALSE$ e $TRUE$, così $TRUE$ sceglie $FALSE$ e viceversa.

$ NOT = lambda b. b FALSE TRUE $
$ NOT TRUE arrow.r TRUE FALSE TRUE = (lambda t. lambda f. t) FALSE TRUE arrow.r.double FALSE \
  NOT FALSE arrow.r FALSE FALSE TRUE = (lambda t. lambda f. f) FALSE TRUE arrow.r.double TRUE $

Il *condizionale* sceglie in base al valore della condizione: passa i due rami al booleano $c$.

$ IF = lambda c. lambda "then". lambda "else". c "then" "else" #h(3em) IF TRUE a b arrow.r.double a #h(1.5em) IF FALSE a b arrow.r.double b $

#block(breakable: false, $
  IF TRUE e_1 e_2 &= (lambda c. lambda "then". lambda "else". c "then" "else") TRUE e_1 e_2 \
  &arrow.r (lambda "then". lambda "else". TRUE "then" "else") e_1 e_2 \
  &arrow.r (lambda "else". TRUE e_1 "else") e_2 \
  &arrow.r TRUE e_1 e_2 = (lambda t. lambda f. t) e_1 e_2 \
  &arrow.r (lambda f. e_1) e_2 arrow.r e_1
$)

*Esercizio*: calcolare $IF FALSE e_1 e_2$.

I *numeri naturali* hanno una definizione induttiva: zero è un naturale; se $n$ è un naturale, anche $"Succ" n$ (il successore) lo è. Le operazioni si definiscono allo stesso modo:

#align(center, table(columns: 3, align: left,
  [], [Caso zero], [Caso successore],
  [Somma], [$m + 0 = m$], [$m + "Succ" n = "Succ"(m + n)$],
  [Prodotto], [$m times 0 = 0$], [$m times "Succ" n = m times n + m$],
))

Nel λ-calcolo un numero si codifica con *cosa ci si fa*: ripetere qualcosa $n$ volte. Il *numerale di Church* $C_n$ prende una funzione $s$ (il successore) e un valore iniziale $z$ (lo zero), e applica $s$ a $z$ per $n$ volte. Il numero 3 vuol dire "fai una cosa tre volte".

#align(center, box(stroke: 1pt + verde, inset: 10pt, radius: 4pt, grid(columns: 3, column-gutter: 2.5em, row-gutter: 0.7em, align: left,
  ..range(4).map(n => $C_#n = lambda s. lambda z. #church(n)$),
  $C_n = lambda s. lambda z. s^n z$,
)))

Le operazioni sui numerali:

#block(breakable: false, table(columns: (auto, 1fr), align: left,
  [Definizione], [Come funziona],
  [$SUCC = lambda n. lambda s. lambda z. s (n s z)$], [$n s z$ applica $s$ a $z$ per $n$ volte; poi una $s$ in più: in tutto $n + 1$ volte. \ $SUCC C_1 arrow.r.double C_2$],
  [$PLUS = lambda m. lambda n. lambda s. lambda z. m s (n s z)$ \ oppure $lambda m. lambda n. m SUCC n$], [$n s z$ calcola $n$; $m s (dots)$ ci applica $s$ altre $m$ volte. Nella seconda forma: applico $SUCC$ a $n$ per $m$ volte. \ $PLUS C_i C_j arrow.r.double SUCC^i (C_j)$],
  [$TIMES = lambda m. lambda n. m (PLUS n) C_0$], [$m$ conta le ripetizioni: partendo da $C_0$, sommo $n$ per $m$ volte. \ $TIMES C_i C_j arrow.r.double PLUS C_j (PLUS C_j (dots (PLUS C_j C_0)))$ con $i$ somme],
))

*Esercizi*:
+ definire $ISZERO$ in modo che $ISZERO C_0 = TRUE$ e $ISZERO C_i = FALSE$ per $i != 0$; calcolare $ISZERO C_1$;
+ calcolare $SUCC C_1$ passo per passo;
+ calcolare $PLUS C_1 C_1$.
