function [calibrationFile] = moveData2Folder(cases,sampName,isMove)
%moveData2Folder is a wrapper for gda2Folder

    assert(~isempty(dir('*.prm')),...
    'Please sadd .prm file to working directory!' )    

    calibrationFile=dir('*.prm');

    for i=1:length(cases)   
        fprintf('Starting...%s\n',sampName{i})
        fprintf('==================================================\n')
        gda2folder(cases{i},sampName{i},calibrationFile,isMove);
        fprintf('==================================================\n\n')
    end
    
end

