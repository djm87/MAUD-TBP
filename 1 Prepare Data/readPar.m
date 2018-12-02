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
    StartInt=contains2(c,'#custom_object_intensity_data');
    EndInt=contains2(c,'#end_custom_object_intensity_data');

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
