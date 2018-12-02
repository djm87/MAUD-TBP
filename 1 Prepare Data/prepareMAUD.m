function [] = prepareMAUD(parInputName,parOutputName,gdaNumsNew)
%prepareMAUD Copies specified gda into the input .par and writes to an
%output .par
    par=readPar(parInputName);
    gdaNums2Replace = getGDANumFromPar(par);
    hasGDA=contains(par,'.gda');
    list=par(hasGDA);
    assert(length(gdaNumsNew)==length(gdaNums2Replace),'different number of rotations')
    for j=1:length(gdaNumsNew)
        for k=1:length(list)
            list{k}=strrep(list{k},...
                [int2str(gdaNums2Replace(j)) '.gda'],[int2str(gdaNumsNew(j)) '.gda']);
        end
    end
    par(hasGDA)=list;
    writePar(par,parOutputName);

end
function [c] = readPar(parName,varargin)
%[] = readPar(parName,varargin) 
%   Description:readPar reads in a MAUD parameter (.par) file into a cell
%   structure wherein each cell is string containing a line of the
%   parameter file
%
%   Input:  (1) name if local or full path to par file
%   Option: (1) set flag = 'keep intensity' to keep intensity data on read in 
%   Output: (1) a cell list of strings with each line of the parameter file.
    if ( length(varargin) == 0) %default if no option specified
        disp('Default: removing intensity data at import')
        flag='remove intensity';
    elseif strcmp( varargin{1},'keep intensity') %Keep intensity if specified
        flag=varargin{1};
    else %If something specified but not handled tell user default option is being used
        disp('Undefined option, setting default "remove intensity"')
        flag='remove intensity';
    end
    
    %read from MAUD parameter file
    c=textread(parName,'%s','delimiter','\n');
    %See if intensity data exists
    StartInt=contains(c,'#custom_object_intensity_data');
    EndInt=contains(c,'#end_custom_object_intensity_data');

    StartIntPos=find(StartInt==true);
    
    if isempty(StartIntPos)
        disp('No intensity data found in MAUD parameter file')
    else
        if strcmp(flag,'keep intensity')
            disp('Keeping intensity data')
        else
            %Remove the intensity data from c
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
    end

end
function [] = writePar(c,parNameOut,varargin)
%[] = writePar(c,parNameOut,varargin) 
%   Description: readPar writes a MAUD parameter (.par) file from a cell 
%   structure wherein each cell is string containing a line of the 
%   parameter file
%
%   Input:  (1) a cell list of strings with each line of the parameter file,
%           (2)name of local or full path to par file
%   Option: (1) set flag = 'keep intensity' to keep intensity data on write in 
%   Note: Removing intensity data will improve write time
    if ( length(varargin) == 0) %default if no option specified
        flag='remove intensity';
    elseif strcmp( varargin{1},'keep intensity') %Keep intensity if specified
        flag=varargin{1};
    else %If something specified but not handled tell user default option is being used
        disp('Undefined option, setting default "remove intensity"')
        flag='remove intensity';
    end
        
    %See if intensity data exists
    StartInt=contains(c,'#custom_object_intensity_data');
    EndInt=contains(c,'#end_custom_object_intensity_data');

    StartIntPos=find(StartInt==true);
    
    if isempty(StartIntPos)
%         disp('No intensity data found in MAUD parameter file')
    else
        if strcmp(flag,'keep intensity')
            disp('Keeping intensity data')
        else
            %Remove the intensity data from c
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
    end
    
    %Write c to parameter file
    fid=efopen(parNameOut,'w');
    fprintf(fid,'%s\n',string(c(:)));
    fclose(fid);

end
function [uniqueGDANums] = getGDANumFromPar(par)
%getGDANumFromPar this searches for unique gda numbers in par and returns
%those numbers
hasGDA=contains(par,'.gda');
list=par(hasGDA);
gdaNums=zeros(length(list),1);
for i=1:length(list)
    id=strfind(list{i},'.gda');
    status=true;
    cnt=0;
    while status
        cnt=cnt+1; 
        [num,status]=str2num(list{i}(id-cnt:id-1));
        if status~=true
            [gdaNums(i)]=str2num(list{i}(id-cnt+1:id-1));
        elseif length(id-cnt:id-1)>10
            error('for some reason the gda length is very high... something is wrong')
        end
    end
    
      
end
uniqueGDANums=unique(gdaNums);

end

