function [lc] = extractMAUDPhases(lc)
%extractMAUDPhases pulls all the phase information from MAUD
    phase=cell(lc.ncases{lc.BS} ,1);    
    if lc.isMatlab
        parfor i=1:lc.ncases{lc.BS} 
            phase{i}=ExtractPhaseFromPar(lc.OutputPar.FullPath{i,lc.BS});
        end
    else %Octave
        for i=1:lc.ncases{lc.BS} 
            phase{i}=ExtractPhaseFromPar(lc.OutputPar.FullPath{i,lc.BS});
        end        
    end
    lc.phase{lc.BS}=phase;
end
