function [] = gda2folder(cases,sampName,calibrationFile,isMove)
%gda2folder Copies gda to folder 'measName' where the measName is generated
%using sequentially numbers.

    for i=1:size(cases,1)
        fprintf('Progress: %d / %d \n',i,size(cases,1))
        measName=int2str(i);
        measDir=fullfile(sampName,measName);
        mkdir(measDir);
        for j=1:size(cases,2)
            newGDA=fullfile(measDir,cases{i,j});
            if isMove
                movefile(cases{i,j},newGDA);
            else
                copyfile(cases{i,j},newGDA);
            end
        end
        calibrationFileFull=fullfile(sampName,measName,calibrationFile.name);
        copyfile(calibrationFile.name,calibrationFileFull);

    end
end
