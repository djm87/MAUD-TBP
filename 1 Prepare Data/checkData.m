function [cases] = checkData(samples,nrot)
%checkData Currently is limited to callingh test for rotations
    for i=1:length(samples)
        %Check if data is missing by assuming n number of rotations 
        %Note: Only case that is not handled is if the first gda is missing 
        %3,6,9,...etc times. A much better function can be writen if better 
        %grouping tags are available from the HIPPO run title/ gda header. 
        [isproblem,cases{i}]=checkRotations(samples{i},nrot);
        if isproblem
           error(['Sample ' sampName{i} ': not all data has the same number of rotations']) 
        end
    end
    disp('======================')
    disp('Everything looks good!')
    disp('======================')
end


