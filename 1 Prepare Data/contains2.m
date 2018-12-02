function [output] = contains2(strings2Search,string2find)
%output is a logical arrayfun
  %find where string occurs
  loc=strfind(strings2Search,string2find);
  output=~cellfun(@isempty,loc);
end