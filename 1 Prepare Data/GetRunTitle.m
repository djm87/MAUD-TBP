function [status,cmdout] = GetRunTitle(str2find,outputName,overWrite)

    if or(~exist(outputName),overWrite)
        if ispc
            [status,cmdout]= system(['findstr  /c:"' str2find '" *.gda > ' outputName]);
        elseif isunix
            [status,cmdout]= system(['grep '  str2find ' *.gda > ' outputName]);
        end
    else
        disp('!!! File already exists and overWrite is set to false... doing nothing!!!')
    end
end
