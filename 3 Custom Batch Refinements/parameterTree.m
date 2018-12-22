function [par,count,c]=parameterTree(par,c,count,last,lvl,flag)
%parameterTree converts a par file that has been read into c by readPar.m
%into a structure of values. Each level of the structure corresponds to a
%loop. When lvl is greater than 1 then the function is processing a nested
%loop. 
%Input:  par - a structure containing select information from the parameter
%           file.
%        c - cell array of parameter file read in by readPar.m 
%        count - current position in reading c. 
%        last - is the last index of c 
%        lvl - correspond to the number of recusions i.e. nested loops
%        flag - two options 'read' and 'update c'. The two modes are identical
%        except that in write mode any modifications present in par are
%        writen back to c.
%Output: par - a structure containing values in the parameter file 
%        count - the position in the parameter file c. This is used in
%           nested loops, 
%        c - when flag is 'update c' c is the updated parameter file that can
%        be writen using the writePar.m function.
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
            
            %Currently these are the key words that are extracted. All
            %refinable parameters contain #min. loop_ variables can also
            %be refinable parameters but a seperate functions is used to
            %read the loop in.
            %To add a key word that you would like extracted just add an
            %elseif line.
            
            if (contains2(c(count),'loop_') && ...
                    ~contains2(c(count+1),'refln_index_h') && ...
                    ~contains2(c(count+1),'odf_values'))
                
               [c,par,count,lastout]=processLoop(par,c,count,fname,last,flag);
               if lastout~=last
                  disp('debug') 
               end
            elseif contains2(c(count),'#min')
                
                [c,par]=getParameter(par,c,count,fname,flag);
                
            elseif contains2(c(count),'_pd_proc_2theta_range_min')
                
                [c,par]=getParameter(par,c,count,fname,flag);
                
            elseif contains2(c(count),'_pd_proc_2theta_range_max')
                
                [c,par]=getParameter(par,c,count,fname,flag);
                
            elseif contains2(c(count),'_rita_wimv_odf_resolution')
                
                [c,par]=getParameter(par,c,count,fname,flag);
                
            elseif contains2(c(count),'_rita_odf_refinable')
                
                [c,par]=getParameter(par,c,count,fname,flag);  

            elseif contains2(c(count),object)
                
                %Recursive call to ParameterTree to extract sub loops
                [par.(fname),count,c]=parameterTree(par.(fname),c,count,id(2),lvl+1,flag);
                
            end
        end
    end
  end
function [par,count,c]=readContinualList(par,c,count,object,last,lvl,flag)
%readContinual list will read keywords and their strings until a blank 
%space occurs.
      id=find(contains2(c(count:last),object),1,'first');
      count=id;
      line=c(count);
      [fname]=createVarName(line{1});

      while count<last 
            count=count+1;
            line=c(count);
            
            %Check if the line is empty
            if isempty(line{1})
               break;
            end
            
            %strsplit line by spaces
            splitline=strsplit(line{1});
            
            %use the first line as name
            var=splitline{1}(2:end);
            if strcmp(flag,'read')
                %write string to struct
                par.(fname).(var)=splitline;
            elseif strcmp(flag,'update c')
                %update the string in c if string in c ~= string in par
                if ~all(strcmp(splitline,strcat(par.(fname).(var))))
                    c(count)=strjoin(par.(fname).(var));
                end
            end
      end
end
function [fname]=createVarName(fname)
%createVarName changes a keyword identifier or object into usuable field
%names for the struct
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
        fname=regexprep(fname, '~','_');
        
        if contains2(fname,'gda')
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
%checkEndObject checks if the end of the object has been reached. If true
%the code the lvl will be exited
        if isempty(find(contains2(c(count:last),object),1,'first')+count-1) 
            output=true;
        else
            output=false;
        end
end
function [id]= getIdObject(c,count,last,object)
%getIdObject get the beginning and the end of an object
    id(1)=find(contains2(c(count:last),object),1,'first')+count-1;
    end_name=['#end_' c{id(1)}(2:end)];
    try
    id(2)=find(contains2(c(count:last),end_name),1,'first')+count-1;
    catch
       error('The read in of the phase will break if you name your phase the same as atom types that are present')
    end
end
function [par]= storeStartEndObject(par,fname,id)
%storeStartEndObject write the beginning and ending line number in the
%global id to the par struct.
        par.(fname).start=id(1)+1; 
        par.(fname).end=id(2)-1;
end
function [c,par,count,last]=processLoop(par,c,count,fname,last,flag)
%processLoop reads in a loop until an empty space marks the end of the
%loop.
    count=count+1;
    line=c(count);
    
    if length(strsplit(line{1}))>1
        error('trying to read a multi variable loop. This is not supported');
    end
    
    %create variable name
    var=line{1}(2:end);
    [var]=createVarName(var);
    
    cnt=1; %counter for loop
    count=count+1; %global counter
    while cnt<last
        line=c(count);
        splitline=strsplit(line{1});
        
        if strcmp(flag,'read')
            if isempty(line{1})
                break;
            end
            par.(fname).(var){cnt,1}=splitline';
        elseif strcmp(flag,'update c')
             %handle the case where a loop variable is added
            if isempty(line{1})
                while cnt<=length(par.(fname).(var))
                    %Lengthen c 
                    c(count+1:end+1)=c(count:end);
                    c(count)=strjoin(par.(fname).(var){cnt});
                    cnt=cnt+1;
                    last=last+1;
                    count=count+1; 
                end
                break;
            elseif cnt > length(par.(fname).(var))
                %if splitline not empty and par empty..deleted loop variable
                c(count)=[];
                count=count-1;
                last=last-1;
            elseif ~all(strcmp(splitline',strcat(par.(fname).(var){cnt})))    
                c{count}=strjoin(par.(fname).(var){cnt});
            end
        end
        count=count+1;
        cnt=cnt+1;
    end
end
function [c,par]=getParameter(par,c,count,fname,flag)
%getParameter reads/write a parameter from/to c from/to par
    line=c(count);
    
    %strsplit line into cells using spaces
    splitline=strsplit(line{1});
    
    %use the keyword to create a field name for par
    var=splitline{1}(2:end);
    [var]=createVarName(var);
    
    if strcmp(flag,'read')
        par.(fname).(var)=splitline;
    elseif strcmp(flag,'update c')
        if length(splitline)~=length(strcat(par.(fname).(var)))
            c{count}=strjoin(par.(fname).(var));
        elseif ~all(strcmp(splitline,strcat(par.(fname).(var))))
            c{count}=strjoin(par.(fname).(var));
        end
        
    end
end