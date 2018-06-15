function alpha_convert2spm
% Converts Fieldtrip structures to SPM MEEG object and scalp x frequency
% images
%
% PURPOSE: 
% This script contains routines to transform FT data to SPM12 scalp x freq
% images.
%
% INPUTS: 
%  - None, run  as is
% 
% OUTPUTS:
% - EEG scalp x frequency-images
%
% DEPENDECIES: 
% - Fieldtrip (http://www.fieldtriptoolbox.org/start)
% - SPM12 (http://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
%
% NOTES:
% Pro memoria: need to epoch before image conversion.
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org

%% Define files
%==========================================================================
data2convert = spm_select(Inf,'^nrm'); % Your preferred prefix here

%% Loop over files
%==========================================================================
for ii = 1:size(data2convert,1)
    
    % Load
    %----------------------------------------------------------------------
    load(data2convert(ii,:));
    
    % Get fileparts
    %----------------------------------------------------------------------
    [pth, nam, ext] = spm_fileparts(data2convert(ii,:));
    outname = [pth filesep 'spm_' nam ext];
   
    % Convert to SPM MEEG object
    %----------------------------------------------------------------------
    D = spm_eeg_ft2spm(nrm,outname);
    
    % Assign default eeg sensor positions
    %----------------------------------------------------------------------
    S           = [];
    S.D         = D;
    S.task      = 'defaulteegsens';
    D           = spm_eeg_prep(S);
    save(D);
    
    % Epoch
    %----------------------------------------------------------------------
    S                  = [];
    S.D                = D;
    S.bc               = 0;
    S.trialength       = 1000;  % in ms.
    S.conditionlabels  = 'rest';
   
    De = spm_eeg_epochs(S);
    
    % Average
    %----------------------------------------------------------------------
    
    S                 = [];
    S.D               = De;
    S.prefix          = 'a';
    S.robust          = 1;
    
    Dea = spm_eeg_average(S);
    
    % Convert to scalp x frequency image
    %----------------------------------------------------------------------
   
    S       = [];
    S.D     = Dea;
    S.mode  = 'scalp x frequency';
    
    spm_eeg_convert2images(S); 

end
%% End
