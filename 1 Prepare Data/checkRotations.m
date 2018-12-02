function [isproblem,cases] = checkRotations(range,nrot)
%checkRotations quick check to make sure all textures have the nrotations.
    mcnt=range(1);
    measurementID=0;
    isproblem=false;
    while mcnt<range(end)
        if and(exist([int2str(mcnt) '.gda']),any(range==mcnt))
            measurementID=measurementID+1;
            cases{measurementID,1}=[int2str(mcnt) '.gda'];
            disp(['Measurement ID = ' int2str(measurementID)])        
            disp(['      ' int2str(mcnt) '.gda'])
            for i=1:nrot-1
                mcnt=mcnt+1;
                if exist([int2str(mcnt) '.gda'])
                        disp(['      ' int2str(mcnt) '.gda'])
                        cases{measurementID,1+i}=[int2str(mcnt) '.gda'];
                elseif mcnt>range(end)
                    disp(['      ' 'One or more cases missing first rotation!'])
                    isproblem=true;
                else
                    disp(['      ' 'Missing rotation!'])
                    isproblem=true;
                end

            end
        end
        mcnt=mcnt+1;
    end
end