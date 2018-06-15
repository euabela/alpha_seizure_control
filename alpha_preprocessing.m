function eeg = alpha_preprocessing(datafiles,labelfile,outdir)
%% Preprocessing of EEG data 
%
% PURPOSE: 
% This script is contains routines to preprocess EEG data (in EDF). 
%
% INPUTS: 
% - data2prepro     File list of data to preprocess (subjects x characters)
% - labelfile        File (.mat) containing a cell of channel label strings
%                   (in one column, i.e. channels x 1) 
% - outputdir       Output directory
%
% OUTPUTS:
% - EEG data in Fieldtrip and SPM12 format with default channel positions.
%
% DEPENDECIES: 
% - Fieldtrip (http://www.fieldtriptoolbox.org/start)
% - SPM12 (http://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
%
% NOTES: 
% You might need to adapt line 50 (removal of auricular, ECG and
% annotation channels). Check whether this fits the channel names in your
% data (and whether this step it is necessary at all).
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org


%% Data selection
%==========================================================================

if nargin<1

    % Select data
    %----------------------------------------------------------------------
    datafiles = spm_select(Inf,'.edf$','Select data to preprocess...');
    
    % Select  file containing channel labels
    %----------------------------------------------------------------------
    labelfile = spm_select(Inf,'mat','Select channel label file...');
    
    % Select output directory
    %----------------------------------------------------------------------
    outdir    = spm_select(1,'dir','Select output directory...');
    
end

%% Preprocessing loop
%==========================================================================

% Load labels
%--------------------------------------------------------------------------
load(labelfile);

for filenum = 1:size(datafiles,1);
    
    % Load data
    %----------------------------------------------------------------------

    cfg             = [];
    cfg.dataset     = deblank(datafiles(filenum,:));
    cfg.continuous  = 'yes';
    
    % Remove all posible inconsistent channels found in our data set (this
    % list was compiled by us manually).
    %----------------------------------------------------------------------
    
    cfg.channel     = {'all','-EEG A*','-EEG S*',...
       '-EEG Oz-REF','-EEG Fpz-*','-EEG 23-24','-EEG 23-25',...
       '-EEG 24-26','-EEG 31-REF','-EEG 32-REF','-EEG Pg1-REF',...
       '-C2*','-C3*','-C4*','-C5*','-C6*','-C7*','-C8*','-C9*','-C10*',...
       '-C11*','-C12*','-ECG*','-EMG*','-EOG*',...
       '-EDF Annotations','-Resp Abdomen-REF','-Airflow-REF',...
       '-Photic-REF','-Status','-Event'}; 
   
    % Detrend and re-reference to average.
    %----------------------------------------------------------------------
    
    cfg.detrend     = 'yes';
    cfg.reref       = 'yes';
    cfg.refchannel  = 'all';
    cfg.refmethod   = 'avg';
    eeg             = ft_preprocessing(cfg);

    % Relabel channels
    %----------------------------------------------------------------------
    
    eeg.label       = labels;
    eeg.cfg.channel = labels;
    
    % Rename and save
    %----------------------------------------------------------------------
    
    [~, nam, ~] = spm_fileparts(datafiles(filenum,:));
    
    % ... as Fieldtrip data structure
    outname     = [outdir '/fteeg_' nam '.mat'];
    save(outname,'eeg');
    
    % ... as SPM12 MEEG object
    D = spm_eeg_ft2spm(eeg, outname);
    save(D);
    
end
%% End
