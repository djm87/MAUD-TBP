function [] = runCases(lc)
%runCases Calls the windows or linux executable in parallel
    if and(ispc,lc.options{3,2})
       [~,~]=system('CallParallel.bat')
    elseif and(isunix,lc.options{3,2})
       [~,~]=system('bash CallParallel.sh') 
    end
end

