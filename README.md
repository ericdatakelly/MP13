# MP13 (aka TheriakPTpath)
Optimization program for P-T path construction

The model is fit to the data by iteratively adjusting multiple parameters of a thermodynamic system.  The program uses the theriak G-minimization algorithm to generate thermodynamic properties of the system at each step along a chemical profile of a crystal growing in the system, and these properties are used in a Nelder-Mead search to find the optimum convergence of targeted parameters of the system.

Original code written by David Moynihan in 2011, published as Moynihan and Pattison (2013).  Updates by Eric to the original 2011 code include:

1. Improved efficiency by removing code redundancies and updating optimization criteria (calculation time reduced 70%)
2. Many new features for more in-depth analysis, including alternate misfit functions
3. Improved UX, including transparency of parameters and their effects to help users make better choices

The main program is TheriakPTpath.m

### Example of final output from MP13 (with post-processing)
Progressive states of the chemical system (usually a rock or magma) are optimized to achieve minimum chemical potential at each point, resulting in a path in P-T space that defines the history of the chemical system during residence in the Earth's crust.  The isopleths (e.g., Xalm) are lines of constant chemical components measured in the crystal, and their convergence defines a point along the path.  The isopleths for each panel correspond with the system when minimized for the P-T at the yellow point.  See Kelly et al. (2015, DOI: 10.1007/s00410-015-1171-2).

<img src="https://github.com/ericdavidkelly/MP13/blob/master/example_output_model_fit.png"/>

<img src="https://github.com/ericdavidkelly/MP13/blob/master/example_output_path.png"/>
