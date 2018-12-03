%% Initialize 
clear all 

%% Read in. batch
insName='Example.ins'
run=readIns(insName);

run.options={'Max MAUD Instances',           5;
             'Delete per cpu results',   false;
             'Run MAUD Refinements',      true;
             'Suppress cmd windows',              true}; %when true on PC Matlab does not wait for processes to end, but Octave works fine.
         
lc=ConvertRun2LinearArray(run);

lc=WriteBatchInputs(lc);

WriteCallParallelBat(lc);

runCases;

CleanRunDir;