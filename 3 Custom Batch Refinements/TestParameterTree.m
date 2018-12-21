%% Load parameter file into tree
clear all

%Select a test par to read in
par.parName='Complicated.par';
% par.parName='Complicated_singlePhase.par';

c=readPar(par.parName,'');

last=length(c);
[par,count,c_updated]=parameterTree(par,c,1,last,1,'read');
%% Options to be tested 
options={'refine','fix','add BK poly coef','remove BK poly coef',...
    'change value to','add output to file','remove output to file',...
    'tie variables together','remove references'};

%% Option 1: refine

%1 variable subordinateObject_PANEL150 bank omega 0
var={'par.PANEL150_bank_omega_67_5.riet_par_background_pol'};
[par] = changeTree(par,var,'run options',options{1});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
assert(any(contains2(tmp{1},'(')),'did not add refinement keyword')

%2 variable subordinateObject_PANEL150 bank omega 67.5
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
[par] = changeTree(par,var,'run options',options{1});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
for i=1:length(tmp)
    assert(any(contains2(tmp{i},'(')),'did not add refinement keyword')
end

%% Option 2: fix

%1 variable subordinateObject_PANEL150 bank omega 0
var={'par.PANEL150_bank_omega_67_5.riet_par_background_pol'};
[par] = changeTree(par,var,'run options',options{2});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
assert(~any(contains2(tmp{1},'(')),'did not add refinement keyword')

%2 variable subordinateObject_PANEL150 bank omega 67.5
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
[par] = changeTree(par,var,'run options',options{2});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
for i=1:length(tmp)
    assert(~any(contains2(tmp{i},'(')),'did not add refinement keyword')
end

%% Option 3: Add BK poly

%1 variable subordinateObject_PANEL150 bank omega 0
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
len_orig=length(eval(var{1}));
[par] = changeTree(par,var,'run options',options{3});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
len_after=length(eval(var{1}));
assert(len_orig<len_after,'Failed to add to poly')

%% Option 4: remove BK poly

%1 variable subordinateObject_PANEL150 bank omega 0
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
len_orig=length(eval(var{1}));
[par] = changeTree(par,var,'run options',options{4});%,'loop index',3) %rename changeTree
tmp=eval(var{1});
len_after=length(eval(var{1}));
assert(len_orig>len_after,'Failed to remove from poly')

%% Option 5: change value to
%Loop test
%test message if max min or value is not passed in - good!

%Test if loopid works
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
tmp_orig=eval(var{1});
change_tmp={'2';'#min';'1.5';'#max';'3'};
[par] = changeTree(par,var,'run options',options{5},'value',change_tmp{1},...
    'min',change_tmp{3},'max',change_tmp{5},'loop index',2);
tmp=eval(var{1});
for i=1:length(tmp{1})
    assert(strcmp(tmp{1}{i},tmp_orig{1}{i}),'Failed to just change loopid');
    assert(strcmp(tmp{2}{i},change_tmp{i}),'Failed to change values');
end
[par] = changeTree(par,var,'run options',options{5},'value',tmp_orig{2}{1},...
    'min',tmp_orig{2}{3},'max',tmp_orig{2}{5},'loop index',2);

%Test if no loopid is passed in that entire loop is set accordingly
tmp_orig=eval(var{1});
change_tmp={'0';'#min';'0';'#max';'0'};
[par] = changeTree(par,var,'run options',options{5},'value',change_tmp{1},...
    'min',change_tmp{3},'max',change_tmp{5});
tmp=eval(var{1});
for i=1:length(tmp{1})
    assert(strcmp(tmp{1}{i},change_tmp{i}),'Failed to just change loopid');
    assert(strcmp(tmp{2}{i},change_tmp{i}),'Failed to change values');
end
[par] = changeTree(par,var,'run options',options{5},'value',tmp_orig{2}{1},...
    'min',tmp_orig{2}{3},'max',tmp_orig{2}{5},'loop index',2);

%Test setting only value, min, or max
tmp_orig=eval(var{1});
change_tmp={'5';'#min';'6';'#max';'7'};
[par] = changeTree(par,var,'run options',options{5},'value',change_tmp{1});
tmp=eval(var{1});
assert(strcmp(tmp{1}{1},change_tmp{1}),'Failed to change values');
assert(strcmp(tmp{2}{1},change_tmp{1}),'Failed to change values');
[par] = changeTree(par,var,'run options',options{5},'min',change_tmp{3});
tmp=eval(var{1});
assert(strcmp(tmp{1}{3},change_tmp{3}),'Failed to change values');
assert(strcmp(tmp{2}{3},change_tmp{3}),'Failed to change values');
[par] = changeTree(par,var,'run options',options{5},'max',change_tmp{5});
tmp=eval(var{1});
assert(strcmp(tmp{1}{5},change_tmp{5}),'Failed to change values');
assert(strcmp(tmp{2}{5},change_tmp{5}),'Failed to change values');

%Test setting only value, min, or max with loopid
tmp_orig=eval(var{1});
change_tmp={'5';'#min';'6';'#max';'7'};
[par] = changeTree(par,var,'run options',options{5},'value',change_tmp{1},'loop index',2);
tmp=eval(var{1});
assert(strcmp(tmp{1}{1},tmp_orig{1}{1}),'Loopid failed');
assert(strcmp(tmp{2}{1},change_tmp{1}),'Failed to change values');
[par] = changeTree(par,var,'run options',options{5},'min',change_tmp{3},'loop index',2);
tmp=eval(var{1});
assert(strcmp(tmp{1}{3},tmp_orig{1}{3}),'Loopid failed');
assert(strcmp(tmp{2}{3},change_tmp{3}),'Failed to change values');
[par] = changeTree(par,var,'run options',options{5},'max',change_tmp{5},'loop index',2);
tmp=eval(var{1});
assert(strcmp(tmp{1}{5},tmp_orig{1}{5}),'Loopid failed');
assert(strcmp(tmp{2}{5},change_tmp{5}),'Failed to change values');

%Test setting only value, min, or max for refinable parameter
var={'par.PANEL150_bank_omega_0_0.LANSCE_Hippo_spectrometer.pd_proc_intensity_incident'};
tmp_orig=eval(var{1});
change_tmp={'6';'#min';'7';'#max';'8'};
[par] = changeTree(par,var,'run options',options{5},'value',change_tmp{1});
tmp=eval(var{1});
assert(strcmp(tmp{2},change_tmp{1}),'Failed to change values');
[par] = changeTree(par,var,'run options',options{5},'min',change_tmp{3});
tmp=eval(var{1});
assert(strcmp(tmp{6},change_tmp{3}),'Failed to change values');
[par] = changeTree(par,var,'run options',options{5},'max',change_tmp{5});
tmp=eval(var{1});
assert(strcmp(tmp{8},change_tmp{5}),'Failed to change values');

 
%Test setting only value, min, or max for non-refinable parameter
var={'par.PANEL150_bank_omega_0_0.pd_proc_2theta_range_min'};
tmp_orig=eval(var{1});
change_tmp={'1.11'};
[par] = changeTree(par,var,'run options',options{5},'value',change_tmp{1});
tmp=eval(var{1});
assert(strcmp(tmp{2},change_tmp{1}),'Failed to change values');

%% Option 6 add autotrace 
%Loop test
%test message if max min or value is not passed in - good!
%Test if loopid works
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
tmp_orig=eval(var{1});
[par] = changeTree(par,var,'run options',options{6},'loop index',2);
tmp=eval(var{1});
assert(strcmp(tmp{1}{2},tmp_orig{1}{2}),'Failed to just change loopid');
assert(strcmp(tmp{2}{2},'#autotrace'),'Failed to change autotrace');

%Test without loop id
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
tmp_orig=eval(var{1});
[par] = changeTree(par,var,'run options',options{6});
tmp=eval(var{1});
assert(strcmp(tmp{1}{2},'#autotrace'),'Failed to change autotrace');
assert(strcmp(tmp{2}{2},'#autotrace'),'Failed to change autotrace');

var={'par.PANEL150_bank_omega_0_0.pd_meas_orientation_omega_offset'};
tmp_orig=eval(var{1});
[par] = changeTree(par,var,'run options',options{6});
tmp=eval(var{1});
assert(strcmp(tmp{3},'#autotrace'),'Failed to change autotrace');

%% Option 7 remove autotrace 
%Loop test
%test message if max min or value is not passed in - good!
%Test if loopid works
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
tmp_orig=eval(var{1});
[par] = changeTree(par,var,'run options',options{7},'loop index',2);
tmp=eval(var{1});
assert(strcmp(tmp{1}{2},tmp_orig{1}{2}),'Failed to just change loopid');
assert(~strcmp(tmp{2}{2},'#autotrace'),'Failed to change autotrace');
[par] = changeTree(par,var,'run options',options{6},'loop index',2);

%Test without loop id
var={'par.PANEL150_bank_omega_0_0.riet_par_background_pol'};
tmp_orig=eval(var{1});
[par] = changeTree(par,var,'run options',options{7});
tmp=eval(var{1});
assert(~strcmp(tmp{1}{2},'#autotrace'),'Failed to change autotrace');
assert(~strcmp(tmp{2}{2},'#autotrace'),'Failed to change autotrace');
[par] = changeTree(par,var,'run options',options{6});


var={'par.PANEL150_bank_omega_0_0.pd_meas_orientation_omega_offset'};
tmp_orig=eval(var{1});
[par] = changeTree(par,var,'run options',options{7});
tmp=eval(var{1});
assert(~strcmp(tmp{3},'#autotrace'),'Failed to change autotrace');
[par] = changeTree(par,var,'run options',options{6});

%% option 8 tie 

var={'par.Magnesium.Atomic_Structure.Mg.atom_site_B_iso_or_equiv';
     'par.Niobium.Atomic_Structure.Nb1.atom_site_B_iso_or_equiv';
     'par.Unknown.Atomic_Structure.Nb1.atom_site_B_iso_or_equiv';
     'par.Unknown.Atomic_Structure.Ni1.atom_site_B_iso_or_equiv';
     'par.Unknown.Atomic_Structure.Ni2.atom_site_B_iso_or_equiv'};
[par] = changeTree(par,var,'run options',options{8});

assert(any(contains2(eval(var{1}),'#ref1440')),'did not set initial ref')
assert(any(contains2(eval(var{2}),'#equalTo')),'did not set initial ref')
assert(any(contains2(eval(var{2}),'#ref1440')),'did not set initial ref')
assert(any(contains2(eval(var{3}),'#equalTo')),'did not set initial ref')
assert(any(contains2(eval(var{3}),'#ref1440')),'did not set initial ref')
assert(any(contains2(eval(var{4}),'#equalTo')),'did not set initial ref')
assert(any(contains2(eval(var{4}),'#ref1440')),'did not set initial ref')
assert(any(contains2(eval(var{5}),'#equalTo')),'did not set initial ref')
assert(any(contains2(eval(var{5}),'#ref1440')),'did not set initial ref')

%% option 9 untie

[par] = changeTree(par,{'#ref1440'},'run options',options{9});

assert(~any(contains2(eval(var{1}),'#ref1440')),'did not remove ref')
assert(~any(contains2(eval(var{2}),'#equalTo')),'did not remove ref')
assert(~any(contains2(eval(var{2}),'#ref1440')),'did not remove ref')
assert(~any(contains2(eval(var{3}),'#equalTo')),'did not remove ref')
assert(~any(contains2(eval(var{3}),'#ref1440')),'did not remove ref')
assert(~any(contains2(eval(var{4}),'#equalTo')),'did not remove ref')
assert(~any(contains2(eval(var{4}),'#ref1440')),'did not remove ref')
assert(~any(contains2(eval(var{5}),'#equalTo')),'did not remove ref')
assert(~any(contains2(eval(var{5}),'#ref1440')),'did not remove ref')

%% pass message
disp('')
disp('=========================================================')
disp('Looks like the changeTree function is operating correctly!')
disp('=========================================================')


