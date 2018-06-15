%% alpha_toposhift_image

%% Load images
%=========================================================================
dataDir  = spm_select(1,'dir','Select data directory...');
imgFiles = spm_select('FPListRec',dataDir,'^condition.*\.nii$');
outNam = 'shift';

%% Loop over files
%=========================================================================
% Start SPM
%-------------------------------------------------------------------------
spm('defaults','eeg');

% Initialise SPM job manager
%-------------------------------------------------------------------------
spm_jobman('initcfg');

% Initialise waitbar
%-------------------------------------------------------------------------
h = waitbar(0,'Please wait...');

% Loop
%-------------------------------------------------------------------------
for imgi = 1:size(imgFiles,1)
    [pth ,nam, ext] = spm_fileparts(imgFiles(imgi,:));
    outNam = ['shift_' nam ext];
    matlabbatch = [];
    matlabbatch{1}.spm.meeg.images.collapse.images = {imgFiles(imgi,:)};
    matlabbatch{1}.spm.meeg.images.collapse.timewin = [6 9];
    matlabbatch{1}.spm.meeg.images.collapse.prefix = 'loAlpha_';
    matlabbatch{2}.spm.meeg.images.collapse.images = {imgFiles(imgi,:)};
    matlabbatch{2}.spm.meeg.images.collapse.timewin = [10 11];
    matlabbatch{2}.spm.meeg.images.collapse.prefix = 'hiAlpha_';
    matlabbatch{3}.spm.util.imcalc.input(1) = cfg_dep('Collapse time: Collapsed M/EEG images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{3}.spm.util.imcalc.input(2) = cfg_dep('Collapse time: Collapsed M/EEG images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{3}.spm.util.imcalc.output = outNam;
    matlabbatch{3}.spm.util.imcalc.outdir = {pth};
    matlabbatch{3}.spm.util.imcalc.expression = 'log(i1./i2)';
    matlabbatch{3}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{3}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{3}.spm.util.imcalc.options.mask = 0;
    matlabbatch{3}.spm.util.imcalc.options.interp = 1;
    matlabbatch{3}.spm.util.imcalc.options.dtype = 16;
    spm_jobman('run',matlabbatch);
    waitbar(imgi/size(imgFiles,1));
end

%  Close waitbar
%-------------------------------------------------------------------------
close(h);

%=========================================================================
%End
