%% Load parameter file into tree
clear all
par.parName='Complicated.par';
% par.parName='Complicated_singlePhase.par';
c=readPar(par.parName,'');

last=length(c);
[par,count,c_updated]=parameterTree(par,c,1,last,1,'read');
%% Options to be tested 
options={'refine','fix','add BK poly coef','remove BK poly coef',...
    'change value to','add output to file','remove output to file',...
    'tie variables together','remove references'}

%% Option 1: refine
%case 1 loop 
%2 variable subordinateObject_PANEL150 bank omega 0

%Currently skips the first loop variable!! 
var={'par.PANEL150_bank_omega_67_5.riet_par_background_pol'}
[par] = changeTree(par,var,'run options',options{1});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
assert(any(contains2(tmp{1},'(')),'did not add refinement keyword')

%1 variable subordinateObject_PANEL150 bank omega 67.5
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'}
[par] = changeTree(par,output2,'run options',options{1});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
for i=1:length(tmp)
    assert(any(contains2(tmp{i},'(')),'did not add refinement keyword')
end
%% Search tree for certain keyword
tic
keyvar='('
foutput=searchParameterTree(par,keyvar,1)
toc
%%
keyvar='Isotropic'
output{1}=searchParameterTree(par,keyvar,1);
keyvar='cell_length'
output{2}=searchParameterTree(par,keyvar,1);
keyvar='instrument_bank_difc'
output{3}=searchParameterTree(par,keyvar,1);


foutput=vertcat(output{1},output{2},output{3});
%%% keyvar='background'
%%
%%
%%
%%%% Filter output from search
has={'length'};
nhas={};
foutput=filterSearchOutput(foutput,has,nhas)




%% change
%pick one
options={'refine','fix','add BK poly coef','remove BK poly coef',...
    'change value to','add output to file','remove output to file',...
    'tie variables together','remove references'}
[par] = changeTree(par,foutput,'run options',options{1});%,'loop index',3) %rename changeTree

%%[par,count,c_updated]=parameterTree(par,c,1,last,1,'update c');
%%writePar(c_updated,'test.par')


