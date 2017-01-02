# MP13 (aka TheriakPTpath)
Optimization program for P-T path construction

Uses the theriak G-minimization algorithm to generate phase properties during pressure-temperature optimization constrained by a chemical zoning profile from core to rim of a crystal, typically garnet.

Original code written by David Moynihan in 2011, published as Moynihan and Pattison (2013).

Updates by Eric to the original 2011 code include 
1. improved efficiency by removing redunant code and updating optimization criteria (calculation time reduced 70%)
2. many new features for more in-depth analysis
3. improved UX

The main program is TheriakPTpath.m

### Example of final output from MP13 (with post-processing)
Progressive states of the chemical system (usually a rock or magma) are optimized toward minimum chemical potential, resulting in a path in P-T space that defines the history of the chemical system during residence in the Earth's crust.  The isopleths (e.g., Xalm) are lines of constant chemical components measured in the system, and their convergence defines a point along the path.  The isopleths for each panel correspond with the system when minimized for the P-T at the yellow dot.

<img src="https://github.com/ericdavidkelly/MP13/blob/master/Example_output.png" alt="Example_output.png" align="middle"/>
