function [run] = readIns(insName)
%readIns Reads in .ins batch files into a struct
    c=textread(insName,'%s','delimiter','\n');

    cnt=2;
    while ~isempty(c{cnt})
        run.BatchOptions{cnt-1}=c{cnt};
        cnt=cnt+1;
    end

    run.cases2Run=c(cnt+1:end);
    run.ncases=length(run.cases2Run);

    for i=1:run.ncases
        curCase=strsplit(run.cases2Run{i});
        for j=1:length(run.BatchOptions)      
            switch run.BatchOptions{j}
                case "_riet_analysis_file"
                  run.InputPar{i}=curCase{j};
                case "_riet_analysis_wizard_index"
                  run.NIter{i}=curCase{j};
                case "_riet_analysis_iteration_number"
                  run.WizNum{i}=curCase{j}; 
                case "_riet_analysis_fileToSave"
                  run.OutputPar{i}=curCase{j};
                case "_riet_meas_datafile_name"
                  run.measDatafileNam{i}=curCase{j};
                case "_riet_append_simple_result_to"
                  run.OutputResult{i}=curCase{j};
                case "_riet_append_result_to"
                  run.OutputResultSaveFlag{i}=curCase{j};
                case "_riet_meas_datafile_replace"
                  run.MeasDatafileReplace{i}=curCase{j};
                case "_maud_background_add_automatic"
                  run.AutoAddBK{i}=curCase{j};
                case "_maud_output_plot_filename"
                  run.OutputPlot{i}=curCase{j};
            end
        end
    end


end

