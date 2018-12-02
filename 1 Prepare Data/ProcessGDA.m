%% Initialize
clear all

%% Get run titles and export them to local txt file
str2find='#Run title:';
outputName='runTitles.txt';
overWrite=false;

GetRunTitle(str2find,outputName,overWrite);

%% Combine Measurements from the same sample
samples = groupMeasurements(outputName);

%% Make the sample directories and the sample names
sampName = makeSampleDirs(samples,outputName);

%% For each sample check the data is consistent
%Currently only rotations are checked. Other checks might be added.
nrot=3;
cases=checkData(samples,nrot);

%Note: If there is a problem. remove the problematic gda or add the
%missing data. Once runTitles.txt is updated you need to rerun
%groupMeasurements

%% Move or Copy the gda to folders 
isMove=false; %if false only copies to folders, leaving gda in working dir.
moveData2Folder(cases,sampName,isMove)

%% Specify the templates for each sample or you can manually process them with HIPPO wizard
templateParName={'Initial.par';'Initial.par';'Initial.par'};

prepareMAUDBatch(cases,sampName,templateParName)

