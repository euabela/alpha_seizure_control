function alpha_convert2images(data2convert, outdir)
%% Convert EEG data to SPM12 images
% PURPOSE:
% This script converts EEG data in SPM12 format to scalp x frequency
% images. 
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org

if nargin<1
    data2convert = spm_select(Inf,'enrm.*\.mat$','Select data to convert...');
    outdir       = spm_select(1,'dir','Select output directory...');
end

for filei = 1:size(data2convert,1)
    % Define condition name
    [~ , nam, ~] = spm_fileparts(data2convert(filei,:));

    % Define matlabbatch parameters
    matlabbatch{1}.spm.meeg.images.convert2images.D = {data2convert(filei,:)};
    matlabbatch{1}.spm.meeg.images.convert2images.mode = 'scalp x frequency';
    matlabbatch{1}.spm.meeg.images.convert2images.conditions = {nam};
    matlabbatch{1}.spm.meeg.images.convert2images.channels{1}.all = 'all';
    matlabbatch{1}.spm.meeg.images.convert2images.timewin = [-Inf Inf];
    matlabbatch{1}.spm.meeg.images.convert2images.freqwin = [-Inf Inf];
    matlabbatch{1}.spm.meeg.images.convert2images.prefix = 'test';
    matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.files(1) = cfg_dep('Convert2Images: M/EEG exported images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {outdir};

    % Run
    spm_jobman('run',matlabbatch');
end
%% END