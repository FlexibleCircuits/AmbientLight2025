# AmbientLight2025

The file "main_data.mat" contains the speed traces underlying the main paper figures as well as information about each trace. Specifically:
•	ALL_SPEED 24x29x450 (conditions x animals x time): speed traces for each tested condition and animal in cm/s.
•	conds 1x24: name of each tested condition as light_species_stimulus with bright/dim being the two light conditions; bl6 = Mus, bw = Peromyscus maniculatus, po = Peromyscus poliontus; dimm = dimming, ex10 = black looming, ex06 = white looming, swep = sweeping
•	ALL_BEH 24x29 (conditions x animals): manually annotated behaviour type with 0 - ignores the stimulus, 1 - escapes to/towards shelter, 2 - stops (short), 3 - freezes (longer, completely still), 4 - does sprint - stop - sprint - stop, 5 - does stop, then escape, 6 - doesn't react directly, but doesn't cross threat zone, 7 - run (not towards shelter, brief), 8 - erratic sprints, 9 - brief startle, then ignored, 10 - approach / positive interest, 11 - escape with freezing
•	ANIMALID 24x29 (conditions x animals): ID of each animal
•	COORDX 24x29 (conditions x animals): x-coordinates for each speed trace
•	COORDY 24x29 (conditions x animals): y-coordinates for each speed trace
•	FPS 24x29 (conditions x animals): recording frequency (Hz) for each speed trace
•	PIX2CM 24x29 (conditions x animals): conversion factor for each video to go from pixels to cm
•	SHELTER 24x29x2 (conditions x animals x dimension): x and y coordinates of the edge of the shelter
•	IDS 24x29 (conditions x animals): experimenter ID


The file "main_data_hunting" contains data concerning the approach behaviour of a lower visual field stimulus (Figure 3).
•	HUNTING 3x2 (species x light condition): speed traces for each species and light condition (bright, dim)
•	HUNTING_LAT 3x2 (species x light condition): latency to first ellipse approach
The file "main_data_foraging" contains data about the pre-stimulus behaviour (Figure 4).


•	medianSpeed 3x1 -> 5x2 (elicited behaviour type x light condition): median pre-stimulus speed per species
•	percentTimeCenter: percent of pre-stimulus time spent in the center part of the arena
•	percentTimeDanger: percent of pre-stimulus time spent in the theat zone of the arena
•	percentTimeShelter: percent of pre-stimulus time spent in the shelter area
•	totDist: total distance travelled during pre-stimulus time
•	corrStims: stimulus type for each entry of the other variables


The folder code contains the script "main_figures.m" contains code to replicate the main figure panels as well as helper code files created by third parties as indicated in the License files.

