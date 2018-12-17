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
            assert(length(input)==2,'only tying two non-loop variables is supported')
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
function [par]=removeRefTo(par,input,varargin)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    %Get arguments
    loopId=get_option(varargin,'loop index')
    
    switch dataType    
        case 'refinable loop'
           szTmp=size(tmp,1);
           if ~isempty(loopId)
               assert(szTmp>=loopId+1,'loop index greater than loop')
               if any(contains2(tmp{loopId+1},'#equalTo'))
                 tmp2=tmp{loopId+1};  
                 id=find(tmp2=='#equalTo',1)
                 tmp2(id:end)=[];
                 tmp{loopId+1}=tmp2;
                 [par]=updatePar(par,input,tmp);  
               elseif any(contains2(tmp{loopId+1},'#ref'))
                 tmp2=tmp{loopId+1};  
                 tmp2(end)=[];
                 tmp{loopId+1}=tmp2;
                 [par]=updatePar(par,input,tmp);
               end
           else   
             disp('Warning: Passed in loop variable without setting "loop index"')
             disp('Going to change all variables in loop')              
             for i=2:szTmp %start at 2 to skip the loop variable name
               if any(contains2(tmp{i},'#equalTo'))
                 tmp2=tmp{i};  
                 id=find(tmp2=='#equalTo',1)
                 tmp2(id:end)=[];
                 tmp{i}=tmp2;
                 [par]=updatePar(par,input,tmp);  
               elseif any(contains2(tmp{i},'#ref'))
                 tmp2=tmp{i};  
                 tmp2(end)=[];
                 tmp{i}=tmp2;
                 [par]=updatePar(par,input,tmp);
               end
             end
           end
        case 'refinable variable'
           if any(contains2(tmp,'#equalTo'))
             id=find(strcmp(tmp,'#equalTo'),1)
             tmp(id:end)=[];
             [par]=updatePar(par,input,tmp); 
           elseif any(contains2(tmp,'#ref'))
             tmp(end)=[];
             [par]=updatePar(par,input,tmp);  
           end
        case 'non-refinable variable'
            error('autotrace just for refinable parameters')
            
        case 'non-refinable loop'
            error('autotrace just for refinable parameters')
            
        otherwise
            error('Passed in non-refineable parameter... nothing done!')
    end
    
end
function [par]=setEqualTo(par,input,varargin)
    %Access location
    tmp1 = evaluateStruct(par,input{1});
    tmp2 = evaluateStruct(par,input{2});
    assert(size(input,1)<3,'Can only handle variable pairs')

    %Get data type
    dataType1 = getDataType(tmp1);
    dataType2 = getDataType(tmp2);
    assert(dataType1==dataType2,'Can''t tie two different variable types');

    equalAdd=get_option(varargin,'equal add');
    equalMult=get_option(varargin,'equal multiply');
    
    if (isempty(equalAdd))
        equalAdd=0.0;
    end
    if (isempty(equalMult))
        equalMult=1.0;
    end    
    
    RefNum=getNextRefNum(par);
    
    switch dataType1 
        case 'refinable loop'
            error(' Cannot handle the loop variables - you can program it :)')
        case 'refinable variable'
            if (any(contains2(tmp1,'#equalTo')) || any(contains2(tmp2,'#equalTo')))
               disp('There is already a reference in one of the variables')
               disp('Remove the current reference before applying a new one')
            else
             lenTmp1=length(tmp1);
             lenTmp2=length(tmp2);
             tmp1{lenTmp1+1}=strcat('#ref',num2str(RefNum));
             tmp2{lenTmp2+1}='#equalTo';
             tmp2{lenTmp2+2}=sprintf('%3.1f',equalAdd);
             tmp2{lenTmp2+3}='+';
             tmp2{lenTmp2+4}=sprintf('%3.1f',equalMult);
             tmp2{lenTmp2+5}='*';
             tmp2{lenTmp2+6}=strcat('#ref',num2str(RefNum));
             [par]=updatePar(par,input{1},tmp1);
             [par]=updatePar(par,input{2},tmp2); 
            end
        otherwise
            error('Unsupported dataType passed in.. check input')
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
    loopId=get_option(varargin,'loop index')

    switch dataType    
        case 'refinable loop'
           szTmp=size(tmp,1);
           if ~isempty(loopId)
               assert(szTmp>=loopId+1,'loop index greater than loop')
               if strcmp(tmp{loopId+1}(2),'#autotrace')
                 tmp2=tmp{loopId+1};  
                 tmp2(2)=[];
                 tmp{loopId+1}=tmp2;
                 [par]=updatePar(par,input,tmp);   
               end
           else   
             disp('Warning: Passed in loop variable without setting "loop index"')
             disp('Going to change all variables in loop')              
             for i=2:szTmp %start at 2 to skip the loop variable name
               if strcmp(tmp{i}(2),'#autotrace')
                 tmp2=tmp{i};  
                 tmp2(2)=[];
                 tmp{i}=tmp2
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
            error('autotrace just for refinable parameters')
            
        case 'non-refinable loop'
            error('autotrace just for refinable parameters')
            
        otherwise
            disp('Passed in non-refineable parameter... nothing done!')
    end
end
function [par]=addAutotrace(par,input,varargin)
    %Access location
    tmp = evaluateStruct(par,input);
    
    %Get data type
    dataType = getDataType(tmp);
    
    %Get arguments
    loopId=get_option(varargin,'loop index')

    switch dataType    
        case 'refinable loop'
           szTmp=size(tmp,1);
           if ~isempty(loopId)
               assert(szTmp>=loopId+1,'loop index greater than loop')
               if ~strcmp(tmp{loopId+1}(2),'#autotrace')
                tmp{loopId+1}=[tmp{loopId+1}(1);{'#autotrace'};tmp{loopId+1}(2:end)];
                [par]=updatePar(par,input,tmp);   
               end
           else   
             disp('Warning: Passed in loop variable without setting "loop index"')
             disp('Going to change all variables in loop')              
             for i=2:szTmp %start at 2 to skip the loop variable name
               if ~strcmp(tmp{i}(2),'#autotrace')
                 tmp{i}=[tmp{i}(1);{'#autotrace'};tmp{i}(2:end)];
                 [par]=updatePar(par,input,tmp);   
               end
             end
           end
            
        case 'refinable variable'
           if ~strcmp(tmp(3),'#autotrace')
             tmp=[tmp(1:2);{'#autotrace'};tmp(3:end)];
             [par]=updatePar(par,input,tmp);
           end
          
        case 'non-refinable variable'
            error('autotrace just for refinable parameters')
            
        case 'non-refinable loop'
            error('autotrace just for refinable parameters')
            
        otherwise
            disp('Passed in non-refineable parameter... nothing done!')
    end
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

    loopId=get_option(varargin,'loop index')
    
    %Set do assignment false unless there is a change
    flag=false;
    
    switch dataType    
        case 'refinable loop'
           szTmp=size(tmp,1);
           if ~isempty(loopId)
               assert(szTmp>=loopId+1,'loop index greater than loop')
               if ~isempty(argvalue)
                tmp{loopId+1}(1)={argvalue};
                flag=true;
               end
               if ~isempty(argmin)
                tmp{loopId+1}(3)={argmin};
                flag=true; 
               end
              if ~isempty(argmax)
                tmp{loopId+1}(5)={argmax};
                flag=true;  
              end
           else
             disp('Warning: Passed in loop variable without setting "loop index"')
             disp('Going to change all variables in loop')  

             for i=2:szTmp %start at 2 to skip the loop variable name
    %            tmp1=tmp{i}(1); %Needed for the nested cell...
               if ~isempty(argvalue)
                tmp{i}(1)={argvalue};
                flag=true;
               end
               if ~isempty(argmin)
                tmp{i}(3)={argmin};
                flag=true; 
               end
              if ~isempty(argmax)
                tmp{i}(5)={argmax};
                flag=true;  
              end  
             end
           end
            
        case 'refinable variable'
           if ~isempty(argvalue)
            tmp{2}={argvalue};
            flag=true;
           end
           if ~isempty(argmin)
            tmp{4}={argmin};
            flag=true; 
           end
          if ~isempty(argmax)
            tmp{6}={argmax};
            flag=true;  
          end  
          
        case 'non-refinable variable'
            tmp{2}=argvalue;
            flag=true; 
            
        case 'non-refinable loop'
            error('non-refinable loop is not handled')
            
        otherwise
            disp('Passed in non-refineable parameter... nothing done!')
    end
    
    if flag
        [par]=updatePar(par,input,tmp);
    end
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

                %Add to end of loop
                if szTmp > 0
                    tmp{szTmp}=[];

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
                tmp{szTmp+1}={'0.0';'#min';'0.0';'#max';'0.0'};

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
            disp('Look into if loops are handled')
            szTmp=size(tmp,1);
            for i=2:szTmp %start at 2 to skip the loop variable name
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
            disp('Look into if loops are handled')
            szTmp=size(tmp,1);
            for i=2:szTmp %start at 2 to skip the loop variable name
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
    elseif and(ischar(tmp{1}),any(contains2(tmp{1},'#min')))
        dataType='refinable variable';
    elseif ischar(tmp{1})
        dataType='non-refinable variable'; 
    else 
        error('unhandle data type!')
    end
end