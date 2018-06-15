%% alpha_topoeffect
%
% PURPOSE: 
% This script is used to generate maps of voxel-wise effect sizes for
% pair-wise comparisons, based on EEG power images.
%
% INPUTS: 
% - direc 1/2       Directories where the images of the first group are
%                   stored. Select the "healthier" group first.
%
% OUTPUTS:
% - EEG effect size maps
%
% DEPENDECIES: 
% - MES (https://github.com/hhentschke/measures-of-effect-size-toolbox)
% - SPM12 (http://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
%
% NOTES: 
% This script calculates two effect size measures, Hedges' g, which assumes
% approximately normally distributed data, and Cohen's U3, which is a
% non-parametric alternative. We report g in the paper because it's easier
% to understand (it's closely related to the popular Cohen's d). Cohen's U3
% has a slightly complicated interpretation: it represents the overlap
% between distributions, and can be understood as the number of scores in
% the diseased group above or below the median of a reference
% group. U3 ranges from 0 to 1, where 0.5 = no effect, 1 maximal effect of
% diseased group. It is non-symmetrical, so the order of input (line 72)
% matters. See the excellent MES documentation for details.
% 
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org

%% Select and load data
%==========================================================================
% File directories
%--------------------------------------------------------------------------
direc1 = spm_select(1,'dir');
direc2 = spm_select(1,'dir');

% Find files
%--------------------------------------------------------------------------
FILES1 = spm_select('FPListRec',direc1,'^shift'); % HS, GSZ, IGE
FILES2 = spm_select('FPListRec',direc2,'^shift'); % PAT, PSZ, FE
nsub1 = size(FILES1,1);
nsub2 = size(FILES2,1);
           
% Find file dimensions
%--------------------------------------------------------------------------
tmp = spm_vol(FILES1(1,:)); % dummy header
x = tmp.dim(1);
y = tmp.dim(2);
z = tmp.dim(3);

% Load
%--------------------------------------------------------------------------
DATA1 = zeros(nsub1,x,y,z);
DATA2 = zeros(nsub2,x,y,z);

for subi = 1:nsub1
    DATA1(subi,:,:,:) = spm_read_vols(spm_vol(FILES1(subi,:)));
end

for subi = 1:nsub2
    DATA2(subi,:,:,:) = spm_read_vols(spm_vol(FILES2(subi,:)));
end

%% Caclulate effect sizes for each voxel
%==========================================================================
% Preallocate matrices
%--------------------------------------------------------------------------

MAPg = zeros(32,32,1);
MAPu = MAPg;

for xi = 1:x
    for yi = 1:y
        for zi = 1:z
            stats = mes(DATA2(:,xi,yi,zi),DATA1(:,xi,yi,zi),{'hedgesg'});
            MAPg(xi,yi,zi) = stats.hedgesg;
            stats = mes(DATA1(:,xi,yi,zi),DATA2(:,xi,yi,zi),{'U3'});
            MAPu(xi,yi,zi) = stats.U3;
        end
    end
end

%% Save as images
%==========================================================================
% File for Hedges'g
%--------------------------------------------------------------------------
outg = tmp;
outg.fname = 'X_GMAP.nii';
spm_write_vol(outg,MAPg);

% File for Cohen's U3
%--------------------------------------------------------------------------
outu = outg;
outu.fname = 'X_UMAP.nii';
spm_write_vol(outu,MAPu);

%% Communicate success
disp('--- DONE ---');

%==========================================================================
%%END
