function [] = prepareMAUDBatch(cases,sampName,templateParName)
%prepareMAUDBatch Does the same thing as prepareMAUD but only loads the par
%file once per sample and handles names based on

    assert(length(templateParName)==length(sampName),...
    'Please specify the same number of templates as samples' )
    assert(~isempty(dir('*.prm')),...
    'Please sadd .prm file to working directory!' )    

    calibrationFile=dir('*.prm');
    
    for i=1:length(sampName)    
        fprintf('Starting...%s\n',sampName{i})
        fprintf('==================================================\n')
        par=readPar(templateParName{i});
        assert(any(contains2(par,calibrationFile.name)),...
        '!!!Using a template with calibration file different than Sven sent!!!')

        gdaNums2Replace=getGDANumFromPar(par);

        template2folder(par,'Initial_template.par',gdaNums2Replace,...
                cases{i},sampName{i});

        fprintf('==================================================\n\n')
    end
end

