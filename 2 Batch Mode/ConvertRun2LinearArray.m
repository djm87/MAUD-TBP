function [lc] = ConvertRun2LinearArray(run)
%ConvertRun2LinearArray This distributes cases accross the cores

    lc=run;
    lc.runtime=cell(10,2);
    
    %Set the concurrent environement for calling MAUD                   
    lc=SetCPUs(lc); 
    
    %Make a 1D struct for each core and fill each with a list from CaseNums
    while true
        for i=1:ceil(lc.ncases/lc.options{1,2})
            for j=1:lc.options{1,2}
                cnt=lc.options{1,2}*(i-1)+j;
                lc.caseID{j}(i)=cnt; %The indices of the appended folders
                if cnt==lc.ncases; break; end
            end 
            if cnt==lc.ncases; break; end
        end
        if cnt==lc.ncases; break; end
    end

end
