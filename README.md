# MP13 (aka TheriakPTpath)
Chemical time series optimization for P-T path construction

This program is used to fit a model to chemical time series data.  The data includes several time series of chemical variations frozen into crystals that formed in the Earth's crust.  Think of the crystals as little recording devices that preserve information about their chemical environment while they grow.  This is analogous to the study of tree rings to understand the history of the tree or forest.


Tree Rings

<img src="https://github.com/ericdavidkelly/MP13/blob/master/Tree_rings.jpg"/>
(source unknown)



Garnet Crystal

<img src="https://github.com/ericdavidkelly/MP13/blob/master/grt_crystal.jpg"/>
(http://skywalker.cochise.edu/wellerr)



Garnet Chemical Zoning

<img src="https://github.com/ericdavidkelly/MP13/blob/master/grt_chem.jpg"/>



The model is fit by iteratively adjusting multiple parameters of a thermodynamic system to create starting conditions, and then a Nelder-Mead approach is implemented to find the optimum convergence (minimum misfit) of targeted parameters of the system, eventually reproducing the chemical variations in the sample data.  A unique series of P-T variations are associated with the variations in chemistry in the crystal.

The original code was written by David Moynihan in 2011, published as Moynihan and Pattison (2013).  Updates by Eric to the original 2011 code include:

1. Improved efficiency by removing code redundancies and updating optimization criteria (calculation time reduced 70%)
2. Many new features for more in-depth analysis, including alternate misfit functions
3. Improved UX, including transparency of parameters and their effects to help users make better choices

The main program is TheriakPTpath.m

### Example of final output from MP13 (with post-processing)
Progressive states of the chemical system (usually a rock or magma) are optimized to achieve minimum chemical potential at each point, resulting in a path in P-T space that defines the history of the chemical system during residence in the Earth's crust.  The isopleths (e.g., Xalm) are lines of constant chemical components measured in the crystal, and their convergence defines a point along the path assuming ideal conditions (chemical equilibrium).  The isopleths for each panel correspond with the system when minimized for the P-T at the yellow point.  See Kelly et al. (2015, DOI: 10.1007/s00410-015-1171-2).

Garnet Chemical Zoning Profile and Model Prediction

<img src="https://github.com/ericdavidkelly/MP13/blob/master/example_output_model_fit.png"/>


Resulting P-T Path

<img src="https://github.com/ericdavidkelly/MP13/blob/master/example_output_path.png"/>
