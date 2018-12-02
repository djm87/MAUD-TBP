function [] = template2folder(par,parOutputName,gdaNums2Replace,...
                                    cases,sampName,calibrationFile)
%template2folder Copies the template to folder 'sampName'

    hasGDA=contains2(par,'.gda');
    list=par(hasGDA);
    for i=1:size(cases,1)
        fprintf('Progress: %d / %d \n',i,size(cases,1))
        listLoop=list;
        for j=1:size(cases,2)
            for k=1:length(listLoop)
                listLoop{k}=strrep(listLoop{k},...
                    [int2str(gdaNums2Replace(j)) '.gda'],cases{i,j});
            end
        end
        par(hasGDA)=listLoop;
        measName=int2str(i);
        parOutputFull=fullfile(sampName,measName,parOutputName);
        writePar(par,parOutputFull,'no check');

    end
end
