%Pass in the .par file as cell of strings
function [par,count]=getParameterTree(par,c,count,object,last,lvl)
  if or(strcmp(object,'data_global'),strcmp(object,'data_sample_'))
      id=find(contains(c(count:last),object),1,'first');
      count=id;
        line=c(count);
      fname=line{1}
      while count<last %Assumes 3000 as max 
            count=count+1;
            line=c(count);           
            if isempty(line{1})
               break;
            end
            splitline=split(line);
            var=splitline{1}(2:end);
            par.(fname).(var)=splitline;
      end      
  elseif strcmp(object,'#subordinateObject')
      
    while count<last
        %See if we are at the end of an object
        if ~isempty(find(contains(c(count:last),object),1,'first')+count-1) 
        	id(1)=find(contains(c(count:last),object),1,'first')+count-1;
        else
            break;
        end
%         start_name=c(id(1))
        end_name=['#end_' c{id(1)}(2:end)];

        id(2)=find(contains(c(count:last),end_name),1,'first')+count-1;
        fname=regexprep(c{id(1)}(20:end), ' ','_');
        if ~isvarname(fname)
            strid=strfind(fname, '.');
            if ~isempty(strid)
                fname(strid)='_';
            end
            fname=regexprep(fname, '/','_');
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
        end
        
        par.(fname).start=id(1)+1; %will need a special function to handle names
        par.(fname).end=id(2)-1;
        count=id(1);
        while count<id(2)
            count=count+1;
            %add if to handle the loops
            if and(contains(c(count),'loop_'),...
                    ~contains(c(count+1),'refln_index_h'))
                count=count+1; 
                line=c(count);
                
                %Assumes single variable loop!
%                 if contains(c(count),'refln_index_h')
                var=line{1}(2:end);
                if ~isvarname(var)
                    var=regexprep(var, '%','');
                    var=regexprep(var, '/','_');
                end
                cnt=0;
                while cnt<3000 %Assumes 3000 as max 
                    line=c(count+cnt);
                    if isempty(line{1})
                        count=count+cnt;
                        break;
                    end
                    splitline=split(line);
                    par.(fname).(var){cnt+1}=splitline;
                    cnt=cnt+1;
                end
                if cnt==3000
                   error('max loops reached on loop structure') ;
                end 
            elseif contains(c(count),'#min')
                line=c(count)      ;                
                splitline=split(line);
                var=splitline{1}(2:end);
                if isvarname(var)
                    par.(fname).(var)=splitline;
                end
                %will need special function to hand names and add them to
                %struct
            elseif or(contains(c(count),'_pd_proc_2theta_range_min'),...
                contains(c(count),'_pd_proc_2theta_range_max'))
                line=c(count);
                splitline=split(line);
                var=splitline{1}(2:end);
                par.(fname).(var)=splitline
                
            elseif contains(c(count),object)
                lvl=lvl+1;
                [par.(fname),count]=GetParameterTree(par.(fname),c,count,object,id(2),lvl);
            end
        end
    end
  else
      error('Object passed in is not handled. Please choose from: data_global, data_sample_, or #subordinateObject');
  end

end
