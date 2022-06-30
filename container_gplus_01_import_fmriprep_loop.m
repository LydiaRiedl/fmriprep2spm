%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Script for G+ Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% by Lydia Riedl %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% runs on server 03.08.2020 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% summary
% In a first step, this script writes conditions, onset times and duration
... from events.tsv files and creates a mat-file with these information
... for 1st level analysis with SPM.
% In a second step, this script writes motion regressors in SPM R format
... from regressors.tsv files generated by fmriprep
... for 1st level analysis with SPM.
... if you did not use fmriprep for preprocessing, please COMMENT this step
% In a third step, this script decompresses the gz zipped functional images
... in order to make them readable for SPM,
... and smoothes the fmriprep-preprocessed images (smoothing kernel = [6 6 6])
    ...(because there is no smoothing included in fmriprep).

%% references
% for further infos regarding BIDS format, 
...please check https://bids.neuroimaging.io/
% for further infos regarding fMRIPrep pipeline, 
...please check https://fmriprep.readthedocs.io
% for further infos about G+ project, 
...please check https://osf.io/uh4f9/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% details
% server: mri008
%
% matlab: MATLAB 9.2.0 (R2017a)
%
% spm: SPM12 - started by typing 'spm12' in terminal (on server, SPM12 does
... not start automatically!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inputs
%           files       : all logfiles in current directory
%
%           bids_dir    : Your BIDS directory (with raw functional images)
%           prepro_dir  : Directory of your preprocessed functional images
%
% Abbreviations (project specific), exemplary for G+ project
%           abs         : metaphorical (= abstract) videos
%           con         : iconical (= concrete) videos
% Outputs
%           names       : array with all the condition names
%           onsets      : array with all video onsets and ordered by 
%                         ... condition
%           duration    : array with all video durations ordered by
%                         ... condition
%           matlab writes these variables in a matfile that can be used by
%           ... SPM for 1st level analysis.
%
% Use ctrl-F to find parameters that need to be checked...
...when adjusting to different datasets ("CHECK!")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% HERE THE VARIABLES AND PATHS ARE DEFINED %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% PLEASE ADJUST THE NAMES AND PATHS TO YOUR DATA %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use ctrl-F to find parameters that need to be checked...
...when adjusting to different datasets ("CHECK!")

%% define function
function [] = container_gplus_01_import_fmriprep_loop()

%% as default, clearing all old variables in the workspace
clear,clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% This should be the only input path you have to change %%%%%%%%%
%%%%%%%%%%%%%%%%%%% if your data follows BIDS structure %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% and was preprocessed with fmriprep %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

derivatives_dir = '/YOUR/PATH/derivatives'; % CHECK! Your BIDS derivatives directory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% first create a new directory for analyses in derivatives
mkdir(fullfile(derivatives_dir, '/analyses/import_fmriprep_for_spm_analyses'))

%% adding path and changing working directory
% CAVE! On our clinic server, calculation should always be done in scratch
% directory!
addpath(fullfile(derivatives_dir, '/analyses/import_fmriprep_for_spm_analyses')); % CHECK!
cd(fullfile(derivatives_dir(1:length(derivatives_dir)-12))) % cd(fullfile(derivatives_dir, '/analyses/import_fmriprep_for_spm_analyses')) % CHECK!

%% directories
bids_dir = fullfile(strcat(derivatives_dir(1:length(derivatives_dir)-11), 'bids')); % CHECK! Your BIDS directory
prepro_dir = fullfile(derivatives_dir, '/fmriprep'); % CHECK! Directory of your preprocessed functional images
tgt_dir = fullfile(derivatives_dir, '/analyses/import_fmriprep_for_spm_analyses'); % CHECK! target directory where output files will be stored
jobfile = {'/YOUR/PATH/container_gplus_01_import_fmriprep_res_job.m'};

%% find preprocessed images (ending desc-preproc_bold.nii.gz) in the directory
... with the preprocessed images (incl. subdirectories)
images_dir = dir([prepro_dir '/**/fu*']);
images     = dir([prepro_dir '/**/fu*/*_res-2_desc-preproc_bold.nii.gz']);

%% loop and job settings
nrun = length(images); % enter the number of runs here
nses = length(images_dir); % enter the number of sessions here
jobs = repmat(jobfile, 1, nses);
inputs = cell(2, nses);

%% load spm to enable functions spm_load and spm_jobman
spm12

for crun = 1:nrun
    subj_ID = images(crun).folder(1,strfind(images(crun).folder, 'fmriprep')+9:strfind(images(crun).folder, '/func')-1);
    mkdir(fullfile(tgt_dir, subj_ID)) % create a new directory where the output will be written
    
    spec_name = images(crun).name(1:findstr(images(crun).name, '_space')-1);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%DON'T CHANGE ANYTHING FROM HERE!!!%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% create .m files with conditions, onsets and durations %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% find events.tsv files in BIDS directory (incl. subdirectories)
    events_files = dir([bids_dir '/**/*events.tsv']);
    
    %% define function used to create conditions.mat file
    container_gplus_01_conditions_function(events_files, crun, tgt_dir, spec_name, subj_ID)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% create rp.txt files with motion regressors infos form preprocessing %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% find regressors.tsv files in directory with the (fmriprep) preprocessed
    ...images (incl. subdirectories)
        regressors_files = dir([prepro_dir '/**/*desc-confounds_timeseries.tsv']);
    
    %% define function used to create regressors-rp.txt file
    container_gplus_01_rp_function(regressors_files, crun, tgt_dir, spec_name, subj_ID)
    
end
    
for cses = 1:nses

    subjID = images_dir(cses).folder(1,strfind(images_dir(cses).folder, 'fmriprep')+9:length(images_dir(cses).folder));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% unzip functional 4D images %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%% and smooth the preprocessed images %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %% define inputs for spm_jobman
    inputs{1, cses} = cellstr(fullfile(images_dir(cses).folder)); % path to the directory with the fmriprep preprocessed desc-preproc_bold.nii.gz files of the current subject
    inputs{2, cses} = cellstr(fullfile(tgt_dir, subjID)); % path to the new created target directory of the current subject
    
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});



end
