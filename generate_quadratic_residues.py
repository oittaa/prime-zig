#!/usr/bin/env python3

# https://mathworld.wolfram.com/QuadraticResidue.html
# https://en.wikipedia.org/wiki/Quadratic_residue

moduli = (256, 9, 5, 7, 13, 17, 97, 241, 257, 673)
quadratic_residues = {}

for m in moduli:
    quadratic_residues[m] = set((x * x) % m for x in range(m // 2 + 1))
    print(f"Quadratic residues mod {m}: {sorted(quadratic_residues[m])}")
