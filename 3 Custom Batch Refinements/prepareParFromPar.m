function [] = prepareParFromPar(InputPar,InputDir,OutputPar,OutputDir)
%This function checks for intensity data if it is stored locally and 
%deletes it if it is. It then takes the InputPar, copies it to the OutputDir,
%finds the gda instances in the par file, and switches them out for the gda 
%Example
%prepareParFromPar('Step4_wiz5_ref6.par',fullfile(pwd,'6'),'Initial_3.par',{fullfile(pwd,'2');fullfile(pwd,'1')})

    c=textread(fullfile(InputDir,InputPar),'%s','delimiter','\n');

    %Find intensity_data
    StartInt=contains(c,'#custom_object_intensity_data');
    EndInt=contains(c,'#end_custom_object_intensity_data');

    if ~isempty(find(StartInt==1))
        StartIntPos=find(StartInt==true);
        EndIntPos=find(EndInt==true);

        for i =1:numel(StartIntPos)
            if i==1
                toRemove=StartIntPos(i):EndIntPos(i);
            else
                toRemove=horzcat(toRemove,StartIntPos(i):EndIntPos(i));
            end
        end
        c(toRemove)=[];
    end

    
    for DirNum=1:length(OutputDir)
        filenames=dir(fullfile(InputDir, '*.gda'));
        gdaInputNames={filenames.name};

        filenames=dir(fullfile(OutputDir{DirNum}, '*.gda'));
        gdaOutputNames={filenames.name};

        %Enforce that the two files should have the same number of gda
        assert(length(gdaInputNames)==length(gdaOutputNames),1,...
            'Not the same number of gda files between directories');

        %Swap instances
        for i=1:length(gdaInputNames)
            list=contains(c,gdaInputNames{i});
            ind=find(list==1);
            for j=1:length(ind)
                c{ind(j)}=replace(c{ind(j)},gdaInputNames{i},gdaOutputNames{i});
            end
        end

        %Write new file
        fid=efopen(fullfile(OutputDir{DirNum},OutputPar),'w');
        fprintf(fid,'%s\n',c{:});
        fclose(fid);
    end
end

