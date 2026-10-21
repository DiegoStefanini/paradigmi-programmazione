#!/usr/bin/env python3
"""Verifica soluzioni di λ-calcolo. Uso: lambda.py "(\\x.x)(\\y.xx)" [no|cbn|cbv]
Variabili di una lettera (con apici/cifre), \\ o λ per l'astrazione."""
import sys, itertools

def parse(s):
    s = s.replace("λ", "\\").replace(" ", "")
    pos = 0
    def atom():
        nonlocal pos
        c = s[pos]
        if c == "(":
            pos += 1; t = expr(); pos += 1; return t
        if c == "\\":
            pos += 1; v = s[pos]; pos += 1; pos += 1  # salta il punto
            return ("lam", v, expr())
        pos += 1
        return ("var", c)
    def expr():
        nonlocal pos
        t = atom()
        while pos < len(s) and s[pos] != ")":
            t = ("app", t, atom())
        return t
    return expr()

def show(t, top=True):
    k = t[0]
    if k == "var": return t[1]
    if k == "lam": 
        r = f"λ{t[1]}.{show(t[2])}"
        return r if top else f"({r})"
    f, a = t[1], t[2]
    fs = show(f, True) if f[0] != "lam" else f"({show(f)})"
    as_ = show(a, False) if a[0] != "var" else a[1]
    return fs + as_ if top else f"({fs}{as_})"

def fv(t):
    k = t[0]
    if k == "var": return {t[1]}
    if k == "lam": return fv(t[2]) - {t[1]}
    return fv(t[1]) | fv(t[2])

def subst(t, x, v):
    k = t[0]
    if k == "var": return v if t[1] == x else t
    if k == "app": return ("app", subst(t[1], x, v), subst(t[2], x, v))
    y, b = t[1], t[2]
    if y == x: return t
    if y in fv(v):
        n = next(c for c in itertools.chain("abcdefghijklmnopqrstuvw", (f"z{i}" for i in range(99)))
                 if c not in fv(v) | fv(b) | {x})
        b = subst(b, y, ("var", n)); y = n
    return ("lam", y, subst(b, x, v))

def is_val(t): return t[0] == "lam"

def step(t, strat):
    k = t[0]
    if k == "var": return None
    if k == "lam": return None if strat in ("cbv", "cbn") else (lambda r: None if r is None else ("lam", t[1], r))(step(t[2], strat))
    f, a = t[1], t[2]
    if f[0] == "lam" and (strat != "cbv" or is_val(a) or step(a, strat) is None):
        return subst(f[2], f[1], a)
    r = step(f, strat)
    if r is not None: return ("app", r, a)
    if strat == "cbn": return None
    if strat == "cbv" or strat == "no":
        r = step(a, strat)
        return None if r is None else ("app", f, r)

def run(s, strat="no", maxn=40):
    t = parse(s); out = [show(t)]
    for _ in range(maxn):
        n = step(t, strat)
        if n is None: return out, True
        t = n; out.append(show(t))
    return out, False

if __name__ == "__main__":
    strat = sys.argv[2] if len(sys.argv) > 2 else "no"
    out, fin = run(sys.argv[1], strat)
    print("\n→ ".join(out)); print("forma normale" if fin else "NON termina (40 passi)")
