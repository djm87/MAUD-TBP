# MAUD-TBP
MAUD toolset for batch processing

## Summary
The objective of this project is to provide an interface to enable fast batch processing of diffraction experiments in reitveld analysis program MAUD.

## Contents
This repository contains scripts that: 
1. Clean data from the neutron time of flight instrument HIPPO at LANSCE
    - Group samples and experiments
    - Prepare MAUD parameter (.par) file using a template
2. Call MAUD in batch text mode 
     - Distributes batch refinements accross available cores
3. Make custom refinements and modify parameter file
     - Fixes, frees, and ties parameters in the parameter file.
     - Performs non-traditional refinements (i.e. adding background polynomial coefficients, remove keywords, etc...)
4. Extract ODF and parameter values directly from parameter file
5. A general MAUD wrapper for batch analysis

## Compatibility
Scripts are written to work in Matlab and Octave. These coding environments are available on all major operating systems.

## Installation
Clone repo to directory of choice. Add the entire git repo path to the Matlab and Octave startup so that functions will be available independent of working directory. To add to the path permanently, call the script InstallRepo2Path.m in the root directory of the repo.

Octave I/O doesn't handle the ~1million lines of text in the parameter file. To make Octave usable, the gnu commandline function sed is used to quickly remove the locally stored intensity data, thereby reducing hte parameter file to 20000-30000 lines of text. For windows you will need to install: http://gnuwin32.sourceforge.net/packages/sed.htm.
