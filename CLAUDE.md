# Paradigmi di Programmazione

Workflow generale: `../CLAUDE.md`.

- Repo GitHub: `DiegoStefanini/paradigmi-programmazione` (la cartella locale resta `programmazione/`).
- Docente: Chiara Bodei, a.a. 2026-27. Pagina e-learning: elearning.di.unipi.it/enrol/index.php?id=1167 (dettagli del corso in `info.md`).
- Lezioni: lunedì 9-11 aula E, martedì 16-18 aula D5, venerdì 14-16 aula D5. Registrate.
- Niente libro: slide e dispense caricate man mano. Approccio "model-first": prima il modello formale, poi il linguaggio (OCaml soprattutto, poi Java, JavaScript, Python, C++).
- Parte funzionale con Jupyter Notebook OCaml in un container Docker (link su e-learning).
- Esame: scritto + orale, **niente prove in itinere**.

Dispensa: **è il testo su cui Diego studia** (21 ott: le dispense della prof, λ-calcolo da 75 pagine e OCaml dai notebook, "ci si studia malissimo"). Le dispense della prof sono solo una fonte, come le slide: servono a controllare che non manchi niente. Il progetto tutor su claude.ai non si usa più (16 ott).

## Mappa materiale ↔ lezione

| Giorno | Materiale (`slide/`) | Grezzo | Argomento |
|---|---|---|---|
| 21 set 2026 | `Lambda calcolo - Prima Parte.pdf`, tutte le 67 slide | `grezzi/2026-09-21.md` | calcolabilità, Turing/von Neumann/Church, sintassi λ, applicazione, convenzioni, alberi, variabili libere e legate |
| 22 set 2026 | `Lambda calcolo - Parte fino al 23 settembre.pdf`, slide 68-116 (le 1-67 sono la Prima Parte) | `grezzi/22-09.md` (vuoto) | FV, α-conversione, sostituzione capture-avoiding, β-riduzione, forma normale, β-equivalenza, Church-Rosser, Ω |
| 25-29 set 2026 | `Lambda_calcolo_2026_fino_29_set.pdf`, slide 117-192 (le 1-116 sono le stesse di prima) | — | currying e ordine superiore, call-by-value e call-by-name, combinatore Y e fattoriale, codifiche (booleani, IF, numerali di Church, SUCC/PLUS/TIMES) |
| 2 ott 2026 | `Lambda calcolo Non Tipato - Fino al 2 ottobre.pdf` (198 slide, nuove: AND/OR 184, SUCC C₁ risolto 192, 196-198); `Introduzione al controllo di tipi e regole di inferenza.pdf`, tutte le 28 | — (niente registrazione) | AND/OR, perché servono i tipi, sistemi di tipi e type safety, regole di inferenza e induzione sulle derivazioni, linguaggio di espressioni con semantica small-step |
| 5-9 ott 2026 | `Sistemi di tipo e Lambda calcolo tipato.pdf` (120 slide; 1-28 già viste; nuove 29-120) | — (niente registrazione) | regole di tipo e type safety per le espressioni, λ-calcolo tipato FUN, Γ, lemma di sostituzione, let, fix/PCF, limiti dei tipi e teorema di Rice |
| — | `Dispensa Lambda Calcolo  e Lambda Calcolo Tipato.pdf` (75 pag., versione del 19 ott): copre tutti e 3 i capitoli | — | solo fonte di controllo |
| ~12-21 ott 2026 | `OCaml Primo sguardo.pdf` (cap. 1), `Liste e Pattern Matching.pdf` (cap. 2): export dei notebook, molto dispersivi; `Esercizi prima esercitazione su OCAML.pdf` | — (niente registrazione) | OCaml: tipi base, funzioni, currying, let/let rec, type inference con vincoli, polimorfismo, liste, pattern matching, funzioni higher-order, fold |

Capitoli della dispensa: 1 «Il lambda calcolo» (sintassi, strategie CBV/CBN, currying, Y, codifiche), 2 «Controllo dei tipi», 3 «Il lambda calcolo tipato», 4 «OCaml: espressioni, funzioni e tipi», 5 «Liste e pattern matching». Le prossime lezioni OCaml (tipi definiti dall'utente, interpreti…) aprono un capitolo nuovo: il 5 ha già 4 sezioni piene.

Nota: nel PDF λ è un glifo che `pdftotext` rende come "l": nella dispensa scrivere sempre λ (`$lambda$`).

Fin dove si è arrivati: λ-calcolo chiuso, e OCaml fino alla fine di `Liste e Pattern Matching.pdf` (fold e modulo `List`). Esercizi 1-11 dai fogli λ, 12-18 dal foglio OCaml, solo consegne; il «Riepilogo» ha anche le tabelle dei costrutti OCaml e delle funzioni su liste.

Nomi delle regole: quelli dell'Appendice B della dispensa della prof (App, CV-App, If-Cond, T-App, T-Fun…). Esercizi: `#esercizio(n)[…]` nel testo, senza soluzioni (Diego li fa sul quaderno). Le riduzioni si verificano con `python3 -I esercizi/lambda.py "<termine>" no|cbv|cbn` (in CBV è valore tutto ciò che non si riduce, anche una variabile libera). Il codice OCaml si prova con `podman run --rm -i docker.io/ocaml/opam:debian-12-ocaml-5.2 ocaml`.
