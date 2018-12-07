clear all
par.parName='PARAMETER_freebackgrounds.par';
c=readPar(par.parName);

last=length(c);
[par,count,c_updated]=parameterTree(par,c,1,last,1,'read');

%% Search tree for certain keyword
% keyvar='background_pol'
keyvar='riet_par_background_pol'


output=searchParameterTree(par,keyvar,1)
%% Filter output from search
has={'L90'};
nhas={};
foutput=filterSearchOutput(output,has,nhas)


%% change
%pick one
options={'refine','fix','add BK poly coef','remove BK poly coef',...
    'change value to','add output to file','remove output to file',...
    'tie variables together','remove references'}
[par] = changeTree(par,foutput,'run options',options{9});%,'loop index',3) %rename changeTree

[par,count,c_updated]=parameterTree(par,c,1,last,1,'write');
writePar(c_updated,'test.par')


