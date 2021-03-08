%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% create .m files with conditions, onsets and durations %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% function
function [] = container_gplus_01_conditions_function(events_files, crun, tgt_dir, spec_name, subj_ID)
    

    
    %% Initialize variables.
    filename = strcat(events_files(crun).folder, '/', events_files(crun).name);
    delimiter = '\t';
    startRow = 2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% automated matlab generated for importing events.tsv files %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Format for each line of text:
    %   column1: double (%f)
    %	column2: double (%f)
    %   column3: categorical (%C)
    %	column4: double (%f)
    %   column5: text (%s)
    %	column6: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%f%f%C%f%s%f%[^\n\r]';
    
    %% Open the text file.
    fileID = fopen(filename,'r');
    
    %% Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    
    %% Close the text file.
    fclose(fileID);
    
    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.
    
    %% Create output variable
    events = table(dataArray{1:end-1}, 'VariableNames', {'onset','duration','trial_type','response_time','stim_file','response'});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% end of automated matlab generated for importing events.tsv files %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% create a cell array containing the names of the conditions, the onsets and the durations
    
    names = categories(events.trial_type)';
    
    for j = 1:length(names)
        for i = 1:length(events.trial_type)
            if names(j) == events.trial_type(i)
                onsets_x(i,j) = events.onset(i);
                durations_x(i,j) = events.duration(i);
            else
                onsets_x(i,j) = 0;
                durations_x(i,j) = 0;
            end
        end
        onsets{1,j} = nonzeros(onsets_x(1:i,j));
        durations{1,j} = nonzeros(durations_x(1:i,j));
    end


    %% save the cell arrays into a .mat-file which spm can read (useful for 1st level - multiple conditions)
    tgt_name = strcat(fullfile(tgt_dir, subj_ID), '/', spec_name, '_conditions.mat');
    save([tgt_name], 'names', 'onsets', 'durations')
    
    %% Clear temporary variables
    clear all
end
