function [samples] = groupMeasurements(outputName)
%groupSamples Takes gda and groups them based on common run name

    %load the runTitles in a variable we can work with
    c=textread(outputName,'%s','delimiter','\n');
    
    %group similar names together.
    cnt=0;
    groupCnt=1;
    groupID=zeros(length(c),1);
    while cnt< length(c)
        cnt=cnt+1; 
        line=c{cnt};
        splitline=strsplit(line,',');
        fname=strjoin(splitline(2:end-1),',');
        group{groupCnt}.id=find(contains2(c,fname));
        group{groupCnt}.len=length(group{groupCnt}.id);
        groupID(group{groupCnt}.id)=groupCnt;
        cnt=max(group{groupCnt}.id);
        groupCnt=groupCnt+1;

    end

    %extract the list of gda numbers (assuming 5 digits! Increase when over 100000.gda)
    tmp = cellfun(@(x){x(1:5)}, c);
    gdaNumList = str2num(vertcat(tmp{:}));

    %Create gda list with each cell being a sample
    lenGroup=length(group);
    samples=cell(lenGroup,1);
    for i=1:lenGroup
        samples{i,1}=gdaNumList(group{i}.id(:));
    end

end

