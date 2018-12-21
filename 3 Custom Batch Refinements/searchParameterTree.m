function [output] = searchParameterTree(par,keyword,lvl,varargin)
%This function searches a struct and finds a keyword
%There are two types of key words: 1) is in the struct fieldname, and 2) is in the
%strings or data stored in a particular field.
%
%This code takes a single keyword. When a key word is found, the full
%struct path to that keyword is outputed. Further filtering can be achieved 
%by enforcing the path to contain or exclude other words.
%filterSearchOutput
%
%A recursively loop is used to probe each struct component. 
%A global output is used to span the levels of recursion
%A global struct name is used so that the full struct location is
%   passed to each recursion level and can be exported to the global output. 
    global searchOutput
    global searchCnt
    global structName
    if lvl==1
        searchOutput={};
        searchCnt=1;
    end
    
    mode=get_option(varargin,'mode');
    
    fname=fieldnames(par);
    output={};
    for i=1:length(fname)
        structName{lvl}=fname{i};
        try 
            searchParameterTree(par.(fname{i}),keyword,lvl+1);
        catch
            try
%             searchOutput{searchCnt}=par.(fname{i});
            %First test if keyword is in the structName
            flag=true;
            for j=1:lvl
                if contains2(structName(j),keyword)
                    searchOutput{searchCnt}=strcat('par.',char(strjoin(structName(1:lvl),'.')));
                    searchCnt=searchCnt+1;
                    flag=false;
                end
            end
            %If keyword isn't in the structName then search values
            if flag
                for j=1:size(par.(fname{i}),1)
                    if iscell(par.(fname{i}))
                        %handle the nested cell
                        if iscell(par.(fname{i}){1})
                            var = par.(fname{i}){j,:};  
                        elseif ischar(par.(fname{i}){1})
                            var = par.(fname{i})(j,:); 
                        end
                      if any(contains2(var,keyword))
                        getOutput(var,keyword,lvl,mode)
                      end
                    elseif ischar(par.(fname{i}))
                      var=par.(fname{i});
                      if any(contains2(var,keyword))
                        getOutput(var,keyword,lvl,mode)
                      end
                    elseif isa(par.(fname{i}),'double') 
                      var=num2str(par.(fname{i}));
                      if any(contains2(var,keyword))
                        getOutput(var,keyword,lvl,mode)
                      end
                    end
                end
            end
            catch
                disp('debug') 
            end
        end
    end
    
    if lvl==1
    output=searchOutput';
    end
end
function []=getOutput(var,keyword,lvl,mode)
    global searchOutput
    global searchCnt
    global structName
    
      if strcmp(mode,'exact')
        id=find(contains2(var,keyword));
        if ~isempty(id)
            if strcmp(var{id},keyword)
              searchOutput{searchCnt}=strcat('par.',char(strjoin(structName(1:lvl),'.')));
              searchCnt=searchCnt+1;
            end
        end
      else
          searchOutput{searchCnt}=strcat('par.',char(strjoin(structName(1:lvl),'.')));
          searchCnt=searchCnt+1;
      end
end