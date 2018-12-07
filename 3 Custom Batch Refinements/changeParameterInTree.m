function [par] = changeParameterInTree(par,input,varargin)
%changeParameterInTree performs one of several simple changes in par
for i=1:length(varargin)
    switch varargin{i}
        
        case 'refine'
            for j=1:length(input)
                par=refineParameter(par,input{j})
            end
            
        case 'fix'
            for j=1:length(input)
                par=fixParameter(par,input{j})
            end
    end
    
end
end

function [par]=fixParameter(par,input)
%     tmp=eval(input)
%     flag=false;
%     for i=1:size(tmp,1)
%         test=contains(tmp{i},'(')
%         
%         if and(any(test), length(test)>1) %handles the loops
%             flag=true;
%             tmp2=tmp{i}(test);
%             loc=strfind(tmp2{1},'(')
%             tmp{i}(test)={tmp2{1}(1:loc-1)}    
%         elseif test
%             flag=true;
%             tmp2=tmp{i};
%             loc=strfind(tmp2,'(')
%             tmp{i}=tmp2(1:loc-1)    
%         end
%     end
%     
    %Access location
    tmp=eval(input{1});
    
    %Set do assignment false unless there is a change
    flag=false;
    szTmp=size(tmp,1);
    
    if and(szTmp>1,strcmp(class(tmp{1}),'cell')) %Then this is a loop
        for i=2:szTmp %start at 2 to skip the loop variable name
           tmp1=tmp{i}(1); %Needed for the nested cell...
           if contains(tmp1{1},'(')
             loc=strfind(tmp1{1},'(')
             tmp{i}(1)={tmp1{1}(1:loc-1)} 
             flag=true;    
           end
        end
    elseif any(and(contains(tmp,'#min'),ischar(tmp{1}))) %Then this is a refinable parameter
           tmp2=tmp{2};
           if contains( tmp2,'(')
             loc=strfind(tmp2,'(')
             tmp{2}=tmp2(1:loc-1)  
             flag=true;    
           end
    else
       tmp
       error('unhandled format: likely passed in a non-refinable parameter!')
    end
    if flag
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
             tmp{i}(1)={strcat(tmp2{1},'(0.0)')}
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
        splitline=split(input,'.');
        switch length(splitline)
            case 1
                error('would overwrite par')
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
                error('the number of split fieldnames was not handled')
        end
    end
end
