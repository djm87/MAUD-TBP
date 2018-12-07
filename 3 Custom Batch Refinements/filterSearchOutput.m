function [input] = filterSearchOutput(input,has,nhas)
%filterSearchOutput excludes/includes input based on key strings
ndel=0;
for i=1:length(input)
        
    test_has=zeros(length(has),1);
    test_nhas=zeros(length(nhas),1);
    for j=1:length(has)
        test_has(j)=contains(input{i-ndel},has{j});
    end
    for j=1:length(nhas)
        test_nhas(j)=~contains(input{i-ndel},nhas{j});
    end
    if ~and(all(test_nhas),all(test_has))
        input(i-ndel)=[];
        ndel=ndel+1;
    end
end

end

