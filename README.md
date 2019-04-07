# TheriakPTpath (aka MP13)
### Background: Chemical time series optimization for P-T path construction

This program is used to fit a model to chemical 'time series' data.  The data includes
chemical variations frozen into crystals that formed in the Earth's crust.  These crystals
provide detailed information about various chemical and physical processes that occurred deep
in the Earth, which helps geoscientists reconstruct Earth history, model geodynamic
processes, understand the formation of important mineral resources, and much more.

Think of the crystals as little recording devices that preserve information about their
chemical environment while they grow.  This is analogous to the study of tree rings to
understand the history of the tree or forest.


Tree Rings

<img src="https://github.com/ericdavidkelly/MP13/blob/master/Tree_rings.jpg"/>
(source unknown)



Garnet Crystal

<img src="https://github.com/ericdavidkelly/MP13/blob/master/grt_crystal.jpg"/>
(http://skywalker.cochise.edu/wellerr)



Garnet Chemical Zoning

<img src="https://github.com/ericdavidkelly/MP13/blob/master/grt_chem.jpg"/>



The model is fit by iteratively adjusting multiple parameters of a thermodynamic system
to create starting conditions, and then a Nelder-Mead approach is implemented to find
the optimum convergence (minimum misfit) of targeted parameters of the system, eventually
reproducing the chemical variations in the sample data.  A unique series of P-T changes
are associated with the variations in chemistry in the crystal.

The original code was written by David Moynihan in 2011, published as Moynihan and
Pattison (2013, DOI: 10.1111/jmg.12032,
<a href="https://www.ucalgary.ca/pattison/files/pattison/13moynihanptpath-jmg.pdf" target="_blank">pdf</a>).


### Example of final output from MP13 (with post-processing)
Progressive states of the chemical system (usually a rock or magma) are optimized to
achieve minimum chemical potential at each point, resulting in a path in P-T space that
defines the history of the chemical system during residence in the Earth's crust.  The
isopleths (e.g., Xalm) are lines of constant chemical components measured in the crystal ...


Garnet Chemical Zoning Profile and Model Prediction

<img src="https://github.com/ericdavidkelly/MP13/blob/master/example_output_model_fit.png"/>


... and their convergence defines a point along the path assuming ideal conditions
(chemical equilibrium).  The isopleths for each panel in the figure below correspond with
the system when minimized for the P-T at the yellow point.  See Kelly et al.
(2015, DOI: 10.1007/s00410-015-1171-2,
<a href="https://www.researchgate.net/profile/Michael_Wells5/publication/280667952_An_Early_Cretaceous_garnet_pressure-temperature_path_recording_synconvergent_burial_and_exhumation_from_the_hinterland_of_the_Sevier_orogenic_belt_Albion_Mountains_Idaho/links/55c0ebe708aec0e5f448fbae.pdf" target="_blank">pdf</a>
).


Resulting P-T Path

<img src="https://github.com/ericdavidkelly/MP13/blob/master/example_output_path.png"/>


These paths are highly detailed compared with previous methods, and they are helping
to change the understanding of mountain forming processes, which also impacts the
exploration and evaluation of mineral resources (like those that supply the materials
in your computer).


### Instructions (intended for experienced Theriak-Domino users)

P-T Path Program "TheriakPTpath"

Version EDK20160510 (Written for Windows 7)

These are basic instructions for installing and running the MP13 Matlab program.
The program runs in Matlab but calls
<a href="https://titan.minpet.unibas.ch/minpet/theriak/theruser.html" target="_blank">Theriak-Domino</a>
(TD) for G minimization.  It is assumed that you already have TD running on your
system, and that you have the typical folders: Working and Programs.

The TheriakPTpath files are setup to run in Windows 7, but they might not work with
Windows 10 due to an issue with theriak not running from the Working folder.  It might
run from the Programs folder instead (i.e., placing TheriakPTpath files into the Programs
folder instead of the Working folder).
TheriakPTpath is modified from the original MP13 script,
but most modifications are minor and only impact user experience.  The search algorithm
makes use of Matlab's fminsearch.m function, which is unchanged from MP13.  The only change that
would impact the original algorithm is the addition of alternate misfit functions, but
the original misfit function remains and is recommended for most cases.

It is assumed that you already have an acceptable model for your rock.  In other words,
you have produced a Domino plot that appropriately describes the stability fields and
isopleth locations of the rock bulk composition for the beginning of garnet growth.
When you run TheriakPTpath, it will attempt to locate the P-T conditions of the isopleth
intersections corresponding to the garnet chemical zoning profile from core to rim while
incorporating garnet fractionation.  As the garnet components are removed from the bulk
composition at each step, the chemical model will be adjusted to create the new effective
bulk composition.  Note that the effective bulk composition could evolve to a point of
instability, possibly indicating that your starting model needs adjustment.  If this occurs,
reevaluate your starting bulk composition and try again.

Keep in mind that the garnet needs to contain preserved chemical zoning with little
re-equilibration.  Generally this means that the rock did not exceed 600 C for a long
duration.


To install and run the program:

1\. Put these files into your TD Working folder (or Program folder as noted above).

  * TheriakPTpath.m

  * TheriakPTpath_misfit_function.m

  * TheriakPTpath_readParams.m

  * TheriakPTpath_readTable.m

  * Therin bulk composition file (e.g., ED01_therin.txt; The bulk comp must have elements
  in this order: Si,Al,Fe,Mg,Mn,Ca,Na,K,Ti,H)

  * Dataset file (e.g., tcdb55c2d.txt)

  * Garnet zoning profile (e.g., ED01Profile.txt).  The steps are not associated with
radius or volume, but they should be spaced so that there are not big jumps in chemistry
(if possible).  Generally, 20-40 micron steps from EPMA data should work.  If there are
big jumps in chemistry, the program may not be able to find the next step.  Interpolate
if needed.

  * Rock parameters file (e.g., ED01_params.txt).

2\. Edit the parameters file.  The file has comments to guide you through it, but here are some additional notes:

  * When specifying the starting P-T values, be sure to choose a point outside of the garnet
stability field but close to the first isopleth intersection.  This will help the program
better approximate garnet fractionation, assuming equilibrium conditions and isopleths
that represent the core of the garnet (not a garnet sectioned through the rim).

  * The original misfit function from MP13 is a good starting point.  If you have difficulty,
you may find that an alternate function is more appropriate.  The options are described
in the comments, but generally the alternate functions use different combinations of
endmembers to find the P-T path.  The normalization also can be turned off.  These options
were added to account for specific characteristics of unique samples, so use them carefully.

3\. Run the program.
  * Start Matlab
  * Navigate to the Working folder
  * Type "TheriakPTpath('<rock_parameters_file_name>')" in the Matlab command window (case sensitive).

    Example:

    ```
    TheriakPTpath('ED01_params.txt')
    ```

    Some messages will be displayed, and if everything looks good, follow the instructions
    to continue.  A figure window will open, and the starting P-T point will be shown as a red dot.

4\. Examine output.
  * Outputfiles will be written to the Working folder (e.g., ED01_allCompsForTD.txt).

    __\*\* These files will be overwritten in the next run \*\*__

    _It is recommended to save these files to a unique folder before running the program again._

  * Note that the garnet volumes reported (e.g., ED01_allInfoFromNode.txt) represent the
cumulateive garnet fractionated during the run, yet each step calculated by TD represents
an independent calculation of phase equilibria in which only the garnet shell is in
equilibrium with the matrix.  To determine the modes of phases at any step, run theriak
for the conditions of the step and renormalize the modes, including the calculated garnet
volume.

  * Your original therin file will be saved, if possible, but...

    __\*\* the program will overwrite therin during the search. \*\*__

    _Make a copy of it for safety._

  * Volumes of garnet and solids are output in the allInfoFromNode file.
    * SolidsVolCC = total volume in cc of solid phases, including the outer shell of garnet
in equilibrium with the matrix phases.
    * GrtOuterVolCC = volume in cc of garnet outer shell in equilibrium with matrix phases
    * GrtVolCC = total garnet fractionated (in cc) during a step between two P-T points.
Includes the outer shell.
  Consider a PT path segment along PT1 to PT2 with 10 fractionation steps along the segment.
    GrtVolCC is the sum of all Grt grown along the segment, and GrtOuterVolCC is the volume of only the Grt produced between steps 9 and 10.  Ideally, GrtOuterVolCC is in equilibrium with the other phases in the rock at step 10.  Each row of the output file represents the conditions of the rock at the end of each segment (equivalent to step 10 in this example), so I report the Grt volume in equilibrium with all other values in a row (GrtOuterVolCC) as well as all Grt produced since the previous row (GrtVolCC).  The two values will be the same if the loop step size is relatively large.  If the difference between the two PT points is smaller than the step size, the number of fractionation steps along a segment will be reduced to one.
    * GrtCumulMode = cumulative garnet mode from the start of the model run at step 1.  Due
to round off error, these values may differ from those calculated from the other volume
values listed here, but in tests with long runs (~40 steps) and variable step sizes, the
error appears to be several orders of magnitude less than 1% of the garnet mode.

  * You can choose to save the loop fractionation table from each step.  A loop table is
described in the TD Guide under 'Theriak output files > tab-file'.
There is also an option to calculate a loop table for the entire PT path.  However,
this option will ignore the 'bulk Mn minimum' option, described below.

  * There is an option to set a 'bulk Mn minimum' value.  This may be useful if the rock
runs out of Mn early, even though evidence suggests that it probably shouldn't (e.g.,
garnet kept growing and still has some Sps component).  A typical value should be very
small (e.g., 0.00001), and is intended to simply help garnet maintain stability while
it grows under Mn-poor conditions, reflected in an observed near-zero Sps component
in the zoning profile.
