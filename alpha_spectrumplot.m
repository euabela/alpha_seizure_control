%% alpha_spectrumplot
% This script is used to generate Fig. 1
%
% PURPOSE: 
% This script prints subplots A-C of Fig. 1 on our forthcoming paper
% (CITATION HERE ONCE PUBLISHED).
%
% INPUTS: 
% - Power spectrum data files in Fieldtrip format.
%
% OUTPUTS:
% - Matlab figure with three subplots
%
% DEPENDECIES: 
% - Gramm by Pierre Morel (https://github.com/piermorel/gramm)
%
% NOTES: 
%
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org
%
%% Load data
%==========================================================================

% Define filenames
%--------------------------------------------------------------------------

% Healthy controls
con = spm_select(Inf,'^nrm_fteeg.*\.mat','Select controls...');

% Patients by syndromes
ige = spm_select(Inf,'^nrm_fteeg.*\.mat','Select IGE...');
foc = spm_select(Inf,'^nrm_fteeg.*\.mat','Select FE...');

% Patients by seizure control
gsz = spm_select(Inf,'^nrm_fteeg.*\.mat','Select GSC...');
psz = spm_select(Inf,'^nrm_fteeg.*\.mat','Select PSC...');

% Organise data structures
%--------------------------------------------------------------------------
% Note: this section of code basically repackages everything into three
% data structures. This simplifies passing data to gramm for plotting.

% Epilepsy data strucutre
epifiles = char(con,ige,foc);
epi = struct; 
epi.idx = [zeros(size(con,1),1); ones((size(ige,1)+size(foc,1)),1)];

for subi = 1:size(epifiles,1)
    load(deblank(epifiles(subi,:)));
    epi.nrm(subi,:) = mean(nrm.powspctrm,1);
    epi.freq        = nrm.freq;
end

% Syndrome data structure
synfiles = char(ige,foc);
syn = struct;
syn.idx = [zeros(size(ige,1),1);ones(size(foc,1),1)];

for subi = 1:size(synfiles,1)
    load(deblank(epifiles(subi,:)));
    syn.nrm(subi,:) = mean(nrm.powspctrm,1);
    syn.freq        = nrm.freq;
end

% Seizure data structure
szrfiles = char(gsz,psz);
szr = struct;
szr.idx = [ones(size(gsz,1),1); ones(size(psz,1),1)+1];

for subi = 1:size(szrfiles,1)
    load(deblank(synfiles(subi,:)));
    szr.nrm(subi,:) = mean(nrm.powspctrm,1);
    szr.freq        = nrm.freq;
end

%% Additional variables (Currently not used, kept for future reference)
%==========================================================================

% General
% x  = syn.freq; % x axis
% y  = syn.nrm;  % y axis
% id = syn.idx;  % color coding - according to groups

% Spectrum peaks...
% ... for controls
% pwrCon     = syn.nrm(syn.idx == 0,:);
% [~,c]      = find(mean(pwrCon(:,5:14)) == max(mean(pwrCon(:,5:14))));
% maxfreqCon = syn.freq(4+c);
% 
% % ... for IGE
% pwrIGE     = syn.nrm(syn.idx == 1,:);
% [~,c]      = find(mean(pwrIGE(:,5:14)) == max(mean(pwrIGE(:,5:14))));
% maxfreqIGE = syn.freq(4+c);
% 
% % ... for focal
% pwrFOC     = syn.nrm(syn.idx == 2,:);
% [~,c]      = find(mean(pwrFOC(:,5:14)) == max(mean(pwrFOC(:,5:14))));
% maxfreqFOC = syn.freq(4+c);

%% Plots
%==========================================================================

% Define figure 
%--------------------------------------------------------------------------
close all;
f = figure('Units', 'centimeters','Position',[15 15 15 5]);

% Define colormap
%--------------------------------------------------------------------------
cmap = brewermap(3,'Set1');

% First subplot
%--------------------------------------------------------------------------
g(1,1) = gramm('x',epi.freq,'y',epi.nrm,'color',epi.idx);
g(1,1).stat_summary('type','bootci','geom',{'area'},'setylim','true');
g(1,1).set_stat_options('nboot',5000);
g(1,1).set_color_options('map',cmap);
g(1,1).set_order_options('color',[2 1]);
g(1,1).set_line_options('base_size',2,'styles',{'-','-.',':'});
g(1,1).axe_property('TickDir','out','LineWidth',1,...
    'YLim',[0.005 0.20],'YTick',[0.01,0.2],'YTickLabel',...
    {'0.01','0.22'},...
    'XLim',[1.5 20],'XTick',[2,6,7,8,11,17,20],'XTickLabel',...
    {'2','6',[],'8','11','17','20'},...
    'TickLength',[0.01 0.025]);
g(1,1).set_layout_options('margin_height',[0.2 0.1],'margin_width',...
    [0.2 0.05],'redraw',false);
g(1,1).set_text_options('base_size',12,'font','Arial');
g(1,1).no_legend();

% Second subplot
%--------------------------------------------------------------------------
g(1,2) = gramm('x',szr.freq,'y',szr.nrm,'color',szr.idx);
g(1,2).stat_summary('type','bootci','geom',{'area'},'setylim','true');
g(1,2).set_stat_options('nboot',5000);
g(1,2).set_color_options('map',cmap);
g(1,2).set_order_options('color',[2 1]);
g(1,2).set_line_options('base_size',2,'styles',{'-','-.',':'});
g(1,2).axe_property('TickDir','out','LineWidth',1,...
    'YLim',[0.005 0.20],'YTick',[0.01,0.2],'YTickLabel',...
    {'0.01','0.22'},...
    'XLim',[1.5 20],'XTick',[2,7,8,10,11,20],'XTickLabel',...
    {'2','7','8',[],'11','20'},...
    'TickLength',[0.01 0.025]);
g(1,2).set_layout_options('margin_height',[0.2 0.1],'margin_width',...
    [0.05 0.1],'redraw',false);
g(1,2).set_text_options('base_size',12,'font','Arial');
g(1,2).no_legend();

% Third subplot
%--------------------------------------------------------------------------
g(1,3) = gramm('x',syn.freq,'y',syn.nrm,'color',syn.idx);
g(1,3).stat_summary('type','bootci','geom',{'area'},'setylim','true');
g(1,3).set_stat_options('nboot',5000);
g(1,3).set_color_options('map',cmap);
g(1,3).set_order_options('color',[2 1]);
g(1,3).set_line_options('base_size',2,'styles',{'-','-.',':'});
g(1,3).axe_property('TickDir','out','LineWidth',1,...
    'YLim',[0.005 0.20],'YTick',[0.01,0.2],'YTickLabel',...
    {'0.01','0.22'},...
    'XLim',[1.5 20],'XTick',[2,10,20],'XTickLabel',...
    {'2','10','20'},...
    'TickLength',[0.01 0.025]);
g(1,3).set_layout_options('margin_height',[0.2 0.1],'margin_width',...
    [0.05 0.1],'redraw',false);
g(1,3).set_text_options('base_size',12,'font','Arial');
g(1,3).no_legend();

% Now draw
%--------------------------------------------------------------------------
draw(g); 

% Customise axes
%--------------------------------------------------------------------------
for ii = 1:3
    ax = g(1,ii).facet_axes_handles;
    alpha_offsetAxes(ax,100);
    if ii ==1
        xlabel(ax,'Frequency (Hz)','Position',[11 -0.03 -1],...
        'FontSize',12,'FontName','Arial');
        ylabel(ax,'Power (norm.)','Position',[0.1, 0.11 -1],...
        'FontSize',12,'FontName','Arial');
    else
        xlabel(ax,''); 
        set(ax,'YLabel',[],'YTickLabel',{});
    end
end
%--------------------------------------------------------------------------
%% END
