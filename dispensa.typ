#import "@preview/cetz:0.4.2": canvas, draw, tree

#set document(title: "Paradigmi di Programmazione — Dispensa")
#set page(paper: "a4", margin: 2.2cm, numbering: "1")
#set text(lang: "it", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => { pagebreak(weak: true); it }
#show raw.where(block: true): block.with(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%, breakable: false)
#show table: it => block(breakable: false, it)
#show grid: it => block(breakable: false, it)
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
#let (fun, Apply, fix, lett, inn) = ("fun", "Apply", "fix", "let", "in").map(math.op)
#let (TRUE, FALSE, NOT, AND, OR, IF, SUCC, PLUS, TIMES, ISZERO, Twice, Comp, iff, thn, els, tt, ff, succ, pred, isZero) = ("TRUE", "FALSE", "NOT", "AND", "OR", "IF", "SUCC", "PLUS", "TIMES", "ISZERO", "Twice", "Comp", "if", "then", "else", "true", "false", "succ", "pred", "isZero").map(math.op)
// regola di inferenza: sopra la riga l'ipotesi, sotto la conclusione
#let regola(sopra, sotto) = $display(frac(sopra, sotto))$
// regola con nome a destra
#let centro(x) = pad(y: 0.6em, align(center, x))
#let inf(sopra, sotto, nome) = $regola(sopra, sotto) #text(8pt, fill: gray)[(#nome)]$
// regole in griglia, n per riga
#let rg(n, ..x) = align(center, grid(columns: (auto,) * n, column-gutter: 1.6em, row-gutter: 1.1em, align: center + bottom, ..x.pos()))
// assioma (regola senza premesse) con nome
#let ax(f, nome) = $#f #h(0.4em) #text(8pt, fill: gray)[(#nome)]$
// esercizio nel testo: solo la consegna, le soluzioni non ci sono
#let esercizio(n, body) = block(breakable: false, stroke: (left: 3pt + rgb("#e08a00")), fill: rgb("#fff6e6"), inset: 10pt, width: 100%)[
  *Esercizio #n* \ #body]
// "cosa devi saper fare" all'inizio di un capitolo
#let obiettivi(..voci) = block(stroke: 1pt + luma(150), radius: 4pt, inset: 10pt, width: 100%)[
  *Cosa devi saper fare* #list(..voci.pos())]
// enunciato importante (teorema, lemma, definizione chiave)
#let teorema(titolo, body) = block(stroke: 1pt + blu, radius: 4pt, inset: 10pt, width: 100%)[*#titolo.* #body]
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

#obiettivi(
  [mettere le parentesi sottintese e disegnare l'albero di un termine],
  [trovare le variabili libere e legate, calcolare FV],
  [fare una sostituzione con l'α-conversione quando serve],
  [trovare i redex e ridurre fino alla forma normale, o accorgersi che la riduzione non termina],
  [ridurre con call-by-value e call-by-name e dire in cosa differiscono],
  [dimostrare che due termini sono β-equivalenti],
  [usare Y per la ricorsione e calcolare con le codifiche (booleani, IF, numerali di Church)],
)

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

*Esempio*: quali parentesi sono sottintese in $lambda x. x lambda y. x y z$?
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

*Esempio*: $"FV"((lambda x. lambda y. x y)((lambda z. z) k))$
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

#nota[Il nome nuovo deve essere *fresco*. $lambda x. x y$ e $lambda y. y y$ *non* sono α-equivalenti: nel primo la $y$ è libera, nel secondo è stata catturata dal $lambda y$ ed è diventata il parametro. La prima funzione applica l'argomento a $y$, la seconda applica l'argomento a se stesso.]

#esercizio(1)[Trovare le variabili libere (prima mettere le parentesi sottintese): \
  a. $(lambda x. x)(lambda y. x x)(lambda y. y) y$ \
  b. $(lambda x. x k)((lambda x. lambda y. x y)(lambda z. (lambda x. z) y))$ \
  c. $x (lambda x. (lambda y. y y) x) y$]

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

*Esempi*. L'espressione è sempre la stessa, cambia la variabile da sostituire ($attach(equiv, br: alpha)$ vuol dire "α-equivalente", cioè uguale a meno di rinominare):

#table(columns: (auto, 1fr), align: left,
  [Sostituzione], [Risultato],
  [$((lambda x. y x) w){x := lambda k. k x}$], [$(lambda x. y x) w$ #h(0.5em) #text(9pt)[l'unica $x$ è legata: $(lambda x. e_1){x := e} equiv lambda x. e_1$]],
  [$((lambda x. y x) w){y := lambda k. k x}$], [$attach(equiv, br: alpha) ((lambda z. y z) w){y := lambda k. k x} = (lambda z. (lambda k. k x) z) w$ \ #text(9pt)[la $x$ di $lambda k. k x$ è libera e verrebbe catturata da $lambda x$: rinomino]],
  [$((lambda x. y x) w){w := lambda k. k x}$], [$(lambda x. y x)(lambda k. k x)$ #h(0.5em) #text(9pt)[$w$ non è sotto nessun $lambda$: caso applicazione]],
)

#esercizio(2)[Calcolare le sostituzioni (che evitano la cattura): \
  a. $(lambda y. x y){x := y}$ \
  b. $(lambda y. x y){x := lambda y. y}$ \
  c. $(lambda y. x y){x := lambda x. x y}$]

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

#esercizio(3)[Trovare tutti i redex: \
  a. $(lambda x. x)((lambda x. x)(lambda z. (lambda x. x) z))$ \
  b. $(lambda x. x)(lambda x. x x)(lambda y. y)$ \
  c. $x ((lambda x. (lambda y. y y) x) y)$]

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

#esercizio(4)[Dimostrare le β-equivalenze, con meno passi possibile: \
  a. $(lambda x. x)(lambda y. y) z attach(equiv, br: beta) (lambda x. (lambda k. k)) w z$ \
  b. $(lambda x. x)(lambda y. y) attach(equiv, br: beta) (lambda y. y)(lambda x. x)$ \
  c. $(lambda x. lambda y. x y) y attach(equiv, br: beta) (lambda x. (lambda x. x)(lambda z. y z)) k$]

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

La risposta generale è il teorema di Church-Rosser: l'ordine in cui si scelgono le β-riduzioni *non influisce sul risultato finale*.

#teorema[Teorema di Church-Rosser][Se $e arrow.r.double e_1$ e $e arrow.r.double e_2$, allora esiste $e'$ con $e_1 arrow.r.double e'$ e $e_2 arrow.r.double e'$. Cioè: se da una stessa espressione si fanno due sequenze di riduzioni diverse, c'è sempre un'espressione raggiungibile da entrambi i risultati (anche con zero passi).]

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

#regole([Standard (senza strategia)], red,
  rg(2, ax($(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$, "App"), inf($e arrow.r e'$, $lambda x. e arrow.r lambda x. e'$, "App-Body")), rg(2, inf($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$, "App-1"), inf($e_2 arrow.r e'$, $e_1 e_2 arrow.r e_1 e'$, "App-2")))
#regole([Call-by-value], verde,
  rg(3, ax($(lambda x. e_1) v_2 arrow.r e_1 {x := v_2}$, "CV-App"), inf($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$, "CV-App-1"), inf($e_2 arrow.r e'$, $v_1 e_2 arrow.r v_1 e'$, "CV-App-2")))
#regole([Call-by-name], blu,
  rg(2, ax($(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$, "CN-App"), inf($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$, "CN-App-1")))

- *Standard*: qualsiasi redex si può ridurre in qualsiasi momento, anche dentro il corpo di una funzione (App-Body). Non è deterministica.
- *Call-by-value*: $v$ sta per un *valore*, cioè un'espressione che non si può più ridurre: una funzione, ma anche una variabile libera come $y$ o un'applicazione bloccata come $x y$. La β-riduzione scatta solo quando l'argomento è un valore $v_2$; l'argomento $e_2$ si riduce solo quando la funzione è già un valore $v_1$.
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

#nota[Esiste anche la *call-by-need*, una variante della CBN: l'argomento si passa senza valutarlo, ma la prima volta che serve si valuta e il risultato si memorizza, così le altre occorrenze lo riusano. Termina negli stessi casi della CBN ed evita le valutazioni ripetute (è la valutazione _lazy_ di Haskell); non la tratteremo in dettaglio.]

#esercizio(5)[Ridurre fino alla forma normale, o accorgersi che la riduzione non termina. A ogni passo indicare il redex scelto; se ci sono più scelte, provarle tutte. \
  a. $(lambda x. lambda y. x y)(lambda z. z y) y$ \
  b. $(lambda x. lambda y. x y)(lambda x. y y) k$ \
  c. $(lambda x. (lambda y. x y)(lambda k. k))(x y)$ \
  d. $(lambda x. y)((lambda y. y y y)(lambda x. x x x))$ \
  e. $(lambda z. ((lambda x. lambda y. x y) z) z)(lambda z. z z)$]

#esercizio(6)[Ripetere l'esercizio 5 con call-by-value e con call-by-name.]

== Funzioni con più argomenti <currying>

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

Con la stessa idea, $AND$ e $OR$ usano il primo booleano $b$ per scegliere. $AND$: se $b$ è vero il risultato è $c$, altrimenti $FALSE$. $OR$: se $b$ è vero il risultato è $TRUE$, altrimenti $c$.

$ AND = lambda b. lambda c. b c FALSE #h(3em) OR = lambda b. lambda c. b TRUE c $

#block(breakable: false, $
  AND TRUE TRUE &arrow.r.double TRUE TRUE FALSE = (lambda t. lambda f. t) TRUE FALSE \
  &arrow.r (lambda f. TRUE) FALSE arrow.r TRUE \
  OR TRUE FALSE &arrow.r.double TRUE TRUE FALSE = (lambda t. lambda f. t) TRUE FALSE \
  &arrow.r (lambda f. TRUE) FALSE arrow.r TRUE
$)

Il *condizionale* sceglie in base al valore della condizione: passa i due rami al booleano $c$.

$ IF = lambda c. lambda "then". lambda "else". c "then" "else" #h(3em) IF TRUE a b arrow.r.double a #h(1.5em) IF FALSE a b arrow.r.double b $

#block(breakable: false, $
  IF TRUE e_1 e_2 &= (lambda c. lambda "then". lambda "else". c "then" "else") TRUE e_1 e_2 \
  &arrow.r (lambda "then". lambda "else". TRUE "then" "else") e_1 e_2 \
  &arrow.r (lambda "else". TRUE e_1 "else") e_2 \
  &arrow.r TRUE e_1 e_2 = (lambda t. lambda f. t) e_1 e_2 \
  &arrow.r (lambda f. e_1) e_2 arrow.r e_1
$)

#esercizio(7)[Calcolare $IF FALSE e_1 e_2$.]

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

$SUCC C_1$ passo per passo. Per non confondere le variabili, in $C_1$ rinomino $s, z$ in $s', z'$; il secondo passo riduce dentro il corpo della funzione (riduzione standard):

$ SUCC C_1 = (lambda n. lambda s. lambda z. s (n s z)) C_1 &arrow.r lambda s. lambda z. s (C_1 s z) \
  &= lambda s. lambda z. s ((lambda s'. lambda z'. s' z') s z) \
  &arrow.r.double lambda s. lambda z. s (s z) = C_2 $

#esercizio(8)[Definire $ISZERO$ in modo che $ISZERO C_0 = TRUE$ e $ISZERO C_i = FALSE$ per $i != 0$; calcolare $ISZERO C_1$.]

#esercizio(9)[a. Calcolare $PLUS C_1 C_1$. Poi dimostrare: \
  b. $IF (IF FALSE TRUE FALSE) C_1 C_2 attach(equiv, br: beta) C_2$ \
  c. $PLUS C_2 C_1 attach(equiv, br: beta) C_3$ \
  d. $TIMES C_2 C_2 attach(equiv, br: beta) C_4$]

Quindi il λ-calcolo è *Turing completo*: con codifiche furbe rappresenta quasi ogni costrutto dei linguaggi. Ma i programmi sarebbero lenti (migliaia di chiamate di funzione), lunghi (centinaia di righe) e difficili da capire. In pratica si usano linguaggi più ricchi, che hanno già le primitive giuste (numeri, booleani, `if`).

= Controllo dei tipi

#obiettivi(
  [spiegare a cosa servono i tipi e cosa vuol dire type safety],
  [leggere una regola di inferenza e costruire un albero di derivazione],
  [dimostrare una proprietà per induzione sulle derivazioni],
  [valutare passo per passo un'espressione con le regole small-step, dicendo il nome di ogni regola],
  [dire se un'espressione è ben tipata costruendo l'albero, o mostrare perché l'albero non si può costruire],
  [enunciare progresso e conservazione e dimostrarli per il caso dell'if],
)

== Perché servono i tipi

Nel λ-calcolo programmi e valori sono tutti funzioni. Quindi niente impedisce di usare un valore nel posto sbagliato:

$ FALSE C_0 = (lambda t. lambda f. f)(lambda s. lambda z. z) arrow.r lambda f. f $

$FALSE$ si può davvero applicare a $C_0$, e produce un valore. Ma non ha senso: $FALSE$ serve a scegliere fra due alternative, non a ricevere un numero. Peggio: $C_0$ e $FALSE$ sono *lo stesso termine*, a meno di α-conversione. Lo stesso vale per $IF C_0 e_1 e_2$ o $TRUE C_0$.

#align(center, canvas(length: 1cm, {
  import draw: *
  content((0, 1), box(stroke: 1pt + blu, inset: 6pt, radius: 3pt)[$FALSE = lambda t. lambda f. f$])
  content((0, -1), box(stroke: 1pt + verde, inset: 6pt, radius: 3pt)[$C_0 = lambda s. lambda z. z$])
  content((6, 0), box(stroke: 1pt + red, inset: 6pt, radius: 3pt)[$lambda x. lambda y. y$])
  line((1.9, 0.9), (4.9, 0.15), mark: (end: "stealth")); line((1.8, -0.9), (4.9, -0.15), mark: (end: "stealth"))
  content((3.4, 0.9), text(8pt)[$alpha$]); content((3.4, -0.9), text(8pt)[$alpha$])
  content((6, -0.8), text(8pt)[nessuno li distingue])
}))

Non è solo un problema del λ-calcolo. Nel *linguaggio macchina* le istruzioni sono parole della macchina (sequenze di bit), i dati sono parole della macchina, e le operazioni prendono sequenze di bit e restituiscono sequenze di bit.

#align(center, canvas(length: 0.6cm, {
  import draw: *
  for (k, b) in "01000001".clusters().enumerate() { rect((k, 0), (k + 1, 1)); content((k + 0.5, 0.5), mono(b)) }
  for (k, t) in ("un'istruzione?", "un numero?", "un carattere?").enumerate() {
    content((12, 1.2 - k * 0.8), anchor: "west", text(9pt, t))
    line((8.2, 0.5), (11.8, 1.2 - k * 0.8), stroke: grigio, mark: (end: "stealth"))
  }
}))

Un principio centrale dell'ingegneria del software è *trovare presto gli errori di programmazione* (come $FALSE C_0$). I linguaggi lo fanno con i *sistemi di tipo* (e più in generale con gli strumenti di *analisi statica*, che esaminano il programma senza eseguirlo).

I *tipi* raggruppano i valori in base al comportamento che vorremmo avessero. Il tipo di un dato dice come il linguaggio permette di usarlo. Un tipo:
- *limita i valori* che un'espressione (una variabile, una funzione) può assumere;
- *definisce le operazioni* ammesse su quei valori e come vengono memorizzati.

I linguaggi hanno dei tipi di base: interi (di varie dimensioni), numeri in virgola mobile (approssimano i reali), caratteri, booleani. $e : T$ si legge "$e$ ha tipo $T$":

#align(center, table(columns: 2, align: left,
  [Espressione], [Cosa dice],
  [$3 + 2 : "Int"$ #text(fill: verde)[✓]], [il risultato è un intero, e $+$ è usato bene: riceve due interi],
  [$tt : "Int"$ #text(fill: red)[✗]], [$tt$ non è un intero],
  [$2 + tt$ #text(fill: red)[✗]], [$+$ non è applicato bene],
))

Perché controllare i tipi? In un programma grande c'è questo pezzo:

```c
if (condizione_complicata)
  { return "hello"/10; }
```

Se i test non rendono mai vera `condizione_complicata`, la divisione di una stringa nel ramo `then` non viene mai scoperta. Poi un input non previsto dai test fa eseguire il ramo, e il programma va in errore *durante l'esecuzione*. Bastava segnalare `"hello"/10` come espressione non ammessa.

#block(sticky: true)[Lo stesso codice in JavaScript e in TypeScript:]

#grid(columns: (1fr, 1fr), gutter: 1em,
[
```js
function addNumbers(x, y) {
  return x + y; }
console.log(addNumbers(3, "0"));
```
*JavaScript* stampa `"30"`, una stringa. Il `+` accetta anche una coppia (numero, stringa): il numero viene trasformato in stringa (*coercion*) e le due stringhe attaccate.
],
[
```ts
function addNumbers(x: number,
                    y: number) {
  return x + y; }
console.log(addNumbers(3, "0"));
```
*TypeScript* si accorge del bug e dà un errore di tipo: _Argument of type 'string' is not assignable to parameter of type 'number'_. Come? Con delle *regole di tipo*.
])

== Sistemi di tipi

#align(center, text(12pt, style: "italic")["Well-typed programs cannot go wrong"] + text(9pt)[ #h(0.5em) — Robin Milner])

Un *sistema di tipi* associa tipi ai valori calcolati. Seguendo il flusso dei valori, prova a *dimostrare* che non avvengano errori di tipo. È il sistema stesso a stabilire cos'è un errore di tipo: un'operazione che si aspetta un certo tipo di valore usata con un valore per cui non ha senso.

Più precisamente è un metodo *sintattico*, *effettivo* e *strutturale* per dimostrare che il programma non ha comportamenti anomali:

#align(center, table(columns: 2, align: left,
  [Metodo], [Cosa vuol dire],
  [sintattico], [l'analisi segue la struttura sintattica del programma],
  [effettivo], [c'è un algoritmo che controlla i vincoli sui tipi, da mettere in un compilatore o in un interprete],
  [strutturale], [il tipo di un'espressione dipende solo dai tipi delle sue sottoespressioni (*composizionale*)],
))

*Type safety* (uso corretto dei tipi): se un'espressione ha un tipo, il tipo garantisce che venga usata nel modo giusto. Senza type safety si scrivono programmi pieni di bug, e i bug sono *vulnerabilità*: un attaccante può sfruttarli per cambiare il comportamento del programma o prenderne il controllo.

Il controllo può essere *statico*, *dinamico* o un misto dei due:

#align(center, canvas(length: 1cm, {
  import draw: *
  rect((0, 0), (5, 1), fill: rgb("#eefaf2"), stroke: verde); content((2.5, 0.5))[*compilazione*]
  rect((5.4, 0), (10.4, 1), fill: rgb("#fff0f0"), stroke: red); content((7.9, 0.5))[*esecuzione*]
  line((5, 0.5), (5.4, 0.5), mark: (end: "stealth"))
  content((2.5, -0.6), text(9pt, fill: verde)[controllo statico])
  content((2.5, -1.2), text(8pt)[trova gli errori prima di eseguire, non rallenta])
  content((7.9, -0.6), text(9pt, fill: red)[controllo dinamico])
}))

Il *type checker* (controllore dei tipi) verifica che il programma rispetti le intenzioni del programmatore, scritte nelle *annotazioni di tipo* (come `x: number`). Se un programma supera il controllo, durante l'esecuzione *non applicherà mai un'operazione a un valore del tipo sbagliato*. È una *correttezza parziale*: il programma è corretto rispetto ai tipi, non rispetto ad altri errori.

Resta una domanda: come si fa a sapere che i programmi che superano il controllo si comportano davvero bene durante l'esecuzione? Servono due cose:
+ un modo per *specificare* un sistema di tipi;
+ un modo per *dimostrare* che è corretto. Per questo bisogna capire nel dettaglio cosa succede quando un programma viene eseguito, cioè il suo *significato*.

Lo strumento per entrambe sono le regole di inferenza.

== Regole di inferenza

Le abbiamo già usate per le strategie di valutazione: sopra la riga le *premesse*, sotto la *conclusione*, a destra il *nome* della regola. Se valgono tutte le premesse, si può concludere $q$. Una regola senza premesse è un *assioma*: $q$ è un fatto accettato dal sistema.

#centro(grid(columns: 2, gutter: 4em, align: bottom,
  inf($p_1 quad p_2 quad dots quad p_n$, $q$, "nome"),
  inf($$, $q$, "assioma"),
))

Una conclusione è valida *rispetto alle regole del sistema scelto*. Esempio: le regole per l'uguaglianza fra termini, riflessiva e transitiva:

#centro(grid(columns: 2, gutter: 4em, align: bottom,
  inf($$, $t = t$, "Rifl"),
  inf($t_1 = t_2 quad t_2 = t_3$, $t_1 = t_3$, "Trans"),
))

Una dimostrazione mette insieme più regole in un *albero di derivazione*: le foglie in alto (premesse o assiomi), ogni riga è una regola applicata, la radice in basso è la conclusione. Dalle premesse $a = b$, $b = c$, $c = d$ si deriva $a = d$:

#centro(inf($inf(a = b quad b = c, a = c, "Trans") quad c = d$, $a = d$, "Trans"))

Le regole possono anche *definire un insieme*: le regole generano gli elementi, una derivazione dimostra che un elemento ci sta dentro. Per esempio i pari:

#grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
  align(center, stack(spacing: 2em,
    inf($$, $0 in "Pari"$, "Zero"),
    inf($(n - 2) in "Pari"$, $n in "Pari"$, $"Passo", n >= 2$))),
  [
    $ {0} subset.eq "Pari" arrow.r.double {0, 2} subset.eq "Pari" arrow.r.double {0, 2, 4} subset.eq "Pari" arrow.r.double dots $
    $ "Pari" = {0, 2, 4, 6, dots} $
    Derivazione di $4 in "Pari"$:
    #centro(inf(inf(inf($$, $0 in "Pari"$, "Zero"), $2 in "Pari"$, "Passo"), $4 in "Pari"$, "Passo"))
  ],
)

Per dimostrare una proprietà di *tutti* gli elementi generati si segue la struttura delle regole: è l'*induzione sulle derivazioni*. Un caso per ogni regola: gli assiomi sono i casi base, le altre regole i passi induttivi.

Proprietà da dimostrare: $P(n) equiv n mod 2 = 0$.

#align(center, table(columns: 2, align: left,
  [Caso base: regola (Zero)], [Passo induttivo: regola (Passo)],
  [$P(0)$ vale perché $0 mod 2 = 0$.], [Suppongo $P(n - 2)$ e dimostro $P(n)$. $(n-2) mod 2 = 0$ vuol dire che esiste $k$ con $n - 2 = 2k$. Allora $n = 2k + 2 = 2(k + 1)$: con $k' = k + 1$ ho $n = 2k'$, quindi $n mod 2 = 0$.],
))

Conclusione: per ogni $n in "Pari"$ vale $n mod 2 = 0$.

== Un linguaggio di espressioni

#block(sticky: true)[Primo caso di studio: un sistema di tipi per un piccolo linguaggio di espressioni con booleani e numeri. Prima la *sintassi*:]

#align(center, box(stroke: 1pt + blu, inset: 12pt, radius: 4pt, grid(columns: 3, column-gutter: 3em, align: left,
  [*Espressioni* \ $E ::= tt \ quad | space ff \ quad | space "NV" \ quad | space iff E thn E els E \ quad | space succ E \ quad | space pred E \ quad | space isZero E$],
  [*Valori* \ $V ::= tt \ quad | space ff \ quad | space "NV"$],
  [*Valori numerici* \ $"NV" ::= 0 | 1 | 2 | dots$],
)))

I *valori* sono i risultati finali: le espressioni che non vanno più calcolate.

Poi la *semantica*, cioè cosa succede quando un'espressione viene eseguita: un *interprete* scritto con regole di inferenza. Ogni regola dice come fare *un passo* di calcolo $E arrow.r E'$ (semantica _small-step_, a piccoli passi).

#regole([Condizionale], blu,
  rg(2, ax($iff tt thn E_1 els E_2 arrow.r E_1$, "If-True"), ax($iff ff thn E_1 els E_2 arrow.r E_2$, "If-False")),
  inf($E arrow.r E'$, $iff E thn E_1 els E_2 arrow.r iff E' thn E_1 els E_2$, "If-Cond"))

If-Cond ha la stessa forma delle regole delle strategie: finché la condizione non è un valore, si calcola la condizione. Quando diventa $tt$ o $ff$ scatta If-True o If-False.

#regole([Operazioni sui numeri], verde,
  rg(2, inf($E arrow.r E'$, $succ E arrow.r succ E'$, "Succ"), inf($m = n + 1$, $succ n arrow.r m$, "SuccNat")),
  rg(3, inf($E arrow.r E'$, $pred E arrow.r pred E'$, "Pred"), ax($pred 0 arrow.r 0$, "PredZero"), inf($n > 0 quad m = n - 1$, $pred n arrow.r m$, "PredNat")),
  rg(3, inf($E arrow.r E'$, $isZero E arrow.r isZero E'$, "IsZero"), ax($isZero 0 arrow.r tt$, "IsZeroZero"), inf($n > 0$, $isZero n arrow.r ff$, "IsZeroSucc")))

Lo schema è sempre lo stesso: la regola a sinistra calcola l'argomento finché diventa un numero $n$, le altre fanno l'operazione. $pred 0$ dà $0$: non ci sono numeri negativi.

Passo dopo passo, `if isZero 0 then 2 else pred 1` si calcola così:

#centro(stack(spacing: 0.9em,
  inf($isZero 0 arrow.r tt$, $iff isZero 0 thn 2 els pred 1 arrow.r iff tt thn 2 els pred 1$, "If-Cond"),
  [$iff tt thn 2 els pred 1 arrow.r 2$ #text(8pt, fill: gray)[ #h(0.5em) (If-True)]]))

Finora l'interprete sa solo calcolare. Ora gli aggiungiamo i *tipi*: solo due, $"Bool"$ e $"Nat"$ (i numeri).

#align(center, box(stroke: 1pt + blu, inset: 10pt, radius: 4pt)[$T ::= "Bool" | "Nat"$])

Il controllo dei tipi è una relazione fra espressioni e tipi, scritta $E : T$ ("$E$ ha tipo $T$"). È definita da regole di inferenza, una per ogni forma sintattica: il metodo è *sintattico*, per induzione sulla struttura del programma.

#regole([Regole di tipo], blu,
  [#inf($$, $tt : "Bool"$, "T-True") #h(2em) #inf($$, $ff : "Bool"$, "T-False") #h(2em) #inf($$, $n : "Nat"$, "T-Nat")],
  [#inf($E : "Bool" quad E_1 : T quad E_2 : T$, $iff E thn E_1 els E_2 : T$, "T-If")],
  [#inf($E : "Nat"$, $succ E : "Nat"$, "T-Succ") #h(1.5em) #inf($E : "Nat"$, $pred E : "Nat"$, "T-Pred") #h(1.5em) #inf($E : "Nat"$, $isZero E : "Bool"$, "T-IsZero")])

La relazione di tipo è la *più piccola* relazione che soddisfa tutte le istanze di queste regole. Un'espressione $E$ è *ben tipata* (_well-typed_) se esiste un $T$ con $E : T$; altrimenti è _ill-typed_.

*Controllo* ("$E$ ha tipo $T$?"): dati $E$ e $T$ si cerca un *albero di derivazione* fatto di istanze delle regole. Per esempio:

#let tn(t, n) = inf($$, t, n)
#centro(text(9pt, inf(
  [#tn($0 : "Nat"$, "T-Nat") #h(0.4em) #inf($0 : "Nat"$, $isZero 0 : "Bool"$, "T-IsZero") #h(0.4em) #tn($2 : "Nat"$, "T-Nat") #h(0.4em) #inf($1 : "Nat"$, $pred 1 : "Nat"$, "T-Pred")],
  $iff isZero 0 thn 2 els pred 1 : "Nat"$, "T-If")))

*Inferenza*: è il problema opposto, data solo $E$ si cerca un $T$ (e la derivazione).

Le regole sono *deterministiche*: per ogni forma sintattica ce n'è una sola, quindi si trasformano subito in un algoritmo che calcola il tipo guardando i tipi delle sottoespressioni:

```
typeof(E) =
  E = true | false         →  Bool
  E = n                    →  Nat
  E = if E1 then E2 else E3
      →  T1 = typeof(E1), T2 = typeof(E2), T3 = typeof(E3);
         se T1 = Bool e T2 = T3 allora T2, altrimenti errore
  E = succ E1 | pred E1    →  se typeof(E1) = Nat allora Nat, altrimenti errore
  E = isZero E1            →  se typeof(E1) = Nat allora Bool, altrimenti errore
```

Il tipo di un'espressione dipende solo dai tipi delle sue parti: è la *composizionalità*. Per questo T-If vuole i due rami dello *stesso* tipo $T$, che diventa il tipo di tutto l'`if`: chi usa quell'`if` deve sapere un tipo preciso. Per esempio l'argomento di $pred$ deve essere $"Nat"$ e la condizione di un `if` deve essere $"Bool"$.

#nota[I sistemi di tipo sono *imprecisi*: danno un'approssimazione prudente che considera tutte le esecuzioni possibili, e anche qualcuna impossibile. $iff tt thn 0 els ff$ dà sicuramente un numero, ma non ha tipo: T-If considera anche il ramo `else`, che a runtime non verrebbe mai eseguito, e $"Nat" != "Bool"$.]

#esercizio(10)[Per ogni espressione: dire se è ben tipata costruendo l'albero di derivazione (e dare il tipo), oppure mostrare che l'albero non si può costruire. Poi valutarla passo per passo fino a un valore, o fino a un'espressione che non si riduce più.
  a. $iff isZero (pred 0) thn tt els ff$ \
  b. $iff isZero (pred tt) thn tt els ff$ \
  c. $isZero (succ (pred 5))$ \
  d. $pred (pred (pred 2))$ \
  e. $iff tt thn isZero 2 els succ 1$]

== Type safety

Un sistema di tipi è *corretto* (_type safe_, _sound_) se vale ciò che promette Milner: i programmi ben tipati non "vanno storti". Si traduce in due proprietà, da dimostrare entrambe:

#align(center, block(breakable: false, table(columns: 2, align: left,
  [Proprietà], [Cosa dice],
  [*Progresso*: se $E : T$ allora $E$ è un valore oppure $E arrow.r E'$ per qualche $E'$], [un'espressione ben tipata *non si blocca* durante l'esecuzione: o ha finito, o può fare un passo],
  [*Conservazione*: se $E : T$ e $E arrow.r E'$ allora $E' : T$], [le regole di esecuzione *preservano il tipo*: dopo un passo l'espressione resta ben tipata, con lo stesso tipo],
)))

Insieme garantiscono che l'esecuzione di un'espressione ben tipata non si blocca mai su un tipo sbagliato.

#nota[Senza tipi può succedere che l'espressione non sia un valore e non esista nessuna regola per proseguire: $iff 0 thn 2 els 1$ resta bloccata, perché la condizione non è né $tt$ né $ff$. Il progresso dice che con i tipi non capita.]

Per la conservazione, esempio sull'albero visto prima: $iff isZero 0 thn 2 els pred 1 : "Nat"$ fa un passo e diventa $iff tt thn 2 els pred 1$, che ha ancora tipo $"Nat"$ (T-True, $2 : "Nat"$ e $pred 1 : "Nat"$ danno T-If). Poi diventa $2 : "Nat"$.

Le dimostrazioni sono per *induzione sulla derivazione di $E : T$*: un caso per ogni regola di tipo. Si mostra il caso dell'`if` (gli altri sono analoghi).

*Progresso.* Casi base (T-True, T-False, T-Nat): $E$ è già un valore. Caso $E = iff E_1 thn E_2 els E_3$: per T-If vale $E_1 : "Bool"$. Per ipotesi induttiva (a) $E_1$ è un valore, quindi $tt$ o $ff$, e scatta If-True o If-False; oppure (b) $E_1 arrow.r E_1'$, e scatta If-Cond. In ogni caso $E$ fa un passo.

*Conservazione.* Casi base: $E$ è un valore, non si riduce, la tesi è vera. Caso $E = iff E_1 thn E_2 els E_3 : T$: per T-If vale $E_1 : "Bool"$, $E_2 : T$, $E_3 : T$. Il passo $E arrow.r E'$ può venire da tre regole:
+ If-True: $E' = E_2$, che ha tipo $T$;
+ If-False: $E' = E_3$, che ha tipo $T$;
+ If-Cond con $E_1 arrow.r E_1'$: per ipotesi induttiva $E_1' : "Bool"$, quindi con T-If anche $iff E_1' thn E_2 els E_3 : T$.

= Il lambda calcolo tipato

#obiettivi(
  [usare l'ambiente dei tipi $Gamma$ e il giudizio $Gamma tack.r e : tau$],
  [costruire l'albero di tipo di un termine di FUN con T-Var, T-Fun, T-App, T-If, o mostrare che non esiste],
  [valutare un termine con la call-by-value, fino a un valore o a un termine bloccato],
  [enunciare progresso, conservazione e lemma di sostituzione, e dire dove serve il lemma],
  [spiegare perché $Omega$ e $Y$ non sono tipabili e come $fix$ recupera la ricorsione],
)

== Tipi e regole di tipo

Il λ-calcolo "puro" non ha tipi. Qui lo rendiamo tipato, partendo da un solo tipo di base, i booleani, più il tipo delle funzioni:

#align(center, box(stroke: 1pt + blu, inset: 10pt, radius: 4pt)[$tau ::= "Bool" | tau arrow.r tau$])

Esempi di tipi: $"Bool"$, $"Bool" arrow.r "Bool"$, $("Bool" arrow.r "Bool") arrow.r "Bool"$. La freccia *associa a destra*: $"Bool" arrow.r "Bool" arrow.r "Bool"$ sta per $"Bool" arrow.r ("Bool" arrow.r "Bool")$. Un tipo $tau_1 arrow.r tau_2$ è quello delle funzioni che prendono un argomento di tipo $tau_1$ e restituiscono un risultato di tipo $tau_2$.

Il linguaggio, che chiamiamo *FUN*, ha il parametro con il suo tipo (nel formato tradizionale: $lambda x : tau . e$):

#align(center, box(stroke: 1pt + blu, inset: 12pt, radius: 4pt, grid(columns: 2, column-gutter: 3em, align: left,
  [*Espressioni* \ $e ::= x$ #text(8pt, fill: gray)[variabile] \ $quad | space fun x : tau = e$ #text(8pt, fill: gray)[funzione] \ $quad | space Apply(e, e)$ #text(8pt, fill: gray)[applicazione] \ $quad | space tt | ff$ \ $quad | space iff e thn e els e$],
  [*Valori* \ $v ::= fun x : tau = e$ \ $quad | space tt | ff$ \ \ #text(9pt)[Il condizionale è un'*espressione*, non un comando: i due rami contengono espressioni.]],
)))

La semantica è quella già vista, riscritta con la nuova sintassi (sostituzione che evita la cattura). If-Cond si trova anche con il nome IF-Eval. Per l'applicazione si usa *call-by-value*: prima si calcola la funzione, poi l'argomento, poi si fa la β-riduzione.

#regole([Semantica], verde,
  [#ax($Apply(fun x : tau = e_1, v_2) arrow.r e_1 {x := v_2}$, "App")],
  rg(2, inf($e_1 arrow.r e_1'$, $Apply(e_1, e_2) arrow.r Apply(e_1', e_2)$, "App-1"), inf($e_2 arrow.r e_2'$, $Apply(v_1, e_2) arrow.r Apply(v_1, e_2')$, "App-2")),
  [#inf($e arrow.r e'$, $iff e thn e_1 els e_2 arrow.r iff e' thn e_1 els e_2$, "If-Cond")],
  rg(2, ax($iff tt thn e_1 els e_2 arrow.r e_1$, "If-True"), ax($iff ff thn e_1 els e_2 arrow.r e_2$, "If-False")))

*Il problema di tipare le funzioni.* Per dare un tipo a $fun x : tau_1 = e$ ci aspettiamo $tau_1 arrow.r tau_2$, dove $tau_2$ è il tipo del corpo $e$. Ma il tipo di $e$ dipende dal tipo di $x$, che si decide nella funzione. Serve ricordare i tipi delle variabili: l'*ambiente dei tipi* $Gamma$, una funzione che associa nomi a tipi.

$ Gamma = x_1 : tau_1, x_2 : tau_2, dots, x_k : tau_k quad "significa" quad Gamma(x_i) = tau_i $

$Gamma, x : tau$ è $Gamma$ estesa con $x : tau$: vale $tau$ per $x$, e $Gamma(y)$ per ogni $y != x$. L'ambiente vuoto $emptyset$ non lega nessuna variabile. Esempio con $Gamma = x : tau, y : tau'$:

#align(center, table(columns: 3, align: center,
  [$Gamma(x)$], [$Gamma(z)$], [$(Gamma, z : tau_2)(z)$],
  [$tau$], [indefinito], [$tau_2$],
))

Il controllo dei tipi diventa una relazione a *tre posti*, il *giudizio di tipo*:

$ Gamma tack.r e : tau $

"nell'ambiente $Gamma$, l'espressione $e$ ha tipo $tau$". Nel linguaggio dei compilatori l'ambiente dei tipi è la *tabella dei simboli* (_symbol table_); le regole le applica il compilatore durante l'analisi statica.

#regole([Regole di tipo di FUN], blu,
  [#inf($$, $Gamma tack.r tt : "Bool"$, "T-True") #h(2em) #inf($$, $Gamma tack.r ff : "Bool"$, "T-False") #h(2em) #inf($Gamma(x) = tau$, $Gamma tack.r x : tau$, "T-Var")],
  [#inf($Gamma tack.r e : "Bool" quad Gamma tack.r e_1 : tau quad Gamma tack.r e_2 : tau$, $Gamma tack.r iff e thn e_1 els e_2 : tau$, "T-If")],
  [#inf($Gamma, x : tau_1 tack.r e : tau_2$, $Gamma tack.r fun x : tau_1 = e : tau_1 arrow.r tau_2$, "T-Fun")],
  [#inf($Gamma tack.r e_1 : tau_1 arrow.r tau_2 quad Gamma tack.r e_2 : tau_1$, $Gamma tack.r Apply(e_1, e_2) : tau_2$, "T-App")])

- *T-Var*: una variabile ha il tipo che le dà l'ambiente.
- *T-If*: i rami hanno lo stesso tipo $tau$, che può essere anche un tipo funzione: si possono avere condizionali i cui rami sono funzioni.
- *T-Fun*: il parametro $x$ è dichiarato con il suo tipo $tau_1$; per tipare il corpo si usa $Gamma, x : tau_1$. Questa dichiarazione *sovrascrive* eventuali dichiarazioni precedenti di $x$ e vale solo nel corpo (è il suo _scope_). Il risultato è il tipo del corpo.
- *T-App*: se $e_1$ trasforma argomenti di tipo $tau_1$ in risultati di tipo $tau_2$ e $e_2$ ha tipo $tau_1$, il risultato è di tipo $tau_2$.

Esempio: $emptyset tack.r fun x : "Bool" = x : "Bool" arrow.r "Bool"$, perché $emptyset, x : "Bool" tack.r x : "Bool"$.

#par(justify: false)[Esempio più grande: $lambda f. f (iff ff thn tt els ff)$, cioè $fun f : "Bool" arrow.r "Bool" = Apply(f, e_0)$ con $e_0 = iff ff thn tt els ff$. Sia $Gamma_f = emptyset, f : "Bool" arrow.r "Bool"$.]

#let B = "Bool"
#centro(text(8pt, inf(
  inf(
    [#inf($$, $Gamma_f tack.r f : B arrow.r B$, "T-Var") #h(1.2em) #inf($Gamma_f tack.r ff : B quad Gamma_f tack.r tt : B quad Gamma_f tack.r ff : B$, $Gamma_f tack.r e_0 : B$, "T-If")],
    $Gamma_f tack.r Apply(f, e_0) : B$, "T-App"),
  $emptyset tack.r fun f : B arrow.r B = Apply(f, e_0) : (B arrow.r B) arrow.r B$, "T-Fun")))

#esercizio(11)[Per ogni termine: dire se è ben tipato costruendo l'albero di derivazione (e dare il tipo), oppure mostrare che l'albero non si può costruire. Poi valutarlo fino a un valore, o fino a un termine che non si riduce più.
  a. $Apply(fun x : "Bool" = x, tt)$ \
  b. $Apply(fun x : "Bool" = Apply(x, tt), ff)$ \
  c. $fun f : "Bool" arrow.r "Bool" = Apply(f, tt)$ \
  d. $Apply(fun f : "Bool" arrow.r "Bool" = (fun x : "Bool" = Apply(f, x)), fun x : "Bool" = x)$]

== Type safety nel λ-calcolo tipato

Le due proprietà valgono anche qui, con una condizione sul progresso: l'espressione deve essere *chiusa* (nessuna variabile libera), cioè tipata nell'ambiente vuoto.

#align(center, block(breakable: false, table(columns: 2, align: left,
  [Proprietà], [Cosa dice],
  [*Progresso*: se $emptyset tack.r e : tau$ allora $e$ è un valore oppure $e arrow.r e'$], [un'espressione chiusa e ben tipata non si blocca],
  [*Conservazione*: se $Gamma tack.r e : tau$ e $e arrow.r e'$ allora $Gamma tack.r e' : tau$], [un passo di esecuzione preserva il tipo],
)))

Si dimostrano ancora per induzione sulle derivazioni di tipo.

*Progresso.* Costanti booleane: come prima. Variabili: caso banale, perché nell'ambiente vuoto una variabile non ha tipo. Astrazione: è già un valore. Applicazione $e = Apply(e_1, e_2)$ con $emptyset tack.r e_1 : tau_1 arrow.r tau_2$ e $emptyset tack.r e_2 : tau_1$: per ipotesi induttiva $e_1$ e $e_2$ sono valori o possono fare un passo.
- Se $e_1$ fa un passo, $e$ fa un passo (prima regola dell'applicazione).
- Se $e_1$ è un valore e $e_2$ fa un passo, $e$ fa un passo (seconda regola).
- Se sono entrambi valori, $e_1$ ha tipo funzione, quindi è $fun x : tau_1 = e_3$, e $e$ fa un passo con la β-riduzione.

*Conservazione.* Il caso difficile è l'applicazione $e = Apply(fun x : tau_1 = e_3, e_2)$ con $e_2$ valore, che si riduce a $e' = e_3 {x := e_2}$. Dal tipo di $e$ si ricava $Gamma, x : tau_1 tack.r e_3 : tau_2$ e $Gamma tack.r e_2 : tau_1$, e bisogna dimostrare $Gamma tack.r e_3 {x := e_2} : tau_2$. Ma abbiamo tipato $e_3$ e non $e_3 {x := e_2}$: ci vuole un lemma che dica che la sostituzione non cambia il tipo.

#teorema[Lemma di sostituzione][Se $Gamma, x : tau_1 tack.r e_3 : tau_2$ e $Gamma tack.r e_2 : tau_1$, allora $Gamma tack.r e_3 {x := e_2} : tau_2$.]

Sostituire il parametro formale con un parametro attuale dello *stesso tipo* conserva il tipo. Esempio: con $x : "Bool"$ vale $iff x thn ff els tt : "Bool"$, quindi anche $(iff x thn ff els tt){x := tt} = iff tt thn ff els tt : "Bool"$. Il lemma si dimostra per induzione sulla derivazione di $Gamma, x : tau_1 tack.r e_3 : tau_2$; i casi interessanti sono variabili e astrazioni. Con il lemma la conservazione è dimostrata: è proprio $Gamma tack.r e' : tau_2$.

== Estensioni e ricorsione <fix>

Si può estendere FUN per farlo diventare un vero linguaggio di programmazione. Con le costanti numeriche $n$ (tipo $"Nat"$) e le operazioni binarie $e_1 plus.o e_2$ (con $plus.o in {"+", "-", "*", "/", "%"}$, di tipo noto $tau_1 times tau_2 arrow.r tau$):

Si calcola prima l'operando sinistro, poi il destro, poi si fa l'operazione ($delta_plus.o$ è l'operazione vera, per esempio la somma):

#centro([#inf($e_1 arrow.r e_1'$, $e_1 plus.o e_2 arrow.r e_1' plus.o e_2$, "Op-1") #h(2em) #inf($e_2 arrow.r e_2'$, $n_1 plus.o e_2 arrow.r n_1 plus.o e_2'$, "Op-2") #h(2em) #inf($delta_plus.o (n_1, n_2) = n$, $n_1 plus.o n_2 arrow.r n$, "Op-3")])

#centro(grid(columns: 2, gutter: 3em, align: bottom,
  inf($$, $Gamma tack.r n : "Nat"$, "T-Nat"),
  inf($Gamma tack.r e_1 : tau_1 quad Gamma tack.r e_2 : tau_2 quad plus.o : tau_1 times tau_2 arrow.r tau$, $Gamma tack.r e_1 plus.o e_2 : tau$, "T-Op")))

Si aggiungono anche le *dichiarazioni locali* $"let" x = e_1 "in" e_2$. Si calcola prima $e_1$; quando è un valore $v$ lo si sostituisce a $x$ in $e_2$. Il tipo di $x$ è quello di $e_1$, e vale solo in $e_2$:

#regole([Dichiarazioni locali], verde,
  [#inf($e_1 arrow.r e_1'$, $lett x = e_1 inn e_2 arrow.r lett x = e_1' inn e_2$, "Let-1") #h(3em) #ax($lett x = v inn e_2 arrow.r e_2 {x := v}$, "Let-2")],
  [#inf($Gamma tack.r e_1 : tau_1 quad Gamma, x : tau_1 tack.r e_2 : tau_2$, $Gamma tack.r lett x = e_1 inn e_2 : tau_2$, "T-Let")])

*Ricorsione.* Nel λ-calcolo tipato semplice tutti i programmi tipabili *terminano*. Quindi $Omega = (lambda x. x x)(lambda x. x x)$ e il combinatore $Y$ *non sono tipabili*. Il motivo è l'auto-applicazione $x x$:

#centro(inf($Gamma tack.r x : tau_1 arrow.r tau_2 quad Gamma tack.r x : tau_1$, $Gamma tack.r Apply(x, x) : tau_2$, "T-App"))

$x$ ha un solo tipo, quindi servirebbe $tau_1 = tau_1 arrow.r tau_2$, che è impossibile. Per avere la ricorsione bisogna aggiungere al linguaggio un costrutto apposta, tipabile e con le proprietà che vogliamo.

Si parte da un esempio. Il fattoriale è il *punto fisso* della funzione $G$, che prende l'approssimazione $f$ del fattoriale e ne costruisce una migliore:

$ G = fun f : "Nat" arrow.r "Nat" = fun n : "Nat" = iff isZero n thn 1 els n * f(pred n) $
$ G : ("Nat" arrow.r "Nat") arrow.r "Nat" arrow.r "Nat" $

Il costrutto $fix e$ calcola questo punto fisso, e si scrive $"fact" = fix G$.

#regole([Il costrutto fix], blu,
  [#inf($e arrow.r e'$, $fix e arrow.r fix e'$, "Fix") #h(3em) #ax($fix (fun f : tau = e) arrow.r e {f := fix (fun f : tau = e)}$, "FixFun")],
  [#inf($Gamma tack.r e : tau arrow.r tau$, $Gamma tack.r fix e : tau$, "T-Fix")])

La regola di valutazione "srotola" una volta la ricorsione: il corpo $e$ viene eseguito con $f$ sostituita da $fix$ di sé stesso, così alla prossima chiamata ricorsiva si srotola ancora. Per $"fact" 3 = (fix G) 3$:

$ (fix G) 3 arrow.r (fun n : "Nat" = iff isZero n thn 1 els n * (fix G)(pred n)) 3 arrow.r^* 3 * (fix G)(pred 3) $

Il λ-calcolo tipato semplice con $fix$ si chiama *PCF* (_Programming Computable Functions_), un linguaggio funzionale tipato introdotto da Gordon Plotkin nel 1977.

Per scrivere meno c'è lo zucchero sintattico $lett "rec" x : tau = e inn e'$, che sta per $lett x = fix (fun x : tau = e) inn e'$. In OCaml ci sono due primitive: `fun` per le funzioni non ricorsive e `let rec` per quelle ricorsive.

```ocaml
let plusOne = fun x -> x + 1;;
let rec fact x = if x <= 1 then 1 else x * fact (x - 1)
```

== Cosa possono garantire i tipi

Con PCF il percorso sui tipi è completo, e resta da capire a cosa serve. Il λ-calcolo è un *modello in piccolo* dei linguaggi: sistemi di tipi, terminazione e verifica si studiano qui, dove le regole sono poche, e poi si portano ai linguaggi veri.

Un tipo è una *specifica di comportamento*: $tau_1 arrow.r tau_2$ dice che la funzione prende un $tau_1$ e restituisce un $tau_2$, e il type checking controlla che il programma rispetti questa specifica. Con tipi più ricchi si controllano anche altre proprietà, per esempio la segretezza e l'autenticità nei protocolli di sicurezza, o l'assenza di deadlock (processi bloccati ad aspettarsi a vicenda) nei sistemi concorrenti.

La garanzia però è solo *parziale*, per un limite che non si può aggirare. Le domande interessanti su un programma (termina su tutti gli input? quanto può crescere la memoria dinamica? lascia uscire informazioni private?) riguardano cosa fa quando gira, e il *teorema di Rice* (1953) dice che *nessuna proprietà non banale del comportamento di un programma è decidibile*: non esiste un algoritmo che risponda sempre giusto ("non banale" vuol dire vera per alcuni programmi e falsa per altri). Non basta nemmeno eseguire il programma e guardare, perché non c'è un limite al tempo che può impiegare.

Si esce dal problema *approssimando*: al posto della proprietà esatta se ne controlla una più prudente, che è decidibile. Un sistema di tipi fa proprio questo, e l'approssimazione deve rispettare i comportamenti veri: valgono progresso e conservazione, quindi un programma accettato non dà mai errori di tipo. Il prezzo è che qualche programma corretto viene rifiutato. Nel disegno ogni ovale è un insieme di programmi: i ben tipati stanno tutti dentro quelli senza errori di tipo (è la type safety), ma non li riempiono.

#centro(canvas(length: 1cm, {
  import draw: *
  circle((0, 0), radius: (5.2, 2.1), stroke: 0.8pt + verde, fill: rgb("#eefaf2"))
  circle((-1.9, -0.2), radius: (2.6, 1.3), stroke: 0.8pt + blu, fill: rgb("#eef4ff"))
  content((0, 1.65), text(9pt, fill: verde)[programmi che non danno errori di tipo])
  content((-1.9, 0.5), text(9pt, fill: blu)[programmi ben tipati])
  circle((-1.9, -0.45), radius: 0.07, fill: black)
  content((-1.9, -0.85), text(9pt, $iff tt thn 1 els 0$))
  circle((2.6, -0.2), radius: 0.07, fill: black)
  content((2.6, -0.6), text(9pt, $iff tt thn 0 els ff$))
  circle((6.3, 0), radius: 0.07, fill: red)
  content((6.3, -0.4), text(9pt, fill: red, $succ tt$))
}))

Il punto rosso sta fuori da tutto: $succ tt$ si blocca, e il type checker lo rifiuta giustamente. $iff tt thn 0 els ff$ invece non dà errori, ma viene rifiutato lo stesso.

Su questa idea sono costruiti gli *analizzatori statici* usati nell'industria, che controllano il codice senza eseguirlo: per esempio Infer, FlowDroid e Roslyn Code Analyzer.

= OCaml: espressioni, funzioni e tipi

#obiettivi(
  [leggere la risposta del toplevel: nome legato, tipo, valore],
  [tradurre un λ-termine in OCaml e scrivere funzioni con `fun`, `let`, `let ... in`, `let rec`],
  [distinguere una funzione curried da una che prende una coppia, e usare l'applicazione parziale],
  [ricavare a mano il tipo di una funzione con il metodo dei vincoli, anche quando è polimorfo (`'a`)],
)

== Il toplevel e i tipi di base

Dopo il modello, il linguaggio. *OCaml* (INRIA, 1996) discende da *ML* (Robin Milner, 1972), il linguaggio funzionale di riferimento: fortemente tipato, con funzioni come valori, variabili immutabili, polimorfismo e pattern matching, e con la *type inference* (il compilatore deduce i tipi da solo). In mezzo c'è *Caml*, che ha aggiunto un'implementazione efficiente e i moduli; OCaml aggiunge gli oggetti. F\# di Microsoft è una variante di OCaml. Lo studiamo perché mostra il paradigma funzionale fatto bene, perché molti linguaggi moderni ne stanno copiando dei pezzi, e perché si presta a scrivere interpreti: lo useremo per implementare linguaggi di paradigmi diversi.

Per provare il codice si usa il *toplevel*, un *REPL* (_Read-Eval-Print Loop_): legge un'espressione, la compila, la valuta e stampa tipo e risultato. Si apre con `ocaml` da terminale, oppure con `utop`, con l'interprete online try.ocamlpro.com o con il notebook Jupyter del corso. Il toplevel `ocaml` valuta solo quando trova `;;`, che chiude l'input; nel notebook `;;` serve solo per separare più espressioni nella stessa cella. Negli esempi la risposta del toplevel è scritta come commento, fra `(*` e `*)`.

```ocaml
let x = 42;;   (* val x : int = 42 *)
x + 5;;        (* - : int = 47 *)
```

#align(center, table(columns: 4, align: left,
  [Risposta], [Prima di `:`], [Fra `:` e `=`], [Dopo `=`],
  [`val x : int = 42`], [`val x`: è nato il nome `x`], [il tipo: `int`], [il valore: `42`],
  [`- : int = 47`], [`-`: nessun nome nuovo], [il tipo: `int`], [il valore: `47`],
))

`let` crea un *legame* (_binding_) fra un nome e un valore: *non è un assegnamento*, il valore di `x` non cambierà più. Il tipo è dedotto guardando la *struttura* dell'espressione, senza calcolarla.

I nomi contengono lettere, cifre, `_` e `'`, e iniziano con una lettera minuscola o con `_`: `x_plus_3` e `x'` vanno bene; `Seven` no (con la maiuscola OCaml cerca un *costruttore*: `Unbound constructor`), `7x` e `x-plus-3` neanche.

In OCaml *tutto è un'espressione*: non ci sono comandi che cambiano uno stato, ogni costrutto calcola un valore. I tipi di base:

#align(center, table(columns: 3, align: left,
  [Tipo], [Valori], [Operazioni],
  [`int`], [`3`, `-1`], [`+ - * /`, `mod` (resto)],
  [`float`], [`3.2`, `3.` (cioè 3.0)], [`+. -. *. /.` con il punto, `**` (potenza)],
  [`bool`], [`true`, `false`], [`&&`, `||`, `not`],
  [`char`], [`'a'` (apici)], [`int_of_char 'a'` dà `97`, `char_of_int`],
  [`string`], [`"abcd"` (virgolette)], [`^` concatena: `"hello" ^ "world"`],
  [`unit`], [solo `()`], [come `void` in C],
))

Su tutti i tipi si confronta con `= <> < > <= >=`.

#nota[Trappole per chi viene dal C: l'uguaglianza è `=`, non `==`; il diverso è `<>`, non `!=`. `&&` e `||` sono *cortocircuitati*: in `e1 && e2`, se `e1` è `false` il risultato è già `false` ed `e2` non viene valutata.]

OCaml *non ha overloading*: `+` lavora solo sugli `int`, e per i `float` serve `+.`. E *non ha conversioni implicite*: in C o Java `3 + 2.5` vale 5.5 (il 3 viene promosso a `float`), e il cast `(int) 3.2` tronca a 3. In OCaml `3 + 2.5` è un errore di tipo, e la conversione si scrive:

```ocaml
(float_of_int 3) +. 2.4;;   (* - : float = 5.4 *)
int_of_float 3.7;;          (* - : int = 3 *)
int_of_string "10";;        (* - : int = 10 *)
```

Due motivi: le conversioni implicite sono una fonte di errori difficili da trovare, e la type inference ha bisogno di sapere con esattezza il tipo di ogni espressione.

Il primo tipo strutturato è la *tupla*: una sequenza di valori, anche di tipi diversi, separati da virgole (le parentesi si possono omettere). I componenti si riconoscono dalla posizione, non da un nome.

```ocaml
let t = (10, "hello", 12.5);;
(* val t : int * string * float = (10, "hello", 12.5) *)
```

Il tipo è il *prodotto* dei tipi dei componenti: se vediamo `int` e `float` come gli insiemi $ZZ$ e $RR$, `int * float` è il prodotto cartesiano $ZZ times RR$, e `(3, 4.2)` ne è un elemento. Una tupla si può *destrutturare* con `let`, scrivendo a sinistra un *pattern* con la stessa forma:

```ocaml
let p = (3.0, 5.0);;   (* val p : float * float = (3., 5.) *)
let (x, y) = p;;       (* val x : float = 3.   val y : float = 5. *)
x +. y;;               (* - : float = 8. *)
```

== Funzioni

Come nel λ-calcolo, in OCaml le *funzioni sono valori*: possono essere il risultato di un'espressione, essere passate a un'altra funzione o restituite da una funzione. La λ diventa `fun`, il punto diventa `->`:

```ocaml
fun x -> x + 1;;          (* - : int -> int = <fun> *)
(fun x -> x + 1) 10;;     (* - : int = 11 *)
```

`fun x -> x + 1` è $lambda x. x + 1$: una funzione *anonima* (senza nome), con argomento `x` e corpo `x + 1`. Il tipo `int -> int` dice che prende un intero e restituisce un intero; il valore è scritto `<fun>`, perché una funzione non si può stampare. In JavaScript la stessa funzione è `function(x) { return x+1 }` o `x => x + 1`; anche Java ha le _lambda expressions_. Sono tutte idee prese dal λ-calcolo.

La traduzione da λ-calcolo (con numeri e operazioni) a OCaml è una funzione $⟦dot⟧$, definita per ricorsione sulla struttura dei termini come $"FV"$: un caso per ogni elemento della sintassi.

#align(center, table(columns: 2, align: left,
  [λ-termine], [OCaml],
  [$⟦n⟧$ (un numero)], [`n`],
  [$⟦x⟧$], [`x`],
  [$⟦T' "op" T''⟧$ (op è `+ - * /`)], [$⟦T'⟧$ `op` $⟦T''⟧$],
  [$⟦lambda x. T'⟧$], [`fun x ->` $⟦T'⟧$],
  [$⟦T' T''⟧$], [$⟦T'⟧ ⟦T''⟧$],
))

Si traduce ogni λ-termine, ma non tutto OCaml viene da un λ-termine: la sintassi di OCaml è molto più ricca. Per esempio $⟦lambda f. lambda n. f n + 1⟧ = $ `fun f -> fun n -> f n + 1`. Applicata a $lambda x. 2 * x$ e a 10 dà lo stesso risultato della β-riduzione (l'applicazione associa a sinistra, e $f n$ si calcola prima del $+$):

$ (lambda f. lambda n. f n + 1)(lambda x. 2 * x) 10 arrow.r (lambda n. (lambda x. 2 * x) n + 1) 10 arrow.r (lambda n. 2 * n + 1) 10 arrow.r 20 + 1 = 21 $

```ocaml
(fun f -> fun n -> f n + 1) (fun x -> 2 * x) 10;;   (* - : int = 21 *)
```

È una *funzione di ordine superiore* (_higher-order_): prende una funzione (`f`) come parametro.

Con più parametri si scrive una catena di `fun`, e il tipo è una catena di frecce:

```ocaml
fun x -> fun y -> x + y;;   (* - : int -> int -> int = <fun> *)
```

`->` nei tipi *associa a destra*: `int -> int -> int` è `int -> (int -> int)`, una funzione che prende `x` e restituisce la funzione `fun y -> x + y`.

Per scrivere meno, `fun x y -> x + y` sta per `fun x -> fun y -> x + y`. È *zucchero sintattico*: un costrutto che non aggiunge niente al linguaggio, perché si può scrivere con altri costrutti, ma rende il codice più comodo, come `x += 1` per `x = x + 1` in C.

Siccome le funzioni sono valori, si legano a un nome con `let`. La seconda forma è zucchero per la prima ed è *il modo più comune di definire funzioni*:

```ocaml
let somma = fun x y -> x + y;;
let somma x y = x + y;;         (* val somma : int -> int -> int = <fun> *)
somma 3 4;;                     (* - : int = 7 *)
```

C'è anche `function x -> x + 1`, che prende *un solo* parametro: torna utile con il pattern matching (@pattern).

*Non esiste il `return`*: il corpo di una funzione è un'espressione, e il suo valore è il risultato. In un linguaggio imperativo il corpo è una sequenza di comandi, e `return` serve a interromperla e dire cosa restituire.

```ocaml
let media x y = (x +. y) /. 2.0;;
(* val media : float -> float -> float = <fun> *)
```

#nota[Senza parentesi, `x +. y /. 2.0` calcola $x + y/2$: `/.` ha la precedenza su `+.` come nella matematica. `media 4. 6.` darebbe `7.` invece di `5.`.]

Un `let` "nudo" vale per tutto quello che viene dopo (ambiente globale). `let ... in` invece dichiara una variabile *locale*, visibile solo nell'espressione dopo `in` (come una variabile dichiarata in un blocco `{ }` in C):

```ocaml
let z = 10 in z * z / 2;;   (* - : int = 50 *)
let w = 5 * z;;             (* Error: Unbound value z *)
```

Si legge come in matematica: "sia $z = 10$ in $z^2 \/ 2$". Con `let ... in` si definiscono anche *funzioni ausiliarie*: `let f x = 2 * x in f (f 10)` vale 40. Un esempio completo: le soluzioni di $a x^2 + b x + c = 0$ sono $(-b plus.minus sqrt(Delta)) \/ 2a$ con $Delta = b^2 - 4 a c$.

```ocaml
let sol a b c =
  let delta = b *. b -. 4. *. a *. c in
  let sol' op = (op (-. b) (sqrt delta)) /. (2. *. a) in
  (sol' (+.), sol' (-.));;
(* val sol : float -> float -> float -> float * float = <fun> *)
sol 1. (-5.) 6.;;   (* - : float * float = (3., 2.) *)
```

- `delta` è calcolato una volta sola e usato due volte; `sqrt` è la radice quadrata, già definita.
- Le due soluzioni differiscono solo per l'operazione ($+$ o $-$), quindi la funzione ausiliaria `sol'` la prende come parametro `op`.
- `(+.)` è l'operatore `+.` in *forma prefissa* (prima degli operandi): `(+.) 3.5 2.0` vale `5.5`. Un operatore usato così va tra parentesi, altrimenti OCaml lo legge in forma infissa (in mezzo agli operandi). `(-. b)` è $-b$, e anche `(-5.)` va tra parentesi.

Il nome della funzione e gli argomenti sono separati da *spazi*, senza parentesi né virgole. Queste funzioni si chiamano *curried*: prendono gli argomenti uno alla volta, come nel λ-calcolo (@currying). `somma 3 4` è `(somma 3) 4`. Si possono usare anche parentesi e virgole, ma è un'altra funzione:

#align(center, table(columns: 3, align: left,
  [Definizione], [Tipo], [Chiamata],
  [`let somma x y = x + y`], [`int -> int -> int`], [`somma 3 4`, un argomento alla volta],
  [`let somma (x, y) = x + y`], [`int * int -> int`], [`somma (3, 4)`: *un solo* argomento, una coppia, destrutturata in `x` e `y`],
))

Il vantaggio della forma curried è l'*applicazione parziale*: passando solo il primo argomento si ottiene una funzione che aspetta il secondo. Nel λ-calcolo $(lambda x. lambda y. x + y) 10 arrow.r lambda y. 10 + y$.

```ocaml
somma 10;;                  (* - : int -> int = <fun> *)
let somma_dieci = somma 10;;
somma_dieci 5;;             (* - : int = 15 *)
```

Da un'unica definizione si ottengono infinite funzioni (`somma 1`, `somma 5`…). Non è come i parametri opzionali o con valore di default di altri linguaggi: lì la funzione chiamata è sempre la stessa, si evita solo di scrivere qualche argomento.

== Condizioni e ricorsione

Nei linguaggi imperativi il flusso si controlla con `if` e con i cicli (`while`), che hanno senso perché c'è l'assegnamento: un `if` sceglie fra due assegnamenti, un `while` ne ripete uno. In OCaml le variabili sono *immutabili*, come le incognite di un'espressione algebrica: non c'è assegnamento, e quindi un ciclo non avrebbe niente da cambiare. Il flusso si controlla con l'espressione `if` e con la *ricorsione*, che ripete un calcolo richiamando la stessa funzione.

`if` è un'*espressione*, come `( ? : )` in C e JavaScript: ha *sempre* tutti e due i rami, `then` ed `else`, *dello stesso tipo*, e si può mettere a destra di un `let`.

```ocaml
let x = 23;;
let y = if x > 10 then 1 else 0;;   (* val y : int = 1 *)
```

#nota[`let f x = if x > 0 then x else "errore"` è un errore di tipo: un ramo è `int`, l'altro `string`, e il tipo del risultato non si può decidere. Senza `else`, invece, `f` non saprebbe cosa restituire quando $x <= 0$: il corpo è un'unica espressione, e dopo l'`if` non si può scrivere altro.]

Una funzione ricorsiva si dichiara con *`let rec`*:

```ocaml
let fact n = if n <= 0 then 1 else n * fact (n - 1);;
(* Error: Unbound value fact  (Hint: ... add the rec keyword) *)
let rec fact n = if n <= 0 then 1 else n * fact (n - 1);;
(* val fact : int -> int = <fun> *)
```

Il motivo: `let fact n = e` sta per `let fact = fun n -> e`, e mentre si valuta `fun n -> e` il nome `fact` non esiste ancora. `rec` rende il nome visibile anche dentro la sua definizione; è il costrutto $fix$ di PCF (@fix). La definizione somiglia a quella matematica: una scelta fra due casi, e in uno la funzione richiama se stessa.

$ "fact"(n) = cases(1 & "se" n <= 0, n dot "fact"(n - 1) & "altrimenti") $

```ocaml
let rec fibonacci n =
  if n = 0 || n = 1 then n else fibonacci (n - 1) + fibonacci (n - 2);;
(* metodo di Euclide *)
let rec mcd n m = if m = 0 then n else mcd m (n mod m);;
```

Una funzione può usare solo funzioni definite prima. Due funzioni che si chiamano a vicenda (*mutuamente ricorsive*) si definiscono insieme, unite da `and`:

```ocaml
let rec pari n = if n = 0 then true else dispari (n - 1)
and dispari n = if n = 0 then false else pari (n - 1);;
pari 6;;      (* - : bool = true *)
```

== Type inference e polimorfismo

Il toplevel dà il tipo di ogni espressione senza che lo scriviamo. Lo ricava da due certezze: i *valori* hanno un tipo preciso (`5.` è `float`), e gli *operatori* lavorano su tipi precisi (`+` solo su `int`, `+.` solo su `float`). Da qui deduce il tipo delle variabili: in `x + y`, `x` e `y` devono essere `int`. Procede dalle foglie dell'albero di sintassi verso la radice, tenendo una lista "variabile ↦ tipo". Se la stessa variabile compare due volte, i due tipi devono coincidere, o essere *unificabili* (uno più generico dell'altro, si prende il meno generico); altrimenti è un errore di tipo. `(x+1)-(x+4)` va bene, `(x+1)-(x+.4.0)` no: la prima `x` è `int`, la seconda `float`.

Con le funzioni si guardano anche argomenti e risultati. In `fun f -> fun n -> f n + 1` (l'applicazione ha la precedenza su `+`, quindi il corpo è `(f n) + 1`): `f n` è un operando di `+`, quindi è `int`; `f` è applicata, quindi è una funzione; di `n` non si sa niente, e il suo tipo resta un generico `'a`. Il risultato è `('a -> int) -> 'a -> int`.

Il metodo si fa a mano con i *vincoli*: una *variabile di tipo* (un tipo ancora sconosciuto) per ogni parametro e una per il risultato, poi un'equazione per ogni pezzo della funzione, poi si risolve.

```ocaml
let sum_if_true test first second =
  (if test first then first else 0) + (if test second then second else 0);;
```

Il tipo ha la forma `TEST -> FIRST -> SECOND -> RIS`.

#align(center, table(columns: 2, align: left,
  [Vincolo], [Da dove viene],
  [`TEST = FIRST -> bool`], [`test first` è la condizione del primo `if`],
  [`TEST = SECOND -> bool`], [`test second` è la condizione del secondo `if`],
  [`FIRST = int`], [i rami del primo `if` sono `first` e `0`],
  [`SECOND = int`], [i rami del secondo `if` sono `second` e `0`],
  [`RIS = int`], [il risultato di `+` è `int`],
))

Risolvendo: `FIRST = SECOND = int`, `TEST = int -> bool`, `RIS = int`, cioè `(int -> bool) -> int -> int -> int`. La funzione somma `first` e `second`, ma solo quelli che superano il controllo `test`; gli altri contano 0. Una funzione che restituisce `true` o `false`, come `test`, si chiama *predicato*. Passando predicati diversi la stessa funzione somma solo i pari, solo i positivi, o altro:

```ocaml
sum_if_true (fun x -> x mod 2 = 0) 3 4;;    (* - : int = 4 *)
sum_if_true (fun x -> x > 0) 3 (-4);;       (* - : int = 3 *)
```

Il predicato non deve essere per forza anonimo: va bene anche una funzione con nome, anche ricorsiva, come una `potenza_di_due`.

A volte i vincoli non bastano a fissare un tipo concreto:

```ocaml
let id x = x;;   (* val id : 'a -> 'a = <fun> *)
id 4;;           (* - : int = 4 *)
id "ciao";;      (* - : string = "ciao" *)
```

`id` è *polimorfa*: si applica a argomenti di tipi diversi. `'a` (si legge "alfa") è una *variabile di tipo*: al suo posto può andare un tipo qualsiasi, ma se compare più volte va sostituita sempre con lo stesso tipo. Quindi `'a -> 'a` dice che il risultato ha lo stesso tipo dell'argomento, qualunque sia. A ogni applicazione OCaml *specializza* `'a` sul tipo dell'argomento.

```ocaml
let first_if_true test first second = if test first then first else second;;
```

Vincoli: `TEST = FIRST -> bool` (la condizione), `FIRST = SECOND` (i due rami), `RIS = FIRST` (il ramo `then`). Nessuno fissa un tipo concreto: `('a -> bool) -> 'a -> 'a -> 'a`.

#nota[Basta un ramo concreto per cambiare tutto: con `then 2` al posto di `then first` si aggiunge `RIS = SECOND = int`, mentre `FIRST` resta libero. Il tipo diventa `('a -> bool) -> 'a -> int -> int`.]

```ocaml
let maggiore x y = if x > y then x else y;;
(* val maggiore : 'a -> 'a -> 'a = <fun> *)
maggiore 6 5;;                 (* - : int = 6 *)
maggiore "albero" "gatto";;    (* - : string = "gatto" *)
maggiore (fun x -> x) (fun x -> x + 1);;
(* Exception: Invalid_argument "compare: functional value". *)
```

`>` si può usare su qualunque tipo, quindi `x` e `y` sono `'a` (lo stesso per tutti e due). Con due funzioni il controllo dei tipi passa, ma *durante l'esecuzione* il confronto solleva un'*eccezione* (una situazione anomala a tempo di esecuzione). Anche `(fun x -> x) = (fun y -> y)` fa lo stesso. Non è un limite di OCaml: due funzioni $f$ e $g$ sono uguali se $f(x) = g(x)$ per ogni $x$, e un algoritmo che lo decidesse risolverebbe il problema della fermata. È *indecidibile*.

Un'*annotazione di tipo* `(x : int)` dice al compilatore il tipo voluto, e può restringere il polimorfismo (le parentesi sono obbligatorie):

```ocaml
let maggiore (x : int) (y : int) : int = if x > y then x else y;;
(* val maggiore : int -> int -> int = <fun> *)
```

Così `maggiore` non si può più applicare a funzioni. Per averla su `int` e su `string`, e non su altro, servono due funzioni con *nomi diversi* (`maggiore_int`, `maggiore_string`): OCaml non ha *overloading*, cioè non permette due funzioni con lo stesso nome che differiscono per numero o tipo dei parametri (in Java e C\# si può).

Anche TypeScript ha la type inference con tipi polimorfi, ma fa scelte diverse:

#align(center, table(columns: 3, align: left,
  [], [TypeScript], [OCaml],
  [Identità], [`id(x: any): any` spegne ogni controllo (accetta `12 * id("hello")`) e non dice che il risultato ha il tipo dell'argomento], [`'a -> 'a`],
  [Polimorfismo], [esplicito: con i _generics_ si scrive `id<T>(x: T): T`], [implicito: `'a` lo deduce il compilatore],
  [Due tipi possibili], [tipo unione `number | string`: accetta `maggiore(3, "hello")`, e rifiuta `maggiore(2, 4) / 2` perché non sa se il risultato è un numero], [due funzioni distinte],
))

OCaml è più rigoroso: vuole il tipo preciso (anche polimorfo) di ogni espressione, quindi niente conversioni implicite né tipi "ambigui". TypeScript lascia più libertà per restare vicino a JavaScript, e qualche errore in più passa. Nessuno dei due è "migliore": hanno scopi diversi.

= Liste e pattern matching

#obiettivi(
  [costruire liste con `[ ; ]`, `::` e `@` e dire il loro tipo],
  [dire se un valore fa match con un pattern, e scrivere `match` esaustivi],
  [scrivere funzioni ricorsive su liste, anche con l'accumulatore (ricorsione in coda)],
  [usare `exists`, `for_all`, `filter`, `map`, `fold_right`, `fold_left`, e scegliere fra le due fold],
)

== Liste

Una *lista* è una sequenza finita e *immutabile* di valori *dello stesso tipo*. Si scrive fra parentesi quadre, con gli elementi separati da `;`. Se gli elementi hanno tipo `T`, la lista ha tipo `T list`. Immutabile vuol dire che non si possono aggiungere, togliere o cambiare elementi: ogni operazione legge una lista e ne costruisce una nuova.

```ocaml
[3; 5; -1; 9];;                   (* - : int list = [3; 5; -1; 9] *)
["cane"; "gatto"];;               (* - : string list *)
[(1, "lun"); (2, "mar")];;        (* - : (int * string) list *)
[[1; 2]; [2; 1]];;                (* - : int list list *)
[];;                              (* - : 'a list = [] *)
```

La lista vuota `[]` ha tipo `'a list`: non ha elementi che fissino il tipo.

#nota[`[1, 2]` non è una lista di due interi: la virgola costruisce una coppia, quindi è una lista con *un solo* elemento, `(1, 2)`, di tipo `(int * int) list`.]

Il tipo di una lista si trova *unificando* i tipi degli elementi: si cerca il tipo più generale compatibile con tutti.

```ocaml
[[]; []];;         (* - : 'a list list *)
[[]; []; [3]];;    (* - : int list list *)
[(fun x -> x + 1); (fun x -> x)];;   (* - : (int -> int) list *)
```

Finché ci sono solo liste vuote il tipo resta generico; appena entra `[3]` diventa `int list list`. Allo stesso modo `fun x -> x` (tipo `'a -> 'a`) si specializza in `int -> int`. Con tre funzioni:

```ocaml
let f x y = 3;;       (* val f : 'a -> 'b -> int *)
let g x y = x + 1;;   (* val g : int -> 'a -> int *)
let h x y = y + 1;;   (* val h : 'a -> int -> int *)
[f; g];;              (* - : (int -> 'a -> int) list *)
[g; h];;              (* - : (int -> int -> int) list *)
```

`g` fissa il primo parametro a `int`, `h` il secondo: insieme li fissano tutti e due. Il tipo trovato così si chiama *most general unifier* (MGU): il tipo più generale che rispetta tutti i vincoli.

Il costruttore fondamentale è *`::`* (_cons_): se `l` ha tipo `T list` ed `e` ha tipo `T`, `e :: l` è la lista che ha `e` come primo elemento, seguito dagli elementi di `l`.

```ocaml
4 :: [3; 2; 1];;           (* - : int list = [4; 3; 2; 1] *)
1 :: 2 :: 3 :: 4 :: [];;   (* - : int list = [1; 2; 3; 4] *)
```

`[1; 2; 3; 4]` è zucchero per `1 :: (2 :: (3 :: (4 :: [])))`, e le parentesi si tolgono perché `::` associa a destra. Si vede la natura *induttiva* delle liste: si parte da `[]` e si mette davanti 4, poi 3, poi 2, poi 1.

Si dice spesso che `::` "aggiunge un elemento in testa", ma non è esatto: le liste sono immutabili, e `e :: l` è una lista *nuova*. Eppure non copia niente. Le liste sono *liste concatenate*: ogni nodo contiene un elemento e un puntatore al nodo dopo; la croce è la fine della lista.

#let nodi(xs, x0, y, ultimo: true) = {
  import draw: *
  for (i, v) in xs.enumerate() {
    let x = x0 + i * 1.7
    rect((x, y), (x + 0.75, y + 0.6))
    content((x + 0.375, y + 0.3), v)
    rect((x + 0.75, y), (x + 1.1, y + 0.6))
    if i < xs.len() - 1 {
      line((x + 0.925, y + 0.3), (x + 1.7, y + 0.3), mark: (end: "stealth"))
    } else if ultimo {
      line((x + 0.75, y), (x + 1.1, y + 0.6)); line((x + 0.75, y + 0.6), (x + 1.1, y))
    }
  }
}
#let nome(p, t) = {
  import draw: *
  content(p, text(9pt, fill: red, raw(t)))
}

#figura(canvas(length: 1cm, {
  import draw: *
  nodi(([1],), 0, 0, ultimo: false)
  line((0.925, 0.3), (1.7, 0.3), mark: (end: "stealth"))
  nodi(([2], [3], [4]), 1.7, 0)
  nome((0.375, -0.35), "lis2"); nome((2.075, -0.35), "lis1")
}), [`lis1 = [2; 3; 4]` e `lis2 = 1 :: lis1`: il nuovo nodo punta alla vecchia lista])

Le due liste *condividono* i nodi di `lis1`. Siccome nessuno può modificarli, per il programmatore è come se fossero due liste distinte, e non si spreca memoria.

La *concatenazione* `lis1 @ lis2` (_append_) mette in fila due liste. Questa volta la prima lista *viene copiata*, nodo per nodo:

```ocaml
[1; 2; 3] @ [4; 5; 6];;    (* - : int list = [1; 2; 3; 4; 5; 6] *)
```

#figura(canvas(length: 1cm, {
  import draw: *
  nodi(([1], [2], [3]), 0, 1.4)
  nodi(([4], [5], [6]), 5.4, 1.4)
  nodi(([1], [2], [3]), 0, 0, ultimo: false)
  line((4.325, 0.3), (5.4, 1.5), mark: (end: "stealth"))
  nome((0.375, 2.35), "lis1"); nome((5.775, 2.35), "lis2"); nome((0.375, -0.35), "lis3")
}), [`lis3 = lis1 @ lis2`: i nodi di `lis1` sono copiati, l'ultima copia punta a `lis2`])

Se invece `@` cambiasse il puntatore dell'ultimo nodo di `lis1` per farlo puntare a `lis2`, `lis1` non sarebbe più `[1; 2; 3]`: la distruggerebbe.

Il modulo `List` della libreria standard ha molte funzioni pronte, che si chiamano con `List.` davanti:

#align(center, table(columns: 3, align: left,
  [Funzione], [Cosa fa], [Esempio],
  [`List.length`], [lunghezza], [`List.length [5; 2; 1]` = `3`],
  [`List.hd`], [_head_, il primo elemento], [`List.hd [5; 2; 1]` = `5`],
  [`List.tl`], [_tail_, la lista senza il primo], [`List.tl [5; 2; 1]` = `[2; 1]`],
  [`List.rev`], [rovescia], [`List.rev [5; 2; 1]` = `[1; 2; 5]`],
))

== Pattern matching <pattern>

Per leggere gli elementi di una lista bisogna *destrutturarla*. Lo strumento è il *pattern matching*, che funziona su tutti i tipi, non solo sulle liste:

```ocaml
match EXP with
| P_1 -> EXP_1
| P_2 -> EXP_2
...
| P_N -> EXP_N
```

Ogni riga `P_i -> EXP_i` è un *ramo* (o caso). Il valore di `EXP` si confronta con i pattern *dall'alto in basso*: al primo `P_i` che *combacia* (fa _match_) si valuta `EXP_i`, e gli altri rami si ignorano. Un pattern è uno di questi:
- un valore di un tipo di base (non una funzione): `true`, `0`, `2.3`, `'a'`, `"abc"`;
- una variabile: `x`, `y`…;
- una tupla di pattern: `(P_1, ..., P_N)`;
- una lista di lunghezza fissa: `[P_1; ...; P_N]`;
- una lista con cons: `P_1 :: P_2`;
- la *wildcard* `_`, che combacia con tutto.

#teorema[Match][Un valore $v$ fa match con un pattern $P$ se $P$ è `_`, oppure $P = v$, oppure si possono sostituire le variabili di $P$ con dei valori ottenendo $P'$ con $P' = v$.]

In pratica $P$ "copre" la forma di $v$, e intanto lega le sue variabili ai pezzi di $v$ corrispondenti.

#align(center, table(columns: 3, align: left,
  [Pattern], [Fanno match], [Non fanno match],
  [`1`], [`1`], [`0`, `2`, `3`],
  [`(3, 2)`], [`(3, 2)`], [`(2, 3)`, `(4, 2)`],
  [`(x, y)`], [`(3, 2)`, `(2, 3)`, `(4, 2)`], [`(1, 3, 2)`, `(1, 4, 3, 2)`],
  [`(x, 2)`], [`(3, 2)`, `(4, 2)`, `("ciao", 2)`], [`(2, 3)`, `(4, 2, 1)`],
  [`[]`], [`[]`], [`[3]`, `[1; 5]`, `['a'; 'b'; 'c']`],
  [`[3]` o `3 :: []`], [`[3]`], [`[]`, `[1; 5]`, `['a'; 'b'; 'c']`],
  [`3 :: x`], [`[3]`, `[3; 4; 5]`], [`[]`, `[1; 5]`, `['a'; 'b'; 'c']`],
  [`x :: y`], [`[3]`, `[3; 4; 5]`, `[1; 5]`, `['a'; 'b'; 'c']`], [`[]`],
  [`_`], [`5`, `true`, `"abc"`, `(3, "hello")`, `[3; 2; 4]`, `[]`], [],
))

In `x :: lis'` la variabile `x` è il *primo elemento* e `lis'` è *la lista degli altri*: in una lista di interi `x` è un `int` e `lis'` una `int list`. Una funzione con il `match` si legge come una funzione definita per casi:

```ocaml
let rec fibonacci n = match n with
  | 0 -> 0
  | 1 -> 1
  | _ -> fibonacci (n - 1) + fibonacci (n - 2);;   (* tutti gli altri *)
let my_or x y = match (x, y) with        (* match su una coppia *)
  | (false, false) -> false
  | _ -> true;;
let inizia_con_zero lis = match lis with
  | 0 :: _ -> true
  | _ -> false;;
let lunghezza_uno lis = match lis with
  | _ :: [] -> true
  | _ -> false;;
```

È bene (ma non obbligatorio) che i pattern siano *esaustivi*: ogni valore possibile deve combaciare con almeno un ramo. Se manca un caso il compilatore dà un _warning_ (un avviso: compila lo stesso) con un esempio di valore scoperto; un warning arriva anche per un ramo che non può mai scattare, per esempio uno messo dopo `_`.

```ocaml
let giorno n = match n with
  | 1 -> "lunedì" | 2 -> "martedì" | 3 -> "mercoledì" | 4 -> "giovedì"
  | 5 -> "venerdì" | 6 -> "sabato" | 7 -> "domenica";;
(* Warning 8: this pattern-matching is not exhaustive.
   Here is an example of a case that is not matched: 0 *)
giorno 7;;   (* - : string = "domenica" *)
giorno 8;;   (* Exception: Match_failure ... *)
```

Quando una funzione fa subito il `match` sul suo argomento si usa *`function`*, che prende i pattern al posto del parametro (il nome del parametro sparisce). Con più parametri, `function` fa il match sull'ultimo:

```ocaml
let is_empty = function
  | [] -> true
  | _ -> false;;
let is_first n = function       (* val is_first : 'a -> 'a list -> bool *)
  | [] -> false
  | x :: _ -> x = n;;
```

Fin qui il `match` sembra uno `switch`, solo che controlla anche la *forma* del valore (per esempio "lista non vuota"). La vera forza è un'altra: intanto che controlla, *smonta* la struttura e dà un nome ai pezzi, cioè lega le variabili del pattern, e le si può usare nel ramo. Per le tuple basta il `let`, che fa un match implicito:

```ocaml
let primo (x, _) = x;;   (* val primo : 'a * 'b -> 'a *)
let testa lis = match lis with x :: _ -> x;;
(* Warning 8: ... not matched: []   val testa : 'a list -> 'a *)
```

`testa` è una *funzione parziale*: funziona solo sulle liste non vuote.

Più pattern con la stessa espressione si *accorpano* con `|`. Le variabili però devono comparire in *tutti* i pattern accorpati:

```ocaml
let giorno_festivo n = match n with
  | 1 | 2 | 3 | 4 | 5 -> "feriale"
  | 6 | 7 -> "festivo"
  | _ -> "errore";;
let somma_coppia c = match c with
  | (x, 0) | (0, x) -> x
  | (x, y) -> x + y;;
let lunghezza_uno_due lis = match lis with
  | x :: [] | x :: y :: [] -> true
  (* Error: Variable y must occur on both sides of this | pattern *)
  | _ -> false;;
```

Se fosse permesso, in `x :: [] | x :: y :: [] -> x + y` la `y` non avrebbe valore quando la lista ha un solo elemento. Il compilatore controlla i pattern senza guardare l'espressione dopo `->`, quindi segnala l'errore anche qui, dove il ramo restituisce solo `true`. Si risolve separando i due rami, oppure, visto che le variabili non servono, con le wildcard: `| _ :: [] | _ :: _ :: [] -> true`.

#esercizio(12)[Determinare il tipo delle seguenti espressioni OCaml:
```ocaml
(* A *) (3, 10.2) :: (3, 2.1) :: [];;
(* B *) [] :: [];;
(* C *) fun x -> fun y -> (x, if y > 0 then x else y < 10);;
(* D *) (fun x -> fun y -> x + y) 10;;
(* E *) let f x y z =
          if x then []
          else match y with
          | (0, 0) -> []
          | (n1, n2) -> z :: [n1; n2];;
(* F *) let g x y z =
          let k = 10 in
          if x = k then y
          else [z];;
```]

== Ricorsione sulle liste

Il pattern matching serve a scrivere funzioni ricorsive sulle liste. Una lista ha due forme, e la funzione ha un ramo per ciascuna, come una dimostrazione per induzione:
- *caso base*: la lista vuota `[]`;
- *caso ricorsivo*: `x :: lis'`, dove la funzione si richiama su `lis'`, più corta.

```ocaml
let rec length lis = match lis with
  | [] -> 0
  | _ :: lis' -> 1 + length lis';;
let rec somma lis = match lis with
  | [] -> 0
  | x :: lis' -> x + somma lis';;
(* val contains : 'a -> 'a list -> bool *)
let rec contains x lis = match lis with
  | [] -> false
  | y :: lis' -> if y = x then true else contains x lis';;
```

Anche `@` si scrive così: se la prima lista è vuota il risultato è la seconda; altrimenti si mette il primo elemento davanti alla concatenazione del resto.

```ocaml
let rec append lis1 lis2 = match lis1 with
  | [] -> lis2
  | x :: lis1' -> x :: append lis1' lis2;;
```

Ogni chiamata stacca un elemento da `lis1` e lo tiene in sospeso; quando `lis1` è vuota, i risultati risalgono:

```
append [1; 2] [3; 4] = 1 :: append [2] [3; 4]
                     = 1 :: (2 :: append [] [3; 4])
                     = 1 :: (2 :: [3; 4])
                     = [1; 2; 3; 4]
```

Il tempo è *lineare* nella lunghezza di `lis1`: una chiamata per elemento. Per *rovesciare* una lista l'idea più diretta è "rovescio il resto e metto il primo in fondo":

```ocaml
let rec rev lis = match lis with
  | [] -> []
  | x :: lis' -> rev lis' @ [x];;
```

```
rev [1; 2; 3] = rev [2; 3] @ [1]
              = (rev [3] @ [2]) @ [1]
              = ((rev [] @ [3]) @ [2]) @ [1]
              = ([3] @ [2]) @ [1] = [3; 2] @ [1] = [3; 2; 1]
```

Funziona, ma è lenta: ogni `@` ricopia tutta la parte già rovesciata. Meglio un secondo parametro, l'*accumulatore*, che parte da `[]` e costruisce il risultato passo per passo:

```ocaml
let rev lis =
  let rec rev_accum lis1 lis2 = match lis1 with
    | [] -> lis2
    | x :: lis1' -> rev_accum lis1' (x :: lis2)
  in rev_accum lis [];;
```

A ogni chiamata il primo elemento di `lis1` passa in testa a `lis2`, quindi gli elementi arrivano in ordine inverso:

```
rev_accum [1; 2; 3] []
→ rev_accum [2; 3] [1]
→ rev_accum [3] [2; 1]
→ rev_accum [] [3; 2; 1]  =  [3; 2; 1]
```

In `rev_accum` la chiamata ricorsiva è *l'ultima operazione*: dopo non resta niente da fare. Una funzione così si dice *ricorsiva in coda* (_tail recursive_). In `somma`, invece, dopo la chiamata resta da fare `x + ...`. Il vantaggio è a tempo di esecuzione: ogni chiamata di funzione occupa nello *stack* (la pila della memoria) un *record di attivazione* con i suoi parametri, ma se non resta lavoro in sospeso basta *un solo* record, riusato a ogni chiamata. Il programma è più veloce, usa meno memoria, e soprattutto non rischia lo *stack overflow* (lo stack pieno, che ferma il programma) su liste lunghe. L'accumulatore è il modo tipico di scrivere funzioni ricorsive efficienti sulle liste.

Un esempio più grosso: l'*area di un poligono* qualsiasi, date le coordinate dei vertici in senso antiorario. Il metodo:
+ si copia il primo vertice in fondo alla lista;
+ si somma ogni $x$ per la $y$ del vertice dopo: $sum x_i y_(i+1)$;
+ si somma ogni $y$ per la $x$ del vertice dopo: $sum y_i x_(i+1)$;
+ l'area è la differenza delle due somme, divisa per 2.

#let poli = ((-3, -2), (-1, 4), (6, 1), (3, 10), (-4, 9))
#let poli-c = poli + (poli.at(0),)
#let s1 = range(5).map(i => poli-c.at(i).at(0) * poli-c.at(i + 1).at(1))
#let s2 = range(5).map(i => poli-c.at(i).at(1) * poli-c.at(i + 1).at(0))

#align(center, grid(columns: 2, column-gutter: 2em, align: horizon,
  canvas(length: 0.28cm, {
    import draw: *
    line((-6, 0), (8, 0), stroke: grigio, mark: (end: "stealth"))
    line((0, -4), (0, 12), stroke: grigio, mark: (end: "stealth"))
    line(..poli, close: true, stroke: 1pt + blu, fill: rgb("#eef4ff"))
    for (k, (x, y)) in poli.enumerate() {
      circle((x, y), radius: 0.18, fill: black)
      content((x + 0.4, y), anchor: "west", box(fill: white, inset: 1pt, text(8pt)[#"ABCDE".at(k) #h(0.1em) (#x, #y)]))
    }
  }),
  table(columns: 4, align: (left, right, right, right),
    [Vertice], [$x_i$, $y_i$], [$x_i y_(i+1)$], [$y_i x_(i+1)$],
    ..range(5).map(i => ([#"ABCDE".at(i)], [#poli.at(i).at(0), #poli.at(i).at(1)], [#s1.at(i)], [#s2.at(i)])).flatten(),
    [], [*somma*], [*#s1.sum()*], [*#s2.sum()*],
  ),
))

L'area è $(#s1.sum() - (#s2.sum())) \/ 2 = #((s1.sum() - s2.sum()) / 2)$. Nel codice, invece di copiare il primo vertice in fondo (con `@`, che copierebbe tutta la lista), lo si passa come parametro `(x0, y0)` e lo si usa quando si arriva all'ultimo vertice. Le due somme si fanno in un unico passaggio, portandosi dietro una *coppia* di risultati:

```ocaml
let area pol =
  let rec calcolo (x0, y0) lis = match lis with
    | [] -> (1, 1)                       (* non succede mai *)
    | (x, y) :: [] -> (x * y0, y * x0)   (* ultimo: il dopo è il primo *)
    | (x1, y1) :: (x2, y2) :: lis' ->
        let (ris1, ris2) = calcolo (x0, y0) ((x2, y2) :: lis') in
        (ris1 + x1 * y2, ris2 + y1 * x2)
  in
  match pol with
  | [] -> 0.
  | p0 :: _ -> let (ris1, ris2) = calcolo p0 pol in
               float_of_int (ris1 - ris2) /. 2.;;
area [(-3, -2); (-1, 4); (6, 1); (3, 10); (-4, 9)];;   (* - : float = 60. *)
```

- Il ramo `[]` di `calcolo` non scatta mai (la si chiama su liste che hanno almeno un elemento), e c'è solo per rendere il match esaustivo.
- Il terzo pattern guarda *due* vertici consecutivi, `(x1, y1)` e `(x2, y2)`, e nella chiamata ricorsiva rimette in testa il secondo.
- Somme e prodotti sono su `int`; la divisione si fa su `float`, perché l'area può non essere intera.

#esercizio(13)[Scrivere una funzione ricorsiva `somma_positivi` che, data una lista `lis` di interi, restituisce la somma degli elementi positivi. Ad esempio, `somma_positivi [3; 0; -1; 2; -4]` restituisce `5`.] <es-13>

#esercizio(14)[Scrivere una funzione ricorsiva `somma_liste` che, date due liste `[x1; ...; xn]` e `[y1; ...; yn]` di uguale lunghezza, restituisca la lista `[x1+y1; ...; xn+yn]`. Se le liste hanno lunghezze diverse, la funzione restituisce la lista vuota.]

#esercizio(15)[Scrivere una funzione ricorsiva `parentesi_bilanciate` che, data una lista `lis` di caratteri, restituisce `true` se la lista contiene una sequenza di caratteri `'('` e `')'` bilanciata. Ad esempio, `parentesi_bilanciate ['('; '('; ')'; '('; '('; ')'; ')'; ')']` restituisce `true`, mentre `parentesi_bilanciate ['('; '('; ')'; ')'; ')']` restituisce `false`.] <es-15>

== Funzioni di ordine superiore sulle liste

Sulle liste l'unico modo di ripetere un calcolo è la ricorsione, ma molte funzioni ricorsive hanno *lo stesso schema*. Queste tre differiscono solo per la condizione:

```ocaml
let rec contiene_zero lis = match lis with
  | [] -> false
  | x :: lis' -> if x = 0 then true else contiene_zero lis';;
let rec contiene_positivo lis = ...   (* uguale, con x > 0 *)
let rec contiene_pari lis = ...       (* uguale, con x mod 2 = 0 *)
```

Tutte scorrono la lista, controllano una condizione su ogni elemento, restituiscono `true` al primo che la soddisfa e `false` se arrivano in fondo. L'idea: la condizione diventa un *predicato* `p : 'a -> bool` passato come parametro, e lo schema si scrive una volta sola.

```ocaml
(* val exists : ('a -> bool) -> 'a list -> bool *)
let rec exists p lis = match lis with
  | [] -> false
  | x :: lis' -> if p x then true else exists p lis';;
let contiene_zero lis = exists (fun x -> x = 0) lis;;
let contiene_pari lis = exists (fun x -> x mod 2 = 0) lis;;
let contains x lis = exists (fun y -> x = y) lis;;
```

La ricorsione adesso è nascosta dentro `exists`. In `contains` la funzione `fun y -> x = y` usa `x`, che non è un suo parametro: è una sua variabile libera, che viene da fuori. Quello che `exists` riceve è allora una *chiusura* (_closure_): la funzione *insieme all'ambiente* in cui è stata creata, cioè ai valori delle sue variabili libere. La chiusura "ricorda" il valore di `x` e può confrontarlo con ogni `y`. Lo stesso si ottiene con l'applicazione parziale: con `let uguale x y = x = y`, si scrive `exists (uguale x) lis`.

Con lo stesso metodo si scrivono le altre operazioni frequenti. *`forall`* controlla che *tutti* gli elementi soddisfino il predicato:

```ocaml
(* val forall : ('a -> bool) -> 'a list -> bool *)
let rec forall p lis = match lis with
  | [] -> true
  | x :: lis' -> if p x then forall p lis' else false;;
let tutti_pari lis = forall (fun x -> x mod 2 = 0) lis;;
```

*`filter`* tiene solo gli elementi che soddisfano il predicato:

```ocaml
(* val filter : ('a -> bool) -> 'a list -> 'a list *)
let rec filter p lis = match lis with
  | [] -> []
  | x :: lis' -> if p x then x :: filter p lis' else filter p lis';;
filter (fun x -> x mod 2 = 0) [1; 2; 3; 4];;   (* - : int list = [2; 4] *)
```

```
filter pari [1; 2; 3; 4] = filter pari [2; 3; 4]     1 è dispari: scartato
                         = 2 :: filter pari [3; 4]   2 è pari: tenuto
                         = 2 :: filter pari [4]
                         = 2 :: 4 :: filter pari []
                         = 2 :: 4 :: []  =  [2; 4]
```

*`map`* applica la stessa funzione `f` a ogni elemento: `map f [x1; ...; xn] = [f x1; ...; f xn]`. Qui non serve un predicato ma una funzione qualsiasi, che può anche cambiare il tipo degli elementi:

```ocaml
(* val map : ('a -> 'b) -> 'a list -> 'b list *)
let rec map f lis = match lis with
  | [] -> []
  | x :: lis' -> f x :: map f lis';;
map (fun x -> x + 1) [1; 2; 3];;      (* - : int list = [2; 3; 4] *)
map (fun (x, y) -> x) [(3, 2); (4, 7); (9, 2)];;
(* - : int list = [3; 4; 9] *)
```

Queste funzioni guardano ogni elemento per conto suo. Spesso invece bisogna *combinare* tutti gli elementi in un unico risultato: la somma, il minimo e il massimo, la concatenazione di stringhe. In JavaScript si userebbe un ciclo con una variabile che accumula il risultato parziale:

```js
function somma(a) {
  var s = 0
  for (var i in a) s += a[i]
  return s
}
```

In un linguaggio funzionale non c'è una variabile da aggiornare: il risultato parziale *viaggia lungo la ricorsione*, come valore restituito o come parametro. Nella `somma` ricorsiva di prima, ogni chiamata restituisce la somma della lista dall'elemento corrente in fondo:

```
somma [3; 2; 4] = 3 + somma [2; 4]
                = 3 + (2 + somma [4])
                = 3 + (2 + (4 + somma []))
                = 3 + (2 + (4 + 0))
```

Gli elementi si sommano *dall'ultimo al primo*, cioè da destra. Scrivendo `+` in forma prefissa è `(+) 3 ((+) 2 ((+) 4 0))`; chiamando $f$ l'operazione e $a$ il valore del caso base, lo schema è $f x_1 (f x_2 (... (f x_n a)))$. È la *`fold_right`*:

```ocaml
let rec fold_right f lis a = match lis with
  | [] -> a
  | x :: lis' -> f x (fold_right f lis' a);;
(* val fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b *)
let somma lis = fold_right (+) lis 0;;
```

I tre parametri: `f`, la funzione da applicare a ogni passo; `lis`, la lista; `a`, il risultato per la lista vuota (sta *a destra* della lista). A ogni passo `f` riceve l'elemento corrente e il risultato già calcolato sul resto della lista. Altri esempi:

```ocaml
let concat lis = fold_right (^) lis "";;
concat ["abc"; "def"; "gh"];;     (* - : string = "abcdefgh" *)
let minimo_massimo lis =
  let f x (min, max) =
    if x < min then (x, max) else if x > max then (min, x) else (min, max)
  in match lis with
  | [] -> (0, 0)
  | x :: lis' -> fold_right f lis' (x, x);;
minimo_massimo [3; 2; 4];;        (* - : int * int = (2, 4) *)
```

In `minimo_massimo` si porta dietro una *coppia* (minimo e massimo finora). Per il caso base non c'è un valore giusto per tutte le liste, quindi si stacca il primo elemento e si parte da `(x, x)`.

La somma si può scrivere anche al contrario, con il risultato parziale passato *come parametro* (un accumulatore, che parte da 0):

```ocaml
let rec somma a lis = match lis with
  | [] -> a
  | x :: lis' -> somma (a + x) lis';;
```

```
somma 0 [3; 2; 4] = somma (0 + 3) [2; 4]
                  = somma ((0 + 3) + 2) [4]
                  = somma (((0 + 3) + 2) + 4) []  =  9
```

Ora gli elementi si sommano *dal primo all'ultimo*, cioè da sinistra, e la funzione è ricorsiva in coda. Il disegno mostra lo stack nei due casi: a sinistra ogni chiamata lascia in sospeso un'addizione, e i risultati (in rosso) risalgono; a destra non c'è niente in sospeso, il risultato scende già fatto e basta un record riusato.

#figura(canvas(length: 1cm, {
  import draw: *
  let cs = ("somma [3; 2; 4]", "somma [2; 4]", "somma [4]", "somma []")
  let sosp = ("3 + □", "2 + □", "4 + □", "")
  let ris = ("9", "6", "4", "0")
  for i in range(4) {
    let y = -i * 1.1
    rect((0, y), (3.6, y + 0.75), fill: if i == 3 { rgb("#eefaf2") } else { white })
    content((1.8, y + 0.52), text(8pt, raw(cs.at(i))))
    content((1.8, y + 0.2), text(8pt, fill: gray, sosp.at(i)))
    if i < 3 { line((1.2, y), (1.2, y - 0.35), mark: (end: "stealth")) }
    content((4.2, y + 0.37), text(9pt, fill: red, ris.at(i)))
    if i > 0 { line((4.2, y + 0.6), (4.2, y + 1.25), stroke: red, mark: (end: "stealth")) }
  }
  let ca = ("somma 0 [3; 2; 4]", "somma 3 [2; 4]", "somma 5 [4]", "somma 9 []")
  for i in range(4) {
    let y = -i * 1.1
    rect((6.3, y), (10.2, y + 0.75), stroke: if i == 0 { black } else { (dash: "dashed", paint: gray) })
    content((8.25, y + 0.37), text(8pt, raw(ca.at(i))))
    if i < 3 { line((8.25, y), (8.25, y - 0.35), mark: (end: "stealth")) }
  }
  content((10.8, -2.93), text(9pt, fill: red)[9])
  content((1.8, 1.2), text(9pt)[*non in coda*: 4 record])
  content((8.25, 1.2), text(9pt)[*in coda*: 1 record riusato])
}), [Lo stack di `somma [3; 2; 4]` nelle due versioni; in grigio l'addizione in sospeso])

Lo schema è $f (... (f (f a x_1) x_2) ...) x_n$, ed è la *`fold_left`*:

```ocaml
let rec fold_left f a lis = match lis with
  | [] -> a
  | x :: lis' -> fold_left f (f a x) lis';;
(* val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a *)
let somma lis = fold_left (+) 0 lis;;
let stringa_piu_lunga lis =
  let f s x = if String.length x > String.length s then x else s in
  fold_left f "" lis;;
stringa_piu_lunga ["ciao"; "hello"; "hi"];;   (* - : string = "hello" *)
```

Qui il valore iniziale `a` sta *a sinistra* della lista, e anche in `f` l'accumulatore è il primo parametro. Regola per ricordarlo: in `fold_X` l'accumulatore sta a `X` (_left_ o _right_), sia fra i parametri della fold sia fra quelli di `f`. Gli alberi delle due fold su `[x1; x2; x3]`:

#align(center, grid(columns: 2, column-gutter: 4em, align: bottom,
  [#albero(([$f$], [$x_1$], ([$f$], [$x_2$], ([$f$], [$x_3$], [$a$])))) #align(center, text(9pt)[`fold_right f [x1; x2; x3] a`])],
  [#albero(([$f$], ([$f$], ([$f$], [$a$], [$x_1$]), [$x_2$]), [$x_3$])) #align(center, text(9pt)[`fold_left f a [x1; x2; x3]`])],
))

Le due fold *non sono intercambiabili*:

#align(center, table(columns: 3, align: left,
  [], [`fold_right f lis a`], [`fold_left f a lis`],
  [Ordine], [dall'ultimo elemento al primo], [dal primo all'ultimo],
  [Tipo di `f`], [`'a -> 'b -> 'b`: elemento, accumulatore], [`'a -> 'b -> 'a`: accumulatore, elemento],
  [In coda?], [no: dopo la chiamata resta da applicare `f`], [sì: un solo record nello stack],
  [Con `(-)` su `[1; 2; 3]`, da 0], [$1 - (2 - (3 - 0)) = 2$], [$((0 - 1) - 2) - 3 = -6$],
  [Con `f` che fa `x :: l`, da `[]`], [`[1; 2; 3]`: la copia], [`[3; 2; 1]`: la rovescia],
))

Con `(-)` i risultati cambiano perché la sottrazione non è associativa. Nell'ultima riga `::` mette sempre in testa: `fold_right` comincia da 3 e mette davanti 2 e poi 1, quindi ricostruisce la lista nello stesso ordine; `fold_left` comincia da 1 e ci mette davanti 2 e poi 3, quindi la rovescia.

Altri due esempi. `somma_dal_fondo` costruisce la lista delle somme a partire dal fondo: se la lista accumulata non è vuota, somma l'elemento corrente al suo primo elemento e mette il risultato in testa.

```ocaml
let somma_dal_fondo lis =
  let f x l = match l with
    | [] -> [x]
    | x' :: _ -> (x + x') :: l
  in fold_right f lis [];;
somma_dal_fondo [2; 2; 2; 2; 2];;   (* - : int list = [10; 8; 6; 4; 2] *)
```

`crescente` controlla se la lista è ordinata. `f` legge un elemento alla volta, ma qui serve confrontare due elementi *consecutivi*: allora nell'accumulatore, insieme al risultato `b`, si porta dietro l'elemento precedente `prec`.

```ocaml
let crescente lis =
  let f (prec, b) x = (x, b && prec <= x) in
  match lis with
  | [] -> true
  | x :: lis' -> let (_, b) = fold_left f (x, true) lis' in b;;
crescente [1; 4; 4; 6; 9];;   (* - : bool = true *)
crescente [3; 5; 4; 7; 9];;   (* - : bool = false *)
```

Con `fold_left`, che va dal primo all'ultimo, `prec` è proprio l'elemento prima; con `fold_right` sarebbe quello dopo. La fold scorre comunque *tutta* la lista, anche quando `b` è già `false`: per fermarsi alla prima coppia fuori ordine serve una ricorsione scritta a mano.

Tutte queste funzioni sono già nel modulo `List`: `List.exists`, `List.for_all`, `List.filter`, `List.map`, `List.fold_right`, `List.fold_left`. Ce ne sono molte altre, come `List.find`, `List.sort`, `List.partition`, `List.merge`, `List.mem`. Si combinano facilmente: per sommare i numeri pari di una lista moltiplicati per 3, prima si filtrano i pari, poi si moltiplicano, poi si sommano.

```ocaml
let somma_pari_per_3 lis =
  let pari = List.filter (fun x -> x mod 2 = 0) lis in
  let per_3 = List.map (fun x -> x * 3) pari in
  List.fold_left (+) 0 per_3;;
somma_pari_per_3 [1; 2; 3; 4; 5; 6];;   (* - : int = 36 *)
```

Anche l'area del poligono diventa più corta, ma più difficile da leggere:

```ocaml
let area pol =
  let f (x1, y1) ((x2, y2), (ris1, ris2)) =
    ((x1, y1), (ris1 + x1 * y2, ris2 + x2 * y1)) in
  let (_, (ris1, ris2)) = List.fold_right f pol (List.hd pol, (0, 0)) in
  float_of_int (ris1 - ris2) /. 2.;;
```

+ `fold_right` scorre i vertici dall'ultimo al primo. L'accumulatore è una coppia di coppie: il vertice *dopo* quello corrente, `(x2, y2)`, e le due somme parziali `(ris1, ris2)`.
+ Si parte da `List.hd pol`, il primo vertice, che fa da "vertice dopo" l'ultimo (senza copiarlo in fondo), e dalle somme `(0, 0)`.
+ A ogni passo `f` aggiunge i due prodotti e restituisce come "vertice dopo" quello corrente, che servirà al passo successivo.
+ Alla fine si butta il vertice (`_`) e si usano le due somme.

Le stesse funzioni ci sono, almeno in parte, anche in altri linguaggi: in JavaScript gli array hanno `map`, `filter` e `reduce` (che è la `fold_left`, per esempio `[1, 2, 3, 4].reduce((acc, x) => acc + x)` dà 10); in Java ci sono dalla versione 8, insieme alle lambda expressions.

#esercizio(16)[Risolvere l'#link(<es-13>)[esercizio 13] usando le funzioni `fold_left` o `fold_right`.]

#esercizio(17)[Risolvere l'#link(<es-15>)[esercizio 15] usando le funzioni higher-order su liste viste a lezione.]

#esercizio(18)[Utilizzando le funzioni higher-order su liste, scrivere una funzione `massimo_unico` che, data una lista `lis`, restituisca `true` se il valore massimo in `lis` è unico, e `false` se `lis` contiene più di una istanza del suo valore massimo, oppure se `lis` è vuota.]

#set heading(numbering: none)

= Riepilogo delle regole

Tutte le definizioni in un posto solo, per ripassare. Il nome di ogni regola è quello che si scrive negli alberi.

#text(9.5pt)[
#regole([λ-calcolo: sintassi, variabili libere, sostituzione], blu,
  rg(4, $e ::= x | lambda x. e | e e$, $"FV"(x) = {x}$, $"FV"(e_1 e_2) = "FV"(e_1) union "FV"(e_2)$, $"FV"(lambda x. e) = "FV"(e) without {x}$),
  rg(3, $x {x := e} = e$, [$y {x := e} = y$ se $y != x$], $(e_1 e_2){x := e} = (e_1 {x := e})(e_2 {x := e})$),
  rg(2, $(lambda x. e_1){x := e} = lambda x. e_1$, [$(lambda y. e_1){x := e} = lambda y. (e_1 {x := e})$ se $y != x$, $y in.not "FV"(e)$]),
  [$(lambda y. e_1){x := e} = lambda z. ((e_1 {y := z}){x := e})$ se $y != x$, $y in "FV"(e)$, $z$ fresca])

#regole([Riduzione standard, call-by-value, call-by-name], red,
  rg(2, ax($(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$, "App"), inf($e arrow.r e'$, $lambda x. e arrow.r lambda x. e'$, "App-Body")), rg(2, inf($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$, "App-1"), inf($e_2 arrow.r e'$, $e_1 e_2 arrow.r e_1 e'$, "App-2")),
  rg(3, ax($(lambda x. e_1) v_2 arrow.r e_1 {x := v_2}$, "CV-App"), inf($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$, "CV-App-1"), inf($e_2 arrow.r e'$, $v_1 e_2 arrow.r v_1 e'$, "CV-App-2")),
  rg(2, ax($(lambda x. e_1) e_2 arrow.r e_1 {x := e_2}$, "CN-App"), inf($e_1 arrow.r e'$, $e_1 e_2 arrow.r e' e_2$, "CN-App-1")))

#regole([Codifiche], verde,
  rg(3, $TRUE = lambda t. lambda f. t$, $FALSE = lambda t. lambda f. f$, $NOT = lambda b. b FALSE TRUE$),
  rg(2, $AND = lambda b. lambda c. b c FALSE$, $OR = lambda b. lambda c. b TRUE c$),
  rg(3, $IF = lambda c. lambda "then". lambda "else". c "then" "else"$, $C_n = lambda s. lambda z. s^n z$, $SUCC = lambda n. lambda s. lambda z. s (n s z)$),
  rg(3, $PLUS = lambda m. lambda n. lambda s. lambda z. m s (n s z)$, $TIMES = lambda m. lambda n. m (PLUS n) C_0$, $Y = lambda f. (lambda x. f (x x))(lambda x. f (x x))$))

#regole([Linguaggio di espressioni], blu,
  rg(3, $E ::= tt | ff | n | iff E thn E els E | succ E | pred E | isZero E$, $V ::= tt | ff | n$, $T ::= "Bool" | "Nat"$),
  rg(2, ax($iff tt thn E_1 els E_2 arrow.r E_1$, "If-True"), ax($iff ff thn E_1 els E_2 arrow.r E_2$, "If-False")),
  inf($E arrow.r E'$, $iff E thn E_1 els E_2 arrow.r iff E' thn E_1 els E_2$, "If-Cond"),
  rg(3, inf($E arrow.r E'$, $succ E arrow.r succ E'$, "Succ"), inf($m = n + 1$, $succ n arrow.r m$, "SuccNat"), ax($pred 0 arrow.r 0$, "PredZero")),
  rg(2, inf($E arrow.r E'$, $pred E arrow.r pred E'$, "Pred"), inf($n > 0 quad m = n - 1$, $pred n arrow.r m$, "PredNat")),
  rg(3, inf($E arrow.r E'$, $isZero E arrow.r isZero E'$, "IsZero"), ax($isZero 0 arrow.r tt$, "IsZeroZero"), inf($n > 0$, $isZero n arrow.r ff$, "IsZeroSucc")),
  rg(4, ax($tt : "Bool"$, "T-True"), ax($ff : "Bool"$, "T-False"), ax($n : "Nat"$, "T-Nat"), inf($E : "Bool" quad E_1 : T quad E_2 : T$, $iff E thn E_1 els E_2 : T$, "T-If")),
  rg(3, inf($E : "Nat"$, $succ E : "Nat"$, "T-Succ"), inf($E : "Nat"$, $pred E : "Nat"$, "T-Pred"), inf($E : "Nat"$, $isZero E : "Bool"$, "T-IsZero")))

#regole([λ-calcolo tipato (FUN) ed estensioni], verde,
  [$e ::= x | fun x : tau = e | Apply(e, e) | tt | ff | iff e thn e els e | n | e plus.o e | lett x = e inn e | fix e$],
  rg(2, $v ::= fun x : tau = e | tt | ff | n$, $tau ::= "Bool" | "Nat" | tau arrow.r tau$),
  ax($Apply(fun x : tau = e_1, v_2) arrow.r e_1 {x := v_2}$, "App"), rg(2, inf($e_1 arrow.r e_1'$, $Apply(e_1, e_2) arrow.r Apply(e_1', e_2)$, "App-1"), inf($e_2 arrow.r e_2'$, $Apply(v_1, e_2) arrow.r Apply(v_1, e_2')$, "App-2")),
  [If-True, If-False, If-Cond come nel linguaggio di espressioni],
  rg(3, inf($e_1 arrow.r e_1'$, $e_1 plus.o e_2 arrow.r e_1' plus.o e_2$, "Op-1"), inf($e_2 arrow.r e_2'$, $n_1 plus.o e_2 arrow.r n_1 plus.o e_2'$, "Op-2"), inf($delta_plus.o (n_1, n_2) = n$, $n_1 plus.o n_2 arrow.r n$, "Op-3")),
  rg(2, inf($e_1 arrow.r e_1'$, $lett x = e_1 inn e_2 arrow.r lett x = e_1' inn e_2$, "Let-1"), ax($lett x = v inn e_2 arrow.r e_2 {x := v}$, "Let-2")),
  rg(2, inf($e arrow.r e'$, $fix e arrow.r fix e'$, "Fix"), ax($fix (fun f : tau = e) arrow.r e {f := fix (fun f : tau = e)}$, "FixFun")),
  rg(4, ax($Gamma tack.r tt : "Bool"$, "T-True"), ax($Gamma tack.r ff : "Bool"$, "T-False"), ax($Gamma tack.r n : "Nat"$, "T-Nat"), inf($Gamma(x) = tau$, $Gamma tack.r x : tau$, "T-Var")),
  rg(2, inf($Gamma, x : tau_1 tack.r e : tau_2$, $Gamma tack.r fun x : tau_1 = e : tau_1 arrow.r tau_2$, "T-Fun"), inf($Gamma tack.r e_1 : tau_1 arrow.r tau_2 quad Gamma tack.r e_2 : tau_1$, $Gamma tack.r Apply(e_1, e_2) : tau_2$, "T-App")),
  rg(2, inf($Gamma tack.r e : "Bool" quad Gamma tack.r e_1 : tau quad Gamma tack.r e_2 : tau$, $Gamma tack.r iff e thn e_1 els e_2 : tau$, "T-If"), inf($Gamma tack.r e_1 : tau_1 quad Gamma tack.r e_2 : tau_2 quad plus.o : tau_1 times tau_2 arrow.r tau$, $Gamma tack.r e_1 plus.o e_2 : tau$, "T-Op")),
  rg(2, inf($Gamma tack.r e_1 : tau_1 quad Gamma, x : tau_1 tack.r e_2 : tau_2$, $Gamma tack.r lett x = e_1 inn e_2 : tau_2$, "T-Let"), inf($Gamma tack.r e : tau arrow.r tau$, $Gamma tack.r fix e : tau$, "T-Fix")))

#regole([Proprietà], red,
  [*Church-Rosser*: se $e arrow.r.double e_1$ e $e arrow.r.double e_2$ esiste $e'$ con $e_1 arrow.r.double e'$ e $e_2 arrow.r.double e'$],
  [*Progresso*: se $emptyset tack.r e : tau$ allora $e$ è un valore oppure $e arrow.r e'$],
  [*Conservazione*: se $Gamma tack.r e : tau$ e $e arrow.r e'$ allora $Gamma tack.r e' : tau$],
  [*Lemma di sostituzione*: se $Gamma, x : tau_1 tack.r e_3 : tau_2$ e $Gamma tack.r e_2 : tau_1$ allora $Gamma tack.r e_3 {x := e_2} : tau_2$])
]

#text(9.5pt)[
#align(center, table(columns: 3, align: left,
  [Costrutto OCaml], [Cosa fa], [In C / JavaScript],
  [`let x = e;;`], [lega il nome `x` al valore di `e`, per sempre], [`const x = e;`],
  [`let x = e in e'`], [`x` vale solo dentro `e'`], [variabile in un blocco `{ }`],
  [`fun x y -> e`], [funzione anonima, curried], [`(x, y) => e`],
  [`let f x y = e`], [funzione con nome], [`function f(x, y) { return e; }`],
  [`let rec f x = e`], [funzione ricorsiva (`and` per le mutue)], [ogni funzione C può essere ricorsiva],
  [`function | P -> e ...`], [funzione che fa subito il match sull'ultimo parametro], [],
  [`if c then e1 else e2`], [espressione, rami dello stesso tipo, `else` obbligatorio], [`c ? e1 : e2`],
  [`match e with | P -> e1 | _ -> e2`], [primo pattern che combacia; `_` combacia con tutto], [`switch`, ma sulla forma],
  [`(x, y)`, `let (x, y) = p`], [tupla e sua destrutturazione], [`struct` senza nomi],
  [`[]`, `x :: l`, `l1 @ l2`], [lista vuota, cons, concatenazione (copia `l1`)], [],
  [`(+.)`, `(x : int)`, `'a`], [operatore prefisso, annotazione di tipo, variabile di tipo], [`(int) x` è un cast, non un'annotazione],
))

#align(center, table(columns: 3, align: left,
  [Funzione (in `List`)], [Tipo], [Risultato],
  [`exists p l`], [`('a -> bool) -> 'a list -> bool`], [qualche elemento soddisfa `p`],
  [`for_all p l`], [`('a -> bool) -> 'a list -> bool`], [tutti gli elementi soddisfano `p`],
  [`filter p l`], [`('a -> bool) -> 'a list -> 'a list`], [gli elementi che soddisfano `p`],
  [`map f l`], [`('a -> 'b) -> 'a list -> 'b list`], [`[f x1; ...; f xn]`],
  [`fold_right f l a`], [`('a -> 'b -> 'b) -> 'a list -> 'b -> 'b`], [`f x1 (f x2 (... (f xn a)))`],
  [`fold_left f a l`], [`('a -> 'b -> 'a) -> 'a -> 'b list -> 'a`], [`f (... (f (f a x1) x2) ...) xn`, in coda],
))
]
