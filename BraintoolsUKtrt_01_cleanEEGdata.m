%% % Braintools UK project test-retest data: Clean EEG data

% This script cleans the EEG data (fieldtrip format).

% For each session folder:

% 1) Find the fieldtrip data 
% 2) Preprocess the data for the different conditions
% 3) Save the data in the session fieldtrip folder

% 4) Save the path to the clean data in the table
% 5) Save the number of clean trial per condition in the table

% Calls to functions from Fieldtrip, 
% and Task Engine and eeg-tools created by Luke Mason
% and other functions specific to this paradigm:
%   - BrTUK_01a_Preprocess_Allcond which calls to:
%       - BrTUK_trialfun_braintoolsUKtrt_FastERP
%       - BrTUK_01aa_NumberTrials_ERPs
%       - BrTUK_01ab_preproc_cleandata

% by Rianne Haartsen: jan-feb 21

%% Load the table with info

clear variables

% add common paths
% braintools and task engine scripts
    addpath(genpath('/XXXXX'));
% braintools UK specific analysis scripts    
    addpath('/XXXXX');
%add fieldtrip path and set to defaults
    addpath('XXXXX/fieldtrip-20180925'); 
    ft_defaults
    
    
%% Set up table to keep track of different thresholds

% % Variables: ID+session, EEGft_path, CleanData_path, 
% % Nfaceup, Nfaceinv, Nobjup, Nobjinv Ncheckers
% 
% % create a table with variable for tracking
%     Nrows = 84;
%     BrtUK_ClnEEG = table('Size',[Nrows 8], ...
%         'VariableNames',{'IDses','EEGft_path','CleanData_path','Nfaceup','Nfaceinv','Nobjup','Nobjinv','Ncheckers'},...
%         'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell', 'cell'});
% 
%     save('/XXXXX/BraintoolsUK_Cleandata_tracker.mat','BrtUK_ClnEEG');

    
%% Clean and preprocess all datasets

load '/XXXXX/BraintoolsUK_Cleandata_tracker.mat'
    
% Cleaning parameters:
    Tmin = -150; % minimum value for minmax threshold AR
    Tmax = 150; % maximum value for minmax threshold AR
    Trange = []; % range value for range threshold AR, or empty 
    BPfilter = [.1, 40]; % range for band pass filter
    Baseline_timewindow =  [-0.1, 0]; % time for baseline correction in sec, or empty

for ss = 69:height(BrtUK_ClnEEG)

    fprintf('Currently nr %i out of %i\n',ss,height(BrtUK_ClnEEG))
    Subj = BrtUK_ClnEEG.IDses{ss}; %ppt code
    disp(Subj)
    
    % 1) Find the fieldtrip data    
        FTdata = BrtUK_ClnEEG.EEGft_path{ss}{1,1}; % EEG data file 
        
    % 2) Preprocess the data for the different conditions
        % save parameters in structure for bookkeeping
        FastERP_info.Subj = Subj;
        FastERP_info.BPfilter = BPfilter;
        FastERP_info.AR_Thresholds = [Tmin, Tmax];
        FastERP_info.AR_Range = Trange; 
        FastERP_info.Baseline_timewindow = Baseline_timewindow;
        
        % function to clean the data
        [EEGdata_Faces_Obj, EEGdata_Checkers, FastERP_info] = BrTUK_01a_Preprocess_Allcond(FTdata, FastERP_info);
 
    % 3) Save the data in the session fieldtrip folder
        Session_path = extractBefore(FTdata,'fieldtrip');
        Cleandata_path = strcat(Session_path,'fieldtrip/', Subj, '_CleanData.mat');
        save(Cleandata_path, 'EEGdata_Faces_Obj','EEGdata_Checkers', 'FastERP_info')

    % 4) Add the path to the clean data into the table
        BrtUK_ClnEEG.CleanData_path{ss} = Cleandata_path;
  
    % 5) Add the number of clean trial per condition into the table
        BrtUK_ClnEEG.Nfaceup(ss) = {FastERP_info.N_trials.FaceUp.Nclean};
        BrtUK_ClnEEG.Nfaceinv(ss) = {FastERP_info.N_trials.FaceInv.Nclean};
        BrtUK_ClnEEG.Nobjup(ss) = {FastERP_info.N_trials.ObjUp.Nclean};
        BrtUK_ClnEEG.Nobjinv(ss) = {FastERP_info.N_trials.ObjInv.Nclean};
        BrtUK_ClnEEG.Ncheckers(ss) = {FastERP_info.N_trials.Checkers.Nclean}; 
        
        save('/XXXXX/BraintoolsUK_Cleandata_tracker.mat','BrtUK_ClnEEG');
        
        clear EEGdata_Faces_Obj EEGdata_Checkers FastERP_info 
        clear FTdata Cleandata_path Session_path Subj

end
