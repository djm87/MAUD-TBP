function [] = userWizard(parName,WizNum)
%userWizard Users put together combination of functional operations such as
%fix all, free background, free intensity, etc.. that are applied to the
%parameter file and used during the refinement step.
    
    %Read in the parameter file and convert it to a parameterTree 
    par.parName=parName;
    c=readPar(par.parName,''); last=length(c);
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
        %Add your custom refinement here. I suggest you make a funtion
        %following the test example provided below. This makes any action 
        %reusable in other user wizards. Actions are performed using
        %the functionality in changeTree.
        case 1
                        
        case 10000 
            %This runs a test on the core parameter functions to make sure
            %they behave the same as in MAUD.

            %all_refined searches the par for '(' and either adds, remove,
            
            %autotrace or fixes the refined variable by removing '(#.##)'
            isTest=true
            parTest = all_refined(par,2,isTest);
            


            
            
            
            parTest = background_pars(par,1)

            parTest = scale_pars(par,1)

            parTest = basic_pars(par,1)


            parTest = bound_bfactor(par,8)

            parTest = microstructure(par,1)
            par = microstructure(par,2)
            par = microstructure(par,6)
            par = microstructure(par,7)
            
            %This one is inspect manually.. it seems 'free texture' in MAUD
            %doesn't do anything!
            par = refine_texture(par,'true',5)
        otherwise
            error('specified a wizard number that doesn''t exist!');
    end
    
    %Write the changes to a par
    [par,count,c_updated]=parameterTree(par,c,1,last,1,'update c');
    writePar(c_updated,'test.par')

end
%% This block reproduces most of the behavior of core MAUD TreeTable Commands 
function [] = testChange(option,output,isTest)
    if isTest
        for i=1:length(output)
            tmp=eval(output{i});
            if option==1 %refined
                assert(any(contains2(tmp,'(')),'Did not add the refinement flag')
            elseif option==2
                assert(all(~contains2(tmp,'(')),'Did not remove the refinement flag')
            elseif option==5
                assert(all(~contains2(tmp,'(')),'Did not remove the refinement flag')
            elseif option==6
                assert(any(contains2(tmp,'#autotrace')),'Did not add autotrace')
            elseif option==7
                assert(all(~contains2(tmp,'#autotrace')),'Did not remove autotrace')
            elseif option==8
                assert(any(contains2(tmp,'#autotrace')),'Did not add autotrace')
            elseif option==9
                assert(all(~contains2(tmp,'#autotrace')),'Did not remove autotrace')    
            end
        end
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
        
    end
end
function par = all_refined(par,option,isTest)
    assert(option==2 || option==6 || option==7,...
        'Can only pass option 2, 6, 7 ')
    
    keyvar='(';
    output=searchParameterTree(par,keyvar,1); 
    [par] = changeTree(par,output,'run options',par.options{option});
    
    testChange(option,output,isTest)
end
function par = background_pars(par,option)
    assert(option==1 || option==2 || option==6 || option==7,...
        'Can only pass option 1, 2, 6, 7 ')
    %This handles background peaks and the polynomials.
    keyvar='riet_par_background_pol';
    output{1}=searchParameterTree(par,keyvar,1);
    keyvar='riet_par_background_peak_height'
    output{2}=searchParameterTree(par,keyvar,1);
    keyvar='riet_par_background_peak_2th'
    output{3}=searchParameterTree(par,keyvar,1);
    keyvar='riet_par_background_peak_hwhm'
    output{4}=searchParameterTree(par,keyvar,1);

    foutput=vertcat(output{1},output{2},output{3},output{4});
    [par] = changeTree(par,foutput,'run options',par.options{option});
end
function par = scale_pars(par,option)
    assert(option==1 || option==2 || option==6 || option==7,...
        'Can only pass option 1, 2, 6, 7 ')
    
    keyvar='inst_inc_spectrum_scale_factor';
    output=searchParameterTree(par,keyvar,1);
    
    [par] = changeTree(par,output,'run options',par.options{option});
end
function par = basic_pars(par,option)
    assert(option==1 || option==2 || option==6 || option==7,...
        'Can only pass option 1, 2, 6, 7 ')
    
    keyvar='instrument_bank_difc';
    output{1}=searchParameterTree(par,keyvar,1);
    keyvar='cell_length';
    output{2}=searchParameterTree(par,keyvar,1);
    keyvar='atom_site_B_iso_or_equiv';
    output{3}=searchParameterTree(par,keyvar,1);

    foutput=vertcat(output{1},output{2},output{3});
    [par] = changeTree(par,foutput,'run options',par.options{option});
end
function par = bound_bfactor(par,option)
    assert(option==8 || option==9,'Can only pass option 8 or 9')

    keyvar='atom_site_B_iso_or_equiv';
    foutput=searchParameterTree(par,keyvar,1);
    
    if option==8
        [par] = changeTree(par,foutput,'run options',par.options{option});
    elseif option==9
        for i =1:length(foutput)
            tmp=eval(foutput{i});
            tmpend=tmp(end);
            if contains2(tmpend,'#ref')
                [par] = changeTree(par,tmpend,'run options',par.options{option});
            end
        end
    end
end
function par = microstructure(par,option)
    assert(option==1 || option==2 || option==6 || option==7,...
        'Can only pass option 1, 2, 6, 7 ')
    
    keyvar='riet_par_cryst_size';
    output{1}=searchParameterTree(par,keyvar,1);
    keyvar='riet_par_rs_microstrain';
    output{2}=searchParameterTree(par,keyvar,1);


    foutput=vertcat(output{1},output{2});
    [par] = changeTree(par,foutput,'run options',par.options{option});
end
function par = refine_texture(par,value,option)
    assert(option==5 && (strcmp(value,'true') || strcmp(value,'false')),...
        'Can only pass option 5 and value must be either ''true'' or ''false''')
    
    keyvar='_rita_odf_refinable'; %Need to add scope of odf parameters
    output=searchParameterTree(par,keyvar,1);

    [par] = changeTree(par,output,'run options',par.options{option},'value',value);
end