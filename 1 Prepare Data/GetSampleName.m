function [fname] = GetSampleName(c,gdaNum)
%GetSampleName Takes a run list and extracts the sample name
    line=c{contains2(c,num2str(gdaNum))};
    splitline=strsplit(line,',');

    fname=strjoin(splitline(2:end-1),'_');
    %fname=fname{1};

    %A matlab variable is an ok file name..
    if ~isvarname(fname)

        if strcmp(fname(1),'_')
           fname=fname(2:end); 
        end

        strid=strfind(fname, '.');
        if ~isempty(strid)
            fname(strid)='p';
        end

        fname=regexprep(fname, '/','_');
        fname=regexprep(fname, '%','p');
        fname=regexprep(fname, ' ','');
        fname=regexprep(fname, '-','_');
        fname=regexprep(fname, '#','num');
        if ~isvarname(fname)
           fname = genvarname(fname);
        end
    end

end

