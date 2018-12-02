function [sampName] = makeSampleDirs(samples,outputName)
%makeSampleDir Creates a folder for each sample and returns the name of
%that folder
    %load the runTitles in a variable we can work with
    c=textread(outputName,'%s','delimiter','\n');
    
    sampName=cell(length(samples),1);
    
    fprintf('Sample Names are:\n')
    fprintf('=====================\n')
    for i=1:length(samples)
        sampName{i}=GetSampleName(c,samples{i}(1));
        
        %Make directory for sample
        if ~(exist(sampName{i},'dir')==7)
            mkdir(sampName{i});
        end
        fprintf('%s\n',sampName{i})
    end
    fprintf('\n')

end

