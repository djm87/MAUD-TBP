function [uniqueGDANums] = getGDANumFromPar(par)
%getGDANumFromPar this searches for unique gda numbers in par and returns
%those numbers
hasGDA=contains2(par,'.gda');
list=par(hasGDA);
gdaNums=zeros(length(list),1);
for i=1:length(list)
    id=strfind(list{i},'.gda');
    status=true;
    cnt=0;
    while status
        cnt=cnt+1; 
        [num,status]=str2num(list{i}(id-cnt:id-1));
        if status~=true
            [gdaNums(i)]=str2num(list{i}(id-cnt+1:id-1));
        elseif length(id-cnt:id-1)>10
            error('for some reason the gda length is very high... something is wrong')
        end
    end
    
      
end
uniqueGDANums=unique(gdaNums);

end

