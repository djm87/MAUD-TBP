function [par] = changeTree(par,input,varargin)
%changeParameterInTree performs one of several simple changes in par
    runOption=get_option(varargin,'run options');
    assert(~isempty(runOption),'Need to pass an option in...')
    
    switch runOption
        case 'remove references'
            for j=1:length(input)
                par=removeRefTo(par,input{j},varargin{:});
            end
            
        case 'tie variables together'
            disp('Note the first variable is the master')
            par=setEqualTo(par,input,varargin{:});
            
        case 'remove output to file'
            for j=1:length(input)
                par=removeAutotrace(par,input{j},varargin{:});
            end    
            
        case 'add output to file'
            for j=1:length(input)
                par=addAutotrace(par,input{j},varargin{:});
            end 
            
        case 'change value to'
            if (isempty(get_option(varargin,'value')) &&...
               isempty(get_option(varargin,'max')) &&...
               isempty(get_option(varargin,'min')))
                error('Need to pass in atleast the value,min,or max arg')
            end
            for j=1:length(input)
                par=changeValueTo(par,input{j},varargin{:});
            end      
            
        case 'remove BK poly coef'
            for j=1:length(input)
                par=removeVarBKPoly(par,input{j});
            end   
            
        case 'add BK poly coef'
            for j=1:length(input)
                par=addVarBKPoly(par,input{j});
            end
            
        case 'refine'
            for j=1:length(input)
                par=refineParameter(par,input{j});
            end
            
        case 'fix'
            for j=1:length(input)
                par=fixParameter(par,input{j});
            end
            
    end %switch
end 
function [par]=removeRefTo(par,refNum2Remove,varargin)
    assert(~isempty(strfind(refNum2Remove,'#ref')),...
        'To remove a refer pass in the reference number as a cell e.g. {#ref1024}')
    output=searchParameterTree(par,refNum2Remove,1,'mode','exact');
    for i=1:length(output)
        %Access location
        tmp = evaluateStruct(par,output{i});
        
        %Get data type
        dataType = getDataType(tmp);
        
        switch dataType
            case 'refinable loop'
                flag=false;
                for j=1:size(tmp,1)
                    tmpend=tmp{j}(end);
                    if strcmp(tmpend{1},refNum2Remove)
                        id=find(contains2(tmp{j},'#equalTo'));
                        if ~isempty(id)
                           tmp{j}=tmp{j}(1:id-1); 
                        else
                           tmp{j}=tmp{j}(1:end-1);
                        end
                        flag=true;
                    end
                end
                if flag 
                   [par]=updatePar(par,output{i},tmp); 
                end
            case 'refinable variable' 
                tmpend=tmp(end);
                 if strcmp(tmpend{1},refNum2Remove)
                    id=find(contains2(tmp,'#equalTo'));
                    if ~isempty(id)
                       tmp=tmp(1:id-1); 
                    else
                       tmp=tmp(1:end-1);
                    end
                    [par]=updatePar(par,output{i},tmp);
                end
        end
    end
end
function [par]=setEqualTo(par,input,varargin)
    %Access location
    szInput=length(input);
    for i=1:szInput
        tmp{i} = evaluateStruct(par,input{i});
        dataType{i} = getDataType(tmp{i});
    end
    
    %Get data type
    assert(all(contains2(dataType,'refinable variable')),'Can''t tie different variable types');
    assert(length(dataType)>1,'Need to pass atleast two variable...')
    
    equalAdd=get_option(varargin,'equal add');
    equalMult=get_option(varargin,'equal multiply');
    
    if (isempty(equalAdd))
        equalAdd=0.0;
    end
    if (isempty(equalMult))
        equalMult=1.0;
    end    
    
    RefNum=getNextRefNum(par);
    
    switch dataType{1}
        case 'refinable loop'
            error(' Cannot handle the loop variables - you can program it :)')
        case 'refinable variable'
            [flag,refNumUsed]=checkForRef(tmp,szInput);
            if flag
               disp('There is already a reference in one or more of the variables.')
               disp('Remove the current references before applying a new one.')
               disp('References already associated with variables you are trying to tie:')
               for i=1:length(refNumUsed)
                fprintf('%s\n',refNumUsed{i})
               end
            else
                %Set the master
                lenTmp1=length(tmp{1});
                tmp{1}{lenTmp1+1}=strcat('#ref',num2str(RefNum));
                [par]=updatePar(par,input{1},tmp{1});
                
                for i=2:szInput
                 lenTmpi=length(tmp{i});
                 tmp{i}{lenTmpi+1}='#equalTo';
                 tmp{i}{lenTmpi+2}=sprintf('%3.1f',equalAdd);
                 tmp{i}{lenTmpi+3}='+';
                 tmp{i}{lenTmpi+4}=sprintf('%3.1f',equalMult);
                 tmp{i}{lenTmpi+5}='*';
                 tmp{i}{lenTmpi+6}=strcat('#ref',num2str(RefNum));
                 
                 [par]=updatePar(par,input{i},tmp{i}); 
                end
            end
        case 'non-refinable variable'
            disp('non-refinable variable not supported for tying')
            
        case 'non-refinable loop'
            disp('non-refinable loop not supported for tying ')
    end

end
function [flag,refNumUsed]=checkForRef(tmp,szInput)
    flag=false;
    cnt=1;
    refNumUsed=[];
    for i=1:szInput
       if any(contains2(tmp{i},'#ref'))
           flag=true;
           refNumUsed{cnt}=tmp{i}{end};
           cnt=cnt+1;
       end
    end
end
function [RefNum]=getNextRefNum(par)
    maxRefNum=0;
    keyvar='#ref';
    output=searchParameterTree(par,keyvar,1);
    for i=1:length(output)
        %Access location
        tmp = evaluateStruct(par,output{i});

        %Get data type
        dataType = getDataType(tmp);
        
        switch dataType
            case 'refinable loop'
                for j=2:size(tmp,1)
                    tmpend=tmp{j}(end);
                    tmprefnum=str2num(tmpend{1}(5:end));
                    if  tmprefnum>maxRefNum
                        maxRefNum=tmprefnum;
                    end
                end
            case 'refinable variable' 
                tmpend=tmp(end);
                tmprefnum=str2num(tmpend{1}(5:end));
                if  tmprefnum>maxRefNum
                    maxRefNum=tmprefnum;
                end
        end
    end
    RefNum=maxRefNum+1;
end
function [par]=removeAutotrace(par,input,varargin)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    %Get arguments
    loopId=get_option(varargin,'loop index');
    assert(isnumeric(loopId)|| isempty(loopId),'loopId must be an integer');

    switch dataType    
        case 'refinable loop'
           szTmp=size(tmp,1);
           if ~isempty(loopId)
               if szTmp>=loopId
                   if strcmp(tmp{loopId}(2),'#autotrace')
                     tmp2=tmp{loopId};  
                     tmp2(2)=[];
                     tmp{loopId}=tmp2;
                   end
               else
                   disp('loopId specified was greater than the loop, doing nothing')
               end
           else   
             disp('Warning: Passed in loop variable without setting "loop index"');
             disp('Going to change all variables in loop');              
             for i=1:szTmp 
               if strcmp(tmp{i}(2),'#autotrace')
                 tmp2=tmp{i};  
                 tmp2(2)=[];
                 tmp{i}=tmp2;
                 [par]=updatePar(par,input,tmp);    
               end
             end
           end
            
        case 'refinable variable'
           if strcmp(tmp(3),'#autotrace')
             tmp(3)=[];
             [par]=updatePar(par,input,tmp);   
           end 
          
        case 'non-refinable variable'
            disp('autotrace just for refinable parameters')
            
        case 'non-refinable loop'
            disp('autotrace just for refinable parameters')
            
        otherwise
            disp('Passed in non-refineable parameter... nothing done!')
    end
    [par]=updatePar(par,input,tmp);
end
function [par]=addAutotrace(par,input,varargin)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    %Get arguments
    loopId=get_option(varargin,'loop index');
    assert(isnumeric(loopId)|| isempty(loopId),'loopId must be an integer');

    switch dataType    
        case 'refinable loop'
           szTmp=size(tmp,1);
           if ~isempty(loopId)
               if szTmp>=loopId
                   if ~strcmp(tmp{loopId}(2),'#autotrace')
                    tmp{loopId}=[tmp{loopId}(1);{'#autotrace'};tmp{loopId}(2:end)];
                   end
               else
                   disp('loopId specified was greater than the loop, doing nothing')
               end
           else   
             disp('Warning: Passed in loop variable without setting "loop index"');
             disp('Going to change all variables in loop');              
             for i=1:szTmp 
               if ~strcmp(tmp{i}(2),'#autotrace')
                 tmp{i}=[tmp{i}(1);{'#autotrace'};tmp{i}(2:end)];
               end
             end
           end
            
        case 'refinable variable'
           if ~strcmp(tmp(3),'#autotrace')
             if size(tmp,1)<size(tmp,2)
                 tmp=tmp';
             end
             tmp=[tmp(1:2);{'#autotrace'};tmp(3:end)]';
           end
          
        case 'non-refinable variable'
            disp('autotrace just for refinable parameters')
            
        case 'non-refinable loop'
            disp('autotrace just for refinable parameters')
            
        otherwise
            disp('Passed in non-refineable parameter... nothing done!')
    end
    [par]=updatePar(par,input,tmp);
end
function [par]=changeValueTo(par,input,varargin)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    %Get arguments
    argvalue=get_option(varargin,'value');
    argmin=get_option(varargin,'min');
    argmax=get_option(varargin,'max');
    assert(ischar(argvalue) || isempty(argvalue),'inputs must be strings')
    assert(ischar(argmin) || isempty(argmin),'inputs must be strings')
    assert(ischar(argmax) || isempty(argmax),'inputs must be strings')

    loopId=get_option(varargin,'loop index');
    assert(isnumeric(loopId)|| isempty(loopId),'loopId must be an integer')
    
    switch dataType    
        case 'refinable loop'
           szTmp=size(tmp,1);
           if ~isempty(loopId)
              
              if szTmp>=loopId
                 tmp{loopId}=update(tmp{loopId},argvalue,argmin,argmax,dataType);
             else
                  disp('Warning: loopId exceeded the size of the loop, doing nothing')
             end
           else
             disp('Warning: Passed in loop variable without setting "loop index"')
             disp('Going to change all variables in loop')  

             for i=1:szTmp 
                 tmp{i}=update(tmp{i},argvalue,argmin,argmax,dataType);
             end
           end
            
        case 'refinable variable'
            tmp=update(tmp,argvalue,argmin,argmax,dataType);
          
        case 'non-refinable variable'
            tmp=update(tmp,argvalue,argmin,argmax,dataType);
        case 'non-refinable loop'
            error('non-refinable loop is not yet handled')
            
        otherwise
            disp('Passed in non-changable parameter... nothing done!')
    end
    
    [par]=updatePar(par,input,tmp);

end
function [par]=removeVarBKPoly(par,input)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    switch dataType    
        case 'refinable loop'
            if contains2(input,'.riet_par_background_pol')
                %Get size of background polynomial loop
                szTmp=size(tmp,1);

                %remove end of loop
                if szTmp > 0
                    tmp(szTmp)=[];

                    par = updatePar(par,input,tmp);
                end
            end
        otherwise
            disp('Non-background poly passed in.. doing nothing')
    end
end
function [par]=addVarBKPoly(par,input)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    switch dataType    
        case 'refinable loop'
            if contains2(input,'.riet_par_background_pol')
                %Get size of background polynomial loop
                szTmp=size(tmp,1);

                %Add to end of loop
                tmp{szTmp+1,1}={'0.0';'#min';'0.0';'#max';'0.0'};

                par = updatePar(par,input,tmp);
            end
        otherwise
            disp('Non-background poly passed in.. doing nothing')
    end
end
function [par]=fixParameter(par,input)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    switch dataType    
        case 'refinable loop'
            szTmp=size(tmp,1);
            for i=1:szTmp 
               tmp1=tmp{i}(1); %Needed for the nested cell...
               if contains2(tmp1{1},'(');
                 loc=strfind(tmp1{1},'(');
                 tmp{i}(1)={tmp1{1}(1:loc-1)} ;
                 [par]=updatePar(par,input,tmp);  
               end
            end
            
        case 'refinable variable'
           tmp2=tmp{2};
           if contains2( tmp2,'(');
             loc=strfind(tmp2,'(');
             tmp{2}=tmp2(1:loc-1) ; 
             [par]=updatePar(par,input,tmp);  
           end
            
        otherwise
            disp('Passed in non-refineable parameter... nothing done!')
    end
end
function [par]=refineParameter(par,input)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    switch dataType    
        case 'refinable loop'
            szTmp=size(tmp,1);
            for i=1:szTmp 
               tmp2=tmp{i}(1); %Needed for the nested cell...
               if ~contains2(tmp2{1},'(')
                 tmp{i}(1)={strcat(tmp2{1},'(0.0)')};
                 [par]=updatePar(par,input,tmp);
               end
            end
            
        case 'refinable variable'
            if ~contains2(tmp,'(')
                tmp{2}=strcat(tmp{2},'(0.0)');
                [par]=updatePar(par,input,tmp);   
            end
            
        otherwise
            disp('Passed in non-refineable parameter... nothing done!')
    end
    
end
function [par]=updatePar(par,input,tmp)
    splitline=strsplit(input,'.');
    switch length(splitline)
        case 1
            error('would destroy par')
        case 2
            par.(splitline{2})=tmp;
        case 3
            par.(splitline{2}).(splitline{3})=tmp;
        case 4
            par.(splitline{2}).(splitline{3}).(splitline{4})=tmp;      
        case 5
            par.(splitline{2}).(splitline{3}).(splitline{4}).(splitline{5})=tmp; 
        case 6
            par.(splitline{2}).(splitline{3}).(splitline{4}).(splitline{5}).(splitline{6})=tmp;    
        otherwise
            error('the number of split field names was not handled')
    end
end
function [tmp] = evaluateStruct(par,input)
    if ischar(input)
        tmp=eval(input);
    elseif iscell(input)
        tmp=eval(input{1});
    else
        error('unhandled type when evaluating input');
    end
end
function [dataType] = getDataType(tmp)
    if and(iscell(tmp{1}),any(contains2(tmp{1},'#min')))
        dataType='refinable loop';
    elseif iscell(tmp{1})
        dataType='non-refinable loop';
    elseif and(ischar(tmp{1}),any(contains2(tmp,'#min')))
        dataType='refinable variable';
    elseif ischar(tmp{1})
        dataType='non-refinable variable'; 
    else 
        error('unhandle data type!')
    end
end
function tmp = update(tmp,argvalue,argmin,argmax,dataType) 
    switch dataType 
        case 'refinable loop' 
               if ~isempty(argvalue)
                tmp(1)={argvalue};
               end
               if ~isempty(argmin)
                ind=find(contains2(tmp,'#min'))+1;
                tmp(ind)={argmin};
               end
              if ~isempty(argmax)
                ind=find(contains2(tmp,'#max'))+1;
                tmp(ind)={argmax};
              end  
        case 'refinable variable'
               if ~isempty(argvalue)
                tmp(2)={argvalue};
               end
               if ~isempty(argmin)
                ind=find(contains2(tmp,'#min'))+1;
                tmp(ind)={argmin};
               end
              if ~isempty(argmax)
                ind=find(contains2(tmp,'#max'))+1;
                tmp(ind)={argmax};
              end     
        case 'non-refinable variable'
               if ~isempty(argvalue)
                tmp(2)={argvalue};
               end
        otherwise
            disp('unhandled  type in updateNextPlace')
            
    end
    
end