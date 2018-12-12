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
            disp('only tying two non-loop variables is supported')
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
    tmp=eval(input{1});
    
    loopId=get_option(varargin,'loop index')

    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
       if ~isempty(loopId)
           assert(szTmp>=loopId+1,'loop index greater than loop')
           if any(contains(tmp{loopId+1},'#equalTo'))
             tmp2=tmp{loopId+1};  
             id=find(tmp2=='#equalTo',1)
             tmp2(id:end)=[];
             tmp{loopId+1}=tmp2;
             flag=true;  
           elseif any(contains(tmp{loopId+1},'#ref'))
             tmp2=tmp{loopId+1};  
             tmp2(end)=[];
             tmp{loopId+1}=tmp2;
             flag=true;
           end
       else   
         disp('Warning: Passed in loop variable without setting "loop index"')
         disp('Going to change all variables in loop')              
         for i=2:szTmp %start at 2 to skip the loop variable name
           if any(contains(tmp{i},'#equalTo'))
             tmp2=tmp{i};  
             id=find(tmp2=='#equalTo',1)
             tmp2(id:end)=[];
             tmp{i}=tmp2;
             flag=true;  
           elseif any(contains(tmp{i},'#ref'))
             tmp2=tmp{i};  
             tmp2(end)=[];
             tmp{i}=tmp2;
             flag=true;
           end
         end
       end
    elseif any(and(contains(tmp,'#min'),ischar(tmp{1}))) %Then this is a refinable parameter
           if any(contains(tmp,'#equalTo'))
             id=find(strcmp(tmp,'#equalTo'),1)
             tmp(id:end)=[];
             flag=true;  
           elseif any(contains(tmp,'#ref'))
             tmp(end)=[];
             flag=true;  
           end
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end

    if flag
        [par]=updatePar(par,input,tmp);
    end
end
function [par]=setEqualTo(par,input,varargin)
     %Access location
    tmp1=eval(input{1});
    tmp2=eval(input{2});
    
    equalAdd=get_option(varargin,'equal add');
    equalMult=get_option(varargin,'equal multiply');
    
    if (isempty(equalAdd))
        equalAdd=0.0;
    end
    if (isempty(equalMult))
        equalMult=1.0;
    end    
    
    RefNum=getNextRefNum(par);

    %Set do assignment false unless there is a change
    flag=false;    
    if and(size(tmp1,1)>1,strcmp(class(tmp1{1}),'cell')) %Then this is a loop
         error(' Cannot handle the loop variables - you can program it :)')
    elseif and(size(tmp2,1)>1,strcmp(class(tmp1{1}),'cell')) %Then this is a loop
         error(' Cannot handle the loop variables - you can program it :)')
    elseif size(input,1)>2 %Then the input is invalid
         error(' Cannot handle more than one pair')
    elseif and(any(and(contains(tmp1,'#min'),ischar(tmp1{1}))),... %Then this is a non-loop refinable parameter
           any(and(contains(tmp2,'#min'),ischar(tmp2{1}))))
       if (any(contains(tmp1,'#equalTo')) || any(contains(tmp2,'#equalTo')))
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
         flag=true;  
       end
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end

    if flag
        [par]=updatePar(par,input{1},tmp1);
        [par]=updatePar(par,input{2},tmp2);
    end
end
function [RefNum]=getNextRefNum(par)
    maxRefNum=0;
    keyvar='#ref';
    output=searchParameterTree(par,keyvar,1);
    for i=1:length(output)
        tmp=eval(output{i});
        szTmp=size(tmp,1);
        if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
            for j=2:size(tmp,1)
                tmpend=tmp{j}(end);
                tmprefnum=str2num(tmpend{1}(5:end));
                if  tmprefnum>maxRefNum
                    maxRefNum=tmprefnum;
                end
            end
        elseif any(and(contains(tmp,'#min'),ischar(tmp{1})))
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
    tmp=eval(input{1});
    
    loopId=get_option(varargin,'loop index')

    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
       if ~isempty(loopId)
           assert(szTmp>=loopId+1,'loop index greater than loop')
           if strcmp(tmp{loopId+1}(2),'#autotrace')
             tmp2=tmp{loopId+1};  
             tmp2(2)=[];
             tmp{loopId+1}=tmp2;
             flag=true;    
           end
       else   
         disp('Warning: Passed in loop variable without setting "loop index"')
         disp('Going to change all variables in loop')              
         for i=2:szTmp %start at 2 to skip the loop variable name
           if strcmp(tmp{i}(2),'#autotrace')
             tmp2=tmp{i};  
             tmp2(2)=[];
             tmp{i}=tmp2
             flag=true;    
           end
         end
       end
    elseif any(and(contains(tmp,'#min'),ischar(tmp{1}))) %Then this is a refinable parameter
       if strcmp(tmp(3),'#autotrace')
         tmp(3)=[];
         flag=true;   
       end
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end

    if flag
        [par]=updatePar(par,input,tmp);
    end
end
function [par]=addAutotrace(par,input,varargin)
    %Access location
    tmp=eval(input{1});
    
    loopId=get_option(varargin,'loop index')

    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
       if ~isempty(loopId)
           assert(szTmp>=loopId+1,'loop index greater than loop')
           if ~strcmp(tmp{loopId+1}(2),'#autotrace')
            tmp{loopId+1}=[tmp{loopId+1}(1);{'#autotrace'};tmp{loopId+1}(2:end)];
            flag=true;    
           end
       else   
         disp('Warning: Passed in loop variable without setting "loop index"')
         disp('Going to change all variables in loop')              
         for i=2:szTmp %start at 2 to skip the loop variable name
           if ~strcmp(tmp{i}(2),'#autotrace')
             tmp{i}=[tmp{i}(1);{'#autotrace'};tmp{i}(2:end)];
             flag=true;    
           end
         end
       end
    elseif any(and(contains(tmp,'#min'),ischar(tmp{1}))) %Then this is a refinable parameter
       if ~strcmp(tmp(3),'#autotrace')
         tmp=[tmp(1:2);{'#autotrace'};tmp(3:end)];
         flag=true;   
       end
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end

    if flag
        [par]=updatePar(par,input,tmp);
    end
end
function [par]=changeValueTo(par,input,varargin)
    %Access location
    tmp=eval(input{1});
    
    argvalue=get_option(varargin,'value');
    argmin=get_option(varargin,'min');
    argmax=get_option(varargin,'max');

    loopId=get_option(varargin,'loop index')
    
    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
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
    elseif any(and(contains(tmp,'#min'),ischar(tmp{1}))) %Then this is a refinable parameter
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
    elseif ischar(tmp{1}) %This is a none refinable parameter such as 2theta range min/max
        tmp{2}=argvalue;
        flag=true; 
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end
    
    if flag
        [par]=updatePar(par,input,tmp);
    end
end
function [par]=removeVarBKPoly(par,input)
    %Access location
    tmp=eval(input{1});
    
    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %BK poly is always a loop
        %Copy from var that exists 
        tmp(szTmp)=[]; 
        
        flag=true;

    end
    
    if flag
        [par]=updatePar(par,input,tmp);
    end
end
function [par]=addVarBKPoly(par,input)
    %Access location
    tmp=eval(input{1});
    
    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %BK poly is always a loop
        %Copy from var that exists 
        tmp{szTmp+1}=tmp{szTmp}; 
        
        %reset value,min, and max to zero
        tmp{szTmp+1}(1)={'0.0'};
        tmp{szTmp+1}(3)={'0.0'};
        tmp{szTmp+1}(5)={'0.0'};
        
        flag=true;
    end
    
    if flag
        par = updatePar(par,input,tmp);
    end
end
function [par]=fixParameter(par,input)
    %Access location
    tmp=eval(input{1});
    
    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
        for i=2:szTmp %start at 2 to skip the loop variable name
           tmp1=tmp{i}(1); %Needed for the nested cell...
           if contains(tmp1{1},'(');
             loc=strfind(tmp1{1},'(');
             tmp{i}(1)={tmp1{1}(1:loc-1)} ;
             flag=true;    
           end
        end
    elseif any(and(contains(tmp,'#min'),ischar(tmp{1}))) %Then this is a refinable parameter
           tmp2=tmp{2};
           if contains( tmp2,'(');
             loc=strfind(tmp2,'(');
             tmp{2}=tmp2(1:loc-1) ; 
             flag=true;    
           end
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end

    if flag
        [par]=updatePar(par,input,tmp);
    end

end
function [par]=refineParameter(par,input)
    %Access location
    tmp=eval(input{1});
    
    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
        for i=2:szTmp %start at 2 to skip the loop variable name
           tmp2=tmp{i}(1); %Needed for the nested cell...
           if ~contains(tmp2{1},'(')
             tmp{i}(1)={strcat(tmp2{1},'(0.0)')};
             flag=true;
           end
        end
    elseif any(and(contains(tmp,'#min'),ischar(tmp{1}))) %Then this is a refinable parameter
           if ~contains(tmp,'(')
             tmp{2}=strcat(tmp{2},'(0.0)');
             flag=true;    
           end
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end
    
    if flag
        [par]=updatePar(par,input,tmp);
    end
end
function [par]=updatePar(par,input,tmp)
    splitline=split(input,'.');
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