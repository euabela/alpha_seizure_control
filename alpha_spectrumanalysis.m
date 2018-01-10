function alpha_spectrumanalysis(files,foi,smth)
%% Spectrum analysis of continous EEG time-series 
%
% PURPOSE: 
% This script is contains routines to compute power spectra of continous
% EEG time-series and transform them to scalp x requency-images to perform
% stastics on.
%
% INPUTS: 
% - files           File list of data to  analyse
% - foi        	    Frequencies of interest
% - smth            Optional: smoothing kernel for scalp x freq. images,
%                   the dimesion is [mm mm Hz], e.g. [6 6 1]
%
% OUTPUTS:
% - EEG scalp x frequency-images
%
% DEPENDECIES: 
% - Fieldtrip (http://www.fieldtriptoolbox.org/start)
% - SPM12 (http://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
%
% NOTES:
% Smoothing is beneficial to accommodate intersubject differences in
% functional anatomy / dynamics and to render the data more Gaussian, if
% one wants to use Random Field Theory. However, the dimensions of the
% smoothing kernel depend on the expected size of the effect
% (matched-filter theorm), which cannot be known a priori. Litvak et al
% recommend to try smoothing with different kernels
% (doi:10.1155/2011/852961), but we are rather averse to too many
% researchers degrees of freedom. Also, because we use permutation
% statistics, smoothing is not strictly necessary (although it might help
% increasing  SNR).
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org

%% Select files to analyse
%==========================================================================
% If using the function without arguments, specify file name patterns,
% frequencies and smoothing kernel here

if nargin<1
    files = spm_select(Inf,'^fteeg.*\.mat$');
    foi   = 2:1:20;
    smth  = [0 0 0];
end

%% Fire up SPM12
%==========================================================================
% This is needed for the matlabbatch at the end of the loop below.

spm('defaults','eeg');
spm_jobman('initcfg');


%% Loop over files
%==========================================================================

for filei = 1:size(files,1);
    
    % Load data
    %----------------------------------------------------------------------
    load(files(filei,:));

    % Cut continous EEG in 2 second epochs with 90% overlap
    %----------------------------------------------------------------------
    cfg = [];
    cfg.length  = 2;
    cfg.overlap = 0.9;
    
    seg = ft_redefinetrial(cfg, eeg);
    
    % Hanning-tapered FFT
    %----------------------------------------------------------------------
    cfg = [];
    cfg.method     = 'mtmfft';
    cfg.taper      = 'hanning';
    cfg.foi        = foi;
    cfg.polyremoval= 0;
    cfg.keeptrials = 'no';

    pwr = ft_freqanalysis(cfg, seg);
    
    % Normalise against total power
    %----------------------------------------------------------------------
    nrm      = pwr;
    channum  = numel(nrm.label);
    
    for chani = 1:channum
        totalpwr = sum(pwr.powspctrm(chani,:));
        nrm.powspctrm(chani,:) = pwr.powspctrm(chani,:)./totalpwr;
    end
    
    % Save FT data
    %----------------------------------------------------------------------
    [pth,nam,ext] = fileparts(files(filei,:));
    save([pth filesep 'pwr_' nam ext],'pwr');
    save([pth filesep 'nrm_' nam ext],'nrm'); 
    
    % Convert to SPM12
    %----------------------------------------------------------------------
    % NOTE: this contains a horrible hack - we repmat the powerspectrum,
    % else SPM will not epoch, and if we don't epoch, it will convert to
    % images later on! 
    
    nrm.dimord    = 'chan_freq_time';
    nrm.powspctrm = repmat(nrm.powspctrm,1,1,2); % SPM expects epochs
    nrm.time      = 1:2;
    
       
    outname = [pth filesep 'nrm_spmeeg_' nam(7:end) ext];
    D = spm_eeg_ft2spm(nrm, outname);
    D = chantype(D, ':', 'EEG');


    % Assign default channel locations and save
    %----------------------------------------------------------------------
    S              = [];
    S.D            = D;
    S.task         = 'defaulteegsens';
    D              = spm_eeg_prep(S);
    save(D);
    
    % Epoch
    %---------------------------------------------------------------------- 
    S                  = [];
    S.D                = D;
    S.bc               = 0;
    S.trialength       = 1000;  % in ms.
    S.conditionlabels  = 'rest';
    
    D = spm_eeg_epochs(S);
    
    % Convert to scalp x frequency images
    %----------------------------------------------------------------------
    S       = [];
    S.D     = D;
    S.mode  = 'scalp x frequency';
    
    img = spm_eeg_convert2images(S);   
    
    % Smooth to accommodate interindividual differences
    %----------------------------------------------------------------------
    % We use a kernel of 6 x 6 mm in space, 1 Hz in frequency. Smoothing is
    % done to accommodate interindividal spatio-spectral differences. We
    % use the matlabbatch structure because it allows for implicit masking
    % (.smooth.im); this avoids "overspilling" of signal outside the image
    % borders.
    if sum(smth) > 0
        matlabbatch = [];
        matlabbatch{1}.spm.spatial.smooth.data   = cellstr(img{1,1});
        matlabbatch{1}.spm.spatial.smooth.fwhm   = smth;
        matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
        matlabbatch{1}.spm.spatial.smooth.im     = 1;
        matlabbatch{1}.spm.spatial.smooth.prefix = 'sm';
        spm_jobman('run', matlabbatch);
    else
        continue
    end
end
%% END
