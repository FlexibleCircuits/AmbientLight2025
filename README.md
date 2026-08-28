# AmbientLight2025

This data set refers to the publication **"Ambient Light Impacts Innate Behaviors of New-World and Old-World Mice"** by Reinhard et al. https://www.biorxiv.org/content/10.1101/2025.05.14.653927v1

## The folder **_code_** contains: 
1. The script **"ReinhardEtAl2026_Figures.m"** which serves to replicate the main figure panels as well as helper code files created by third parties as indicated in the License files.
2. The script **"ReinhardEtAl2026_Figure4.ipynb"** which contains the code to perform the mixed effects analysis and linear regression analysis of Figure 4 of the final manuscript.
3. The script **"CEBRA_dimensionalityReduction.ipynb"** which contains the code for Figure 1F.

## The folder **_data_** contains the following files:
### The file **"main_data.mat"** contains the speed traces underlying the main paper figures as well as information about each trace. Specifically:
- **ALL_SPEED** 24x29x450 (conditions x animals x time): speed traces for each tested condition and animal in cm/s.
- **conds** 1x24: name of each tested condition as light_species_stimulus with bright/dim being the two light conditions; bl6 = Mus, bw = Peromyscus maniculatus, po = Peromyscus poliontus; dimm = dimming, ex10 = black looming, ex06 = white looming, swep = sweeping
- **ALL_BEH** 24x29 (conditions x animals): manually annotated behaviour type with 0 - ignores the stimulus, 1 - escapes to/towards shelter, 2 - stops (short), 3 - freezes (longer, completely still), 4 - does sprint - stop - sprint - stop, 5 - does stop, then escape, 6 - doesn't react directly, but doesn't cross threat zone, 7 - run (not towards shelter, brief), 8 - erratic sprints, 9 - brief startle, then ignored, 10 - approach / positive interest, 11 - escape with freezing
- **ANIMALID** 24x29 (conditions x animals): ID of each animal
- **COORDX** 24x29 (conditions x animals): x-coordinates for each speed trace
- **COORDY** 24x29 (conditions x animals): y-coordinates for each speed trace
- **FPS** 24x29 (conditions x animals): recording frequency (Hz) for each speed trace
- **PIX2CM** 24x29 (conditions x animals): conversion factor for each video to go from pixels to cm
- **IDS** 24x29 (conditions x animals): experimenter ID


### The file **"main_data_plots.mat"** contains the same data as "main_data.mat" but reformatted to exclude sweeping stimuli which were not analysed in the manuscript. Variables have shape 296x1
- **sorted_by_max** 296x1: order of trials to be plotted if sorted by max. speed
- **animalid_all, coordx_all, coordy_all, fps_all, ids_all, px2cm_all** contain the same data as in main_data.mat but excluding the sweeping stimuli (296x1)
- **data_all** 296x1: reshaped ALL_SPEED data
- **behv_manual** 296x1: manual behavioural classification
- **light_all** 296x1: light level index (0=dim, 1=bright)
- **species_all** 296x1: species information (1=Mm, 2=Pm, 3=Pp)
- **stimuli** 296x1: stimulus information (1=dimming, 2=black looming, 3=white looming)
- **toshelter** 296x1: whether running bout ended in shelter (0=no, 1=yes)

  
### The file "main_data_autobehv_newThr" contains the automated behaviour classification.
- **behv_auto_curr** 296x1: automated behaviour classification; 0 - none, 1 - stop, 2 - escape to shelter, 3 - run (no shelter), 4 - dart to shelter, 5 - dart (no shelter)


### The file **"main_data_perAnimalInfo.mat"** contains age and sex info per animal
- **age** 296x1: age in days per trial as saved in main_data_plots.mat
- **animalsex_perID** 94x1: sex of each animal; 1=male, 2=female
- **dob_perID** 94x1: date of birth for each animal
- **doe_all** 296x8: date of experiment for each trial
- **takenids** 94x1: ID of each animal included in main_data_plots.mat as indexed in ANIMALID


### The file **"main_data_taken.mat"** contains two variables:
- **TAKETHIS** 296x1: index of entries in 24x29 variables as they correspond to 296x1 variables
- **animalid_all** 18x29: version of ANIMALID but without sweeping stimulus


### The file **"index_helpers.mat"** contains variables that help moving between 24x29 and 296x1 variables
- **colID** 296x1: corresponding column in 24x29 variables for each entry in 296x1 variables
- **rowID** 296x1: corresponding row in 24x29 variables for each entry in 296x1 variables
- **ids_all** 296x1: IDS all but for 296x1 variables


### The file "main_data_hunting" contains data concerning the approach behaviour of a lower visual field stimulus (Figure 3).
- **HUNTING** 3x2 (species x light condition): speed traces for each species and light condition (bright, dim)
- **HUNTING_LAT** 3x2 (species x light condition): latency to first ellipse approach

  
### The file "main_data_foraging_new" contains data about the pre-stimulus behaviour (Figure 4).
- **medianSpeed** 4x1 -> 6x2 (elicited behaviour type x light condition): median pre-stimulus speed per species (1 - Pp subset, 2 - Mm, 3 - Pm, 4 - Pp)
- **percentTimeCenter** 4x1 -> 6x2: percent of pre-stimulus time spent in the center part of the arena
- **percentTimeDanger** 4x1 -> 6x2: percent of pre-stimulus time spent in the theat zone of the arena
- **percentTimeShelter** 4x1 -> 6x2: percent of pre-stimulus time spent in the shelter area



