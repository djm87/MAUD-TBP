function [lc] = customRefinements(lc)
%customRefinements If '_cust_analysis_wizard_index' is specified in the
%.ins file, this custom analysis tool userWizard is used. The WizNum in
%this case refers to a user defined sequence of parameter file operations
%that set the run environment for the refinement step in that particular
%par file.
  if any(strcmp(lc.BatchOptions(:,lc.BS), '_cust_analysis_wizard_index'))
    if lc.isMatlab
        parfor i=1:lc.ncases{lc.BS} 
            userWizard(lc.InputPar.FullPath{i,lc.BS},lc.WizNum{i,lc.BS});
        end
    else %Octave
        for i=1:lc.ncases{lc.BS} 
            userWizard(lc.WizNum{i,lc.BS});
        end        
    end
  end

end
