gcp
tic
[~,~]=system('Maud_batch.bat');   
time_single=toc

tic
parfor i =1:4
    if i==1
       [~,~]=system('Maud_batch.bat');
    elseif i==2
       [~,~]=system('Maud_batch2.bat');
    elseif i==3
       [~,~]=system('Maud_batch3.bat');
    elseif i==4
       [~,~]= system('Maud_batch4.bat');   
    end
end
time_parallel=toc

speedup=time_single*4/time_parallel
delete(gcp('nocreate')) 
