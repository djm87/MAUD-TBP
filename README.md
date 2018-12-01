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

## Comptibility
Scripts are written to work in Matlab and Octave. These coding environments are available on all major operating systems.
