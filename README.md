# MP13 (aka TheriakPTpath)
Optimization program for P-T path construction

Uses the theriak G-minimization algorithm to generate phase properties during pressure-temperature optimization constrained by a chemical zoning profile from core to rim of a crystal, typically garnet.

Original code written by David Moynihan in 2011, published as Moynihan and Pattison (2013).

Updates by Eric to the original 2011 code include 
1. improved efficiency by removing redunant code and updating optimization criteria (calculation time reduced 70%)
2. many new features for more in-depth analysis
3. improved UX

The main program is TheriakPTpath.m
