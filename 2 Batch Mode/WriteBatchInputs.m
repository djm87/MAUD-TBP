function [lc] = WriteBatchInputs(lc)
%WriteBatchInputs Writes the batch inputs for each cpu
    for i=1:lc.options{1,2} 
        insName=['Maud_Batch_input_' int2str(i) '.ins'];
        
        
        if ispc
            lc.batName{i}=['Maud_Batch_input_' int2str(i) '.bat'];
            fid=fopen(lc.batName{i},'w');
            fprintf(fid,'%s\n',...
             ['start /b /wait jre\bin\java -mx8192M -cp lib/Maud.jar;lib/ij.jar com.radiographema.MaudText -f %cd%\',insName]);
            fprintf(fid,'EXIT\n');
            fclose(fid);
        end
        
        fid=fopen(insName,'w');
        fprintf(fid,'loop_\n');
        for j=1:length(lc.BatchOptions) 
            fprintf(fid,'%s\n',lc.BatchOptions{j});
        end
        
        fprintf(fid,'\n');
        
        for j=1:length(lc.caseID{i})
            id=lc.caseID{i}(j);
            for k=1:length(lc.BatchOptions)       
                switch lc.BatchOptions{k}
                    case "_riet_analysis_file"
                      fprintf(fid,'%s ',lc.InputPar{id});
                    case "_riet_analysis_wizard_index"
                      fprintf(fid,'%s ',lc.NIter{id});
                    case "_riet_analysis_iteration_number"
                      fprintf(fid,'%s ',lc.WizNum{id});
                    case "_riet_analysis_fileToSave"
                      fprintf(fid,'%s ',lc.OutputPar{id});
                    case "_riet_meas_datafile_name"
                      fprintf(fid,'%s ',lc.measDatafileNam{id});
                    case "_riet_append_simple_result_to"
                      % handle potential write conflicts 
                      newstr=['_CPU' int2str(i) '.txt'];
                      lc.OutputResult{id}=strrep(...
                          lc.OutputResult{id},'.txt',newstr);
                      fprintf(fid,'%s ',lc.OutputResult{id});
                    case "_riet_append_result_to"
                      % handle potential write conflicts 
                      newstr=['_CPU' int2str(i) '.txt'];
                      lc.OutputResultSaveFlag{id}=strrep(...
                          lc.OutputResultSaveFlag{id},'.txt',newstr);
                      fprintf(fid,'%s ',lc.OutputResultSaveFlag{id});
                    case "_riet_meas_datafile_replace"
                      fprintf(fid,'%s ',lc.MeasDatafileReplace{id});
                    case "_maud_background_add_automatic"
                      fprintf(fid,'%s ',lc.AutoAddBK{id});
                    case "_maud_output_plot_filename"
                      fprintf(fid,'%s ',lc.OutputPlot{id});
                end
            end
            fprintf(fid,'\n');
                
                
        end
        fclose(fid);
    end
end