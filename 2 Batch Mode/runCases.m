function [] = runCases()
%runCases Calls the windows or linux executable in parallel
    if ispc
       [~,~]=system('CallParallel.bat')
    elseif isunix 
       [status,result]=system('bash CallParallel.sh') 
    end
end

