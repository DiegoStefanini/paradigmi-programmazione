# Paradigmi di Programmazione

Workflow generale: `../CLAUDE.md`.

- Repo GitHub: `DiegoStefanini/paradigmi-programmazione` (la cartella locale resta `programmazione/`).
- Docente: Chiara Bodei, a.a. 2026-27. Pagina e-learning: elearning.di.unipi.it/enrol/index.php?id=1167 (dettagli del corso in `info.md`).
- Lezioni: lunedì 9-11 aula E, martedì 16-18 aula D5, venerdì 14-16 aula D5. Registrate.
- Niente libro: slide e dispense caricate man mano. Approccio "model-first": prima il modello formale, poi il linguaggio (OCaml soprattutto, poi Java, JavaScript, Python, C++).
- Parte funzionale con Jupyter Notebook OCaml in un container Docker (link su e-learning).
- Esame: scritto + orale, **niente prove in itinere**.

## Mappa materiale ↔ lezione

| Giorno | Materiale (`slide/`) | Grezzo | Argomento |
|---|---|---|---|
| 21 set 2026 | `Lambda calcolo - Prima Parte.pdf`, tutte le 67 slide | `grezzi/2026-09-21.md` | calcolabilità, Turing/von Neumann/Church, sintassi λ, applicazione, convenzioni, alberi, variabili libere e legate |
| 22 set 2026 | `Lambda calcolo - Parte fino al 23 settembre.pdf`, slide 68-116 (le 1-67 sono la Prima Parte) | `grezzi/22-09.md` (vuoto) | FV, α-conversione, sostituzione capture-avoiding, β-riduzione, forma normale, β-equivalenza, Church-Rosser, Ω |
| 25-29 set 2026 | `Lambda_calcolo_2026_fino_29_set.pdf`, slide 117-192 (le 1-116 sono le stesse di prima) | — | currying e ordine superiore, call-by-value e call-by-name, combinatore Y e fattoriale, codifiche (booleani, IF, numerali di Church, SUCC/PLUS/TIMES) |
| 2 ott 2026 | `Lambda calcolo Non Tipato - Fino al 2 ottobre.pdf` (198 slide, nuove: AND/OR 184, SUCC C₁ risolto 192, 196-198); `Introduzione al controllo di tipi e regole di inferenza.pdf`, tutte le 28 | — (niente registrazione) | AND/OR, perché servono i tipi, sistemi di tipi e type safety, regole di inferenza e induzione sulle derivazioni, linguaggio di espressioni con semantica small-step |

Capitoli della dispensa: 1 «Il lambda calcolo» (fino alle strategie CBV/CBN), 2 «Programmare nel lambda calcolo» (currying, Y, codifiche), 3 «Controllo dei tipi».

Nota: nel PDF λ è un glifo che `pdftotext` rende come "l": nella dispensa scrivere sempre λ (`$lambda$`).

Fin dove si è arrivati: fine di `Introduzione al controllo di tipi e regole di inferenza.pdf` (semantica small-step; le regole di tipo non ci sono ancora). Senza registrazione il punto esatto non è verificato. `Prima Esercitazione sul Lambda Calcolo.pdf` non è ancora nella dispensa.

