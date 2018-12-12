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
function [] = userWizard(parName,WizNum)
%userWizard Users put together combination of functional operations such as
%fix all, free background, free intensity, etc.. that are applied to the
%parameter file and used during the refinement step.
    
    %Read in the parameter file and convert it to a parameterTree 
    par.parName=parName;
    c=readPar(par.parName); last=length(c);
    [par,count,c_updated]=parameterTree(par,c,1,last,1,'read');
    
    %Available operations
    par.options={'refine',...%1
                 'fix',... %2
                 'add BK poly coef',... %3
                 'remove BK poly coef',... %4
                 'change value to',... %5
                 'add output to file',... %6
                 'remove output to file',... %7
                 'tie variables together',...%8
                 'remove references'} %9

    %Set the refinement parameters in the parameterTree
    switch WizNum 
    case 1
        [par] = changeTree(par,foutput,'run options',options{9});
    otherwise
        error('specified a wizard number that doesn''t exist!');
    end
    
    %Write the 
    [par,count,c_updated]=parameterTree(par,c,1,last,1,'update c');
    writePar(c_updated,'test.par')

end
%% This block reproduces most of the behavior of core MAUD TreeTable Commands 
function par = all_refined(par,option)
    keyvar='(';
    foutput=searchParameterTree(par,keyvar,1);
    [par] = changeTree(par,foutput,'run options',option);
end
function par = background_pars(par,option)
    %This handles background peaks and the polynomials.
    keyvar='riet_par_background_pol';
    output{1}=searchParameterTree(par,keyvar,1);
    keyvar='riet_par_background_peak_height'
    output{2}=searchParameterTree(par,keyvar,1);
    keyvar='riet_par_background_peak_2th'
    output{3}=searchParameterTree(par,keyvar,1);
    keyvar='iet_par_background_peak_hwhm'
    output{4}=searchParameterTree(par,keyvar,1);

    foutput=vertcat(output{1},output{2},output{3},output{4});
    [par] = changeTree(par,foutput,'run options',option);
end
function par = scale_pars(par,option)
    keyvar='inst_inc_spectrum_scale_factor';

    foutput=searchParameterTree(par,keyvar,1);
    [par] = changeTree(par,foutput,'run options',option);
end
function par = basic_pars(par,option)
    keyvar='instrument_bank_difc';
    output{1}=searchParameterTree(par,keyvar,1);
    keyvar='cell_length';
    output{2}=searchParameterTree(par,keyvar,1);
    keyvar='atom_site_B_iso_or_equiv';
    output{3}=searchParameterTree(par,keyvar,1);

    foutput=vertcat(output{1},output{2},output{3});
    [par] = changeTree(par,foutput,'run options',option);
end
function par = bound_bfactor(par,option)
    keyvar='atom_site_B_iso_or_equiv';
    foutput=searchParameterTree(par,keyvar,1);
    
    len=length(foutput);
    if len>1
        [par] = changeTree(par,foutput,'run options',par.options{option});
        for i = 2:len
            [par] = changeTree(par,foutput([1,i]),'run options',par.options{8});
        end

    else
    end
end
function par = microstructure(par,option)
    keyvar='riet_par_cryst_size';
    output{1}=searchParameterTree(par,keyvar,1);
    keyvar='riet_par_rs_microstrain';
    output{2}=searchParameterTree(par,keyvar,1);


    foutput=vertcat(output{1},output{2});
    [par] = changeTree(par,foutput,'run options',option);
end
function par = texture(par,option)
    keyvar='_rita_odf_refinable'; %Need to add scoop of odf parameters
    foutput=searchParameterTree(par,keyvar,1);

    foutput=vertcat(output{1},output{2});
    [par] = changeTree(par,foutput,'run options',option);
end
function par = backgrounds(par,option)

end 