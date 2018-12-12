function [output] = searchParameterTree(par,keyword,lvl)
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
                if contains(structName(j),keyword)
                    searchOutput{searchCnt}=strcat('par.',string(join(structName(1:lvl),'.')));
                    searchCnt=searchCnt+1;
                    flag=false;
                end
            end
            %If keyword isn't in the structName then search values
            if flag
                for j=1:size(par.(fname{i}),1)
                    if strcmp(class(par.(fname{i})),'cell')
                      if any(contains(par.(fname{i}){j,:},keyword))
                        searchOutput{searchCnt}=strcat('par.',string(join(structName(1:lvl),'.')));
                        searchCnt=searchCnt+1;
                      end
                    elseif strcmp(class(par.(fname{i})),'string')
                      if any(contains(par.(fname{i}),keyword))
                        searchOutput{searchCnt}=strcat('par.',string(join(structName(1:lvl),'.')));
                        searchCnt=searchCnt+1;
                      end
                    elseif strcmp(class(par.(fname{i})),'double') 
                      if any(contains(string(par.(fname{i})),keyword))
                        searchOutput{searchCnt}=strcat('par.',string(join(structName(1:lvl),'.')));
                        searchCnt=searchCnt+1;
                      end
                    end
                end
            end
            catch
%                disp('debug') 
            end
        end
    end
    
    if lvl==1
    output=searchOutput';
    end
end
