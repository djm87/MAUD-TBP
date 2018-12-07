function [par,count,c]=parameterTree(par,c,count,last,lvl,flag)

if lvl==1
    [par,~,c]=readContinualList(par,c,count,'data_global',last,lvl,flag);
    [par,count,c]=readContinualList(par,c,count,'data_sample_',last,lvl,flag);
end
    object='#subordinateObject';
    while count<last
        %Check if should exit level
        if checkEndObject(c,count,last,object)
            break; 
        end
        
        %Get the c id of object lines
        id=getIdObject(c,count,last,object);
        
        %Get a name for the object that can be used in a struct
        [fname]=createVarName(regexprep(c{id(1)}(20:end), ' ','_'));
        
        %Store the beginning and end of the object in par.
        par = storeStartEndObject(par,fname,id);
        
        count=id(1);
        
        %This loops through the object trying pull out loops, variables,
        %etc.
        
        while count<id(2)
            count=count+1;
            if and(contains(c(count),'loop_'),...
                    ~contains(c(count+1),'refln_index_h'))
                
               [c,par,count,last]=processLoop(par,c,count,fname,last,flag);
               
            elseif contains(c(count),'#min')
                
                [c,par]=getParameter(par,c,count,fname,flag);
                
            elseif contains(c(count),'_pd_proc_2theta_range_min')
                
                [c,par]=getParameter(par,c,count,fname,flag);
                
            elseif contains(c(count),'_pd_proc_2theta_range_max')
                
                [c,par]=getParameter(par,c,count,fname,flag);
                
            elseif contains(c(count),object)
                
                %Recursive call to ParameterTree to extract sub loops
                %recursively
                [par.(fname),count,c]=parameterTree(par.(fname),c,count,id(2),lvl+1,flag);
                
            end
        end
    end
  end
function [par,count,c]=readContinualList(par,c,count,object,last,lvl,flag)
      id=find(contains(c(count:last),object),1,'first');
      count=id;
        line=c(count);
      fname=line{1};
      while count<last 
            count=count+1;
            line=c(count);           
            if isempty(line{1})
               break;
            end
            splitline=split(line);
            var=splitline{1}(2:end);
            if strcmp(flag,'read')
                par.(fname).(var)=splitline;
            elseif strcmp(flag,'update c')
                if ~all(strcmp(splitline,strcat(par.(fname).(var))))
                    c(count)=join(par.(fname).(var));
                end
            end
      end
end
function [fname]=createVarName(fname)
    if ~isvarname(fname)
        if strcmp(fname(1),'_')
           fname=fname(2:end); 
        end
        strid=strfind(fname, '.');
        if ~isempty(strid)
            fname(strid)='_';
        end
        fname=regexprep(fname, '/','_');
        fname=regexprep(fname, '%','');
        fname=regexprep(fname, '-','_');
        
        if contains(fname,'gda')
            strid=strfind(fname,'g');
            len=length(fname);
            if strcmp(fname(strid+5),')')
                fname=fname([strid:strid+2,1:strid-1,strid+4]);
            else
                fname=fname([strid:strid+2,1:strid-1,strid+4,strid+5]);
            end
        end
        if ~isvarname(fname)
            disp('!!!!! Unhandled Variable Name !!!!!!')
        end
    end
end
function [output]= checkEndObject(c,count,last,object)
        if isempty(find(contains(c(count:last),object),1,'first')+count-1) 
            output=true;
        else
            output=false;
        end
end
function [id]= getIdObject(c,count,last,object)
    id(1)=find(contains(c(count:last),object),1,'first')+count-1;
    end_name=['#end_' c{id(1)}(2:end)];
    id(2)=find(contains(c(count:last),end_name),1,'first')+count-1;
end
function [par]= storeStartEndObject(par,fname,id)
        par.(fname).start=id(1)+1; 
        par.(fname).end=id(2)-1;
end
function [c,par,count,last]=processLoop(par,c,count,fname,last,flag)
    count=count+1;
    line=c(count);
    %Assumes single variable loop!
    var=line{1}(2:end);
    [var]=createVarName(var);
    cnt=1;
    maxLoop=3000;
    while cnt<maxLoop %Assumes data won't exceed as max 
        line=c(count);
        if isempty(line{1})
            %Read in the added BK variables
            if strcmp(flag,'update c')
             exit=true; 
             while exit
              try
                %if field doesn't exist exit while
                tmp=par.(fname).(var){cnt};
                c(count+1:end+1)=c(count:end);
                c(count)=join(tmp);
                cnt=cnt+1;
                last=last+1;
                count=count+1;
              catch
                  exit=false;
                  
              end
             end
            end
%             count=count+1;
            break;
        end
        splitline=split(line);

        if strcmp(flag,'read')
            par.(fname).(var){cnt,1}=splitline;
        elseif strcmp(flag,'update c')
            try
             if ~all(strcmp(splitline,strcat(par.(fname).(var){cnt})))
                c(count)=join(par.(fname).(var){cnt});
             end
            catch
              %if splitline full and par empty means deleted loop variable
              % change c and exit
              c(count)=[];
              count=count-1;
              last=last-1;
            end
        end
        count=count+1;
        cnt=cnt+1;
    end
    if cnt==maxLoop
       error('max loops reached on loop structure') ;
    end 
end
function [c,par]=getParameter(par,c,count,fname,flag)
    line=c(count);                
    splitline=split(line);
    var=splitline{1}(2:end);
    [var]=createVarName(var);
    if strcmp(flag,'read')
        par.(fname).(var)=splitline;
    elseif strcmp(flag,'update c')
        if ~all(strcmp(splitline,strcat(par.(fname).(var))))
            c(count)=join(par.(fname).(var));
        end
        
    end
end