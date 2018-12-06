function [c] = readPar(parName)
%[] = readPar(parName,varargin) 
%   Description:readPar reads in a MAUD parameter (.par) file into a cell
%   structure wherein each cell is string containing a line of the
%   parameter file
%
%   Input:  (1) name if local or full path to par file
%   Output: (1) a cell list of strings with each line of the parameter file.

    printMessage('Removing intensity data at import and rewriting par without intensity data for future processing');
    if ispc
      loc=strfind(parName,'\');
    elseif isunix
      loc=strfind(parName,'/');
    end
    tmpPar = [tempname,'.par'];
    [~,~]=system(sprintf('sed -n "/#custom_object_intensity_data/,/#end_custom_object_intensity_data/!p" <%s >%s',parName,tmpPar));
    c=textread(tmpPar,'%s','delimiter','\n');
    if ~isempty(c)
      copyfile(tmpPar,parName);
    end

end
