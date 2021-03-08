%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% create rp.txt files with motion regressors infos form preprocessing %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% function
function [] = container_gplus_01_rp_function(regressors_files, crun, tgt_dir, spec_name, subj_ID)

    filename = strcat(regressors_files(crun).folder, '/', regressors_files(crun).name);
    confounds = spm_load([strcat(regressors_files(crun).folder, '/', regressors_files(crun).name)]);

    
    %% Creating output variables
    R1 = confounds.trans_x; % trans x
    R2 = confounds.trans_y; % trans y
    R3 = confounds.trans_z; % trans z
    R4 = confounds.rot_x; % rot x
    R5 = confounds.rot_y; % rot y
    R6 = confounds.rot_z; % rot z
    
    %% Creating an array R from the generated output variables
    R = [R1 R2 R3 R4 R5 R6];
    
    %% Saving the array R
    tgt_name = strcat(fullfile(tgt_dir, subj_ID), '/', spec_name, '_desc-confounds_regressors-rp.txt');
    save(tgt_name, 'R', '-ascii')
    
    %% Clear temporary variables
    clear all

end