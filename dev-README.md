# Development Sandbox README

This README details the functionalities supported by the Development Sandbox in the unofficial-v2.1 branch.

## Setting trial-level durations

The original BASCO toolbox was set up to receive durations only as a function of condition. This prevented the use of the toolbox for experiments in which trial durations had been jittered, which is common in event-related experimental designs. The Development Sandbox has updated the toolbox to accept durations on a trial by trial basis. 

**Analyses run using trial-level durations must be prepared using a config file; GUI does not currently support this functionality.**

### Changed Files
* BASCO/BASCO.m (main program file)
* tutorials/empathy/anadef.m (config file for 3D-stored timeseries data)
* tutorials/empathy4D/anadef.m (config file for 4d-stored timeseries data)

### Preparing Timing Files
Trial-level durations should be formatted and stored in a .txt file with the same structure as the onset files. Each row represents one experiment condition in the order specified in the config file. Elements in each row represent the duration for each instance of that condition in experiment order. One .txt file should be generated for each run and stored in the folder for that run.

### Config File Setup
Relevant values:
* AnaDef.durType: Set to 2 for trial-level durations
* AnaDef.Subj{csubj}.Duration: Cell Array including the .txt file names for the duration files for each run 

### File Structure
1. Experiment Folder
	1. Subject 1 Folder
		1. Run 1 Folder
			1. raw data (all 3D files or one 4D file)
			1. onsets.txt
			1. durations.txt
			1. Additional regressor(s) (e.g., motion files)
		1. Run 2 Folder
		1. ...
		1. Run R Folder
	1. Subject 2 Folder
	1. ...
	1. Subject N Folder
	1. ROIs Folder
	1. **Config File.m**

#### Notes
* Duration files must have the exact same number and ordering of elements as their corresponding onset files
