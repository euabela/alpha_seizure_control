function [jaccardIndex, ci, p] = alpha_jaccard(im1, im2)
%% Calculate Jaccard similarity index between to images, and provide stats
%
% PURPOSE: 
% This script calculates the Jaccard similarity index (Jaccard index for
% short), i.e. the intersecton divided by the union of two sets, and uses
% bootstrapping to find its confidence interval and permutations to assess
% its significance. It works for images in Nifti format (.nii), e.g. EEG 
% topographies or brain images.
%
% INPUTS: 
% - im1, im2        Two binarised image files (nifti format)
%
% OUTPUTS:
% - jaccardIndex    
% - ci              95% confidence interval
% - p               Permutation-based p-value
%
% DEPENDECIES: 
% - Matlab statistics toolbox (for bootci.m)
%
% NOTES: 
% On theoretical grounds, the Jaccard distance (1-Jaccard index)
% might be preferrable, see Levandowsky, Winter, Nature 1971 (doi:
% 10.1038/234034a0). 
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org

%% Select images 
%==========================================================================

% Require input
%--------------------------------------------------------------------------
if nargin < 1
    im1 = spm_select(1,'image','Select first image...');
    im2 = spm_select(1,'image','Select second image...');
end

% Load data
%--------------------------------------------------------------------------
dat1 = spm_read_vols(spm_vol(im1));
dat2 = spm_read_vols(spm_vol(im2));
D = [dat1(:), dat2(:)];

%% Calculations
%==========================================================================

% Calculate index
%--------------------------------------------------------------------------
% Define a function handle, so it can be easily passed to the steps below.
jaccardFunction = @(D) sum(D(:,1) & D(:,2)) / sum(D(:,1) | D(:,2));
jaccardIndex = jaccardFunction(D);

% Calculate bootstraped 95% confidence intervals (CI)
%--------------------------------------------------------------------------
ci = bootci(5000,jaccardFunction,D);

% Calculate p-value using a permutation test
%--------------------------------------------------------------------------
% Permute second image over frequencies, recalculate jaccard index, do
% p-value count. This equals moving each space x space slice randomly
% between frequencies, keeping the whithin-slice topography intact.
nperms = 5000;
jaccardIndex_perm = size(1,nperms);

for ii = nperms
    order    = randperm(size(dat2,3));
    permdat2 = dat2(:,:,order);
    permD    = [dat1(:),permdat2(:)];
    jaccardIndex_perm(ii) = jaccardFunction(permD);
end

% How many times is the permuted Jaccard higher than the actual Jaccard? If
% not many, the actual Jaccard is unusual -> low p-value!
p = sum(jaccardIndex_perm>jaccardIndex)/nperms;

%--------------------------------------------------------------------------
%% End
