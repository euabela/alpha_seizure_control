% alpha_spectrumplot
%
% DEPENDENCIES:
% - alpha_offsetAxes (see this repository)
% - brewermap (https://github.com/DrosteEffect/BrewerMap)
% - gramm (https://github.com/piermorel/gramm)
% - export_fig (https://github.com/altmany/export_fig)
%

%% 1-Load data
%==========================================================================
clearvars;
load('2018-03-07_alpha_spectrumplot.mat');

%% 2-Plots
%==========================================================================

% 2.1-Set up figure 
%--------------------------------------------------------------------------
close all;
f = figure('Units', 'centimeters','Position',[20 50 15 8]);
font = 11;
% 2.2-Define colormap
%--------------------------------------------------------------------------
if ~exist('cmap','var')
    cmap = brewermap(3,'Set1');
end

% 2.3-Set up data, axes, and positions
%--------------------------------------------------------------------------

% Panel A
g(1,1) = gramm('x',epi.freq,'y',epi.nrm,'color',epi.idx);
g(1,1).axe_property('TickDir','out','LineWidth',.5,...
    'YLim',[0 0.20],'YTick',[0.01,0.2],'YTickLabel',{'0.01','0.20'},...
    'XLim',[1 20],'XTick',[2,6,7,8,11,20],...
    'XTickLabel', {'2','6','7','8','11','20'},...
    'TickLength',[0.025 0.025]);
g(1,1).set_layout_options('margin_height',[0.45 0.1],'margin_width',...
    [0.20 0.00],'redraw',false);

% Panel B
g(1,2) = gramm('x',szr.freq,'y',szr.nrm,'color',szr.idx);
g(1,2).axe_property('TickDir','out','LineWidth',.5,...
    'YLim',[0 0.20],'YTick',[0.01,0.2],'YTickLabel',{},...
    'XLim',[1 20],'XTick',[2,7,8,11,20],...
    'XTickLabel', {'2','7','8','11','20'},...
    'XLabel',[],'TickLength',[0.025 0.025]);
g(1,2).set_layout_options('margin_height',[0.45 0.1],'margin_width',...
    [0.15 0.05],'redraw',false);

% Panel C
g(1,3) = gramm('x',syn.freq,'y',syn.nrm,'color',syn.idx);
g(1,3).axe_property('TickDir','out','LineWidth',.5,...
    'YLim',[0 0.20],'YTick',[0.01,0.2],'YTickLabel',{},...
    'XLim',[1 20],'XTick',[2,7,10,11,20],...
    'XTickLabel', {'2','7','10  ','  11','20'},...
    'XLabel',[],'TickLength',[0.025 0.025]);
g(1,3).set_layout_options('margin_height',[0.45 0.1],'margin_width',...
    [0.10 0.1],'redraw',false);

% 2.4-Set common options for all subplots
%--------------------------------------------------------------------------
for ii = 1:3
    g(1,ii).stat_summary('type','bootci','geom',{'area'},'setylim','true');
    g(1,ii).set_stat_options('nboot',5000);
    g(1,ii).set_color_options('map',cmap);
    g(1,ii).set_order_options('color',[2 1]);
    g(1,ii).set_line_options('base_size',1,'styles',{'-','-.',':'});
    g(1,ii).set_text_options('base_size',8.5,'font','Arial');
    g(1,ii).no_legend();
    if ii == 1
      g(1,ii).set_names('x','Frequency (Hz)','y',...
          ['Power' char(10) '(normalised)']);
    else
      g(1,ii).set_names('y',[]);
    end
end

% 2.5-Draw and customise axes
%--------------------------------------------------------------------------
g.draw();

for ii = 1:3
    ax = g(1,ii).facet_axes_handles;
    alpha_offsetAxes(ax,50);
    if ii == 1
        ax.YLabel.Position = [0.2 0.105 -1]; % Move y-label closer to axis
%       ax.XLabel.Position = [18 -0.03 -1];  % Move x-label out of the way
        ax.XLabel.HorizontalAlignment = 'center';
    end
end

% 2.6-Mark non-overlapping frequencies
% --------------------------------------------------------------------------

% Panel A
ax11 = g(1,1).facet_axes_handles;
line(ax11,[6 8],[0 0],'Color','k','LineWidth',2);
line(ax11,[10.9 11.1],[0 0],'Color','k','LineWidth',2);

% Panel B
ax12 = g(1,2).facet_axes_handles;
line(ax12,[7 8],[0 0],'Color','k','LineWidth',2);
line(ax12,[10.9 11.1],[0 0],'Color','k','LineWidth',2);

% Panel C
ax13 = g(1,3).facet_axes_handles;
line(ax13,[6.9 7.1],[0 0],'Color','k','LineWidth',2);
line(ax13,[10 11],[0 0],'Color','k','LineWidth',2);
  

% Annotations Panel A
text(ax11,0,.23,'A','FontSize',font,'FontWeight','Bold');
text(ax11,4,.135,'Patients','FontSize',font*.7);
text(ax11,11,.155,['Healthy' char(10) 'controls'],'FontSize',font*.7);

% text(ax11,14.5,.04,['Group spectra' char(10) '[\mu\pm95%CI]'],'FontSize',font*.5);
% text(ax11,2,.015,['Peak \alpha-freq.' char(10) '[mdn\pmIQR]'],'FontSize',font*.5,...
%     'HorizontalAlignment','left');

% Annotations Panel B
text(ax12,0,.23,'B','FontSize',font,'FontWeight','Bold');
text(ax12,5.5,.155,['Poor' char(10) 'sz. control'],'FontSize',font*.7,...
    'HorizontalAlignment','center');
text(ax12,13.5,.17,['Good' char(10) 'sz. control'],'FontSize',font*.7,...
    'HorizontalAlignment','center');

% Annotations Panel C
text(ax13,0,.23,'C','FontSize',font,'FontWeight','Bold');
text(ax13,5.5,.15,['Focal' char(10) 'epilepsy'],'FontSize',font*.7,...
    'HorizontalAlignment','center');
text(ax13,16.2,.17,['Idiopathic' char(10) 'generalised epilepsy'],...
    'FontSize',font*.7,'HorizontalAlignment','center');


% 2.7-Show and save (optional)
%--------------------------------------------------------------------------
f.Visible = 'on';

% Uncomment this if you want to save, reimport and visualise % figure.
% export_fig alpha_spectra_v3.png -png -r300
% [I,map] = imread('alpha_spectra_v3.png','png');
% figure; imshow(I,map);


%% End

%% Zombie code (not dead, yet not alive either)
% if strcmp(iaf,'mdn') == 1;
%    
%   % Healthy subjects
%     line(ax11,[prctile(epi.confreq,25) prctile(epi.confreq,75)],[0.02 0.02],...
%         'Color',cmap(2,:),'LineWidth',1.5);
%     plot(ax11,median(epi.confreq),0.02,'o','MarkerFaceColor',cmap(2,:),...
%         'MarkerEdgeColor','w','MarkerSize',5)
% 
%     % Epilepsy patients
%     line(ax11,[prctile(epi.patfreq,25) prctile(epi.patfreq,75)],[0.01 0.01],...
%         'Color',cmap(1,:),'LineWidth',1.5);
%     plot(ax11,median(epi.patfreq),0.01,'o','MarkerFaceColor',cmap(1,:),...
%         'MarkerEdgeColor','w','MarkerSize',5)
%  
% 
%     % GSC
%     line(ax12,[prctile(szr.gszfreq,25) prctile(szr.gszfreq,75)],[0.02 0.02],...
%         'Color',cmap(2,:),'LineWidth',1.5);
%     plot(ax12,median(szr.gszfreq),0.02,'o','MarkerFaceColor',cmap(2,:),...
%         'MarkerEdgeColor','w','MarkerSize',5)
%     
%     % PSC
%     line(ax12,[prctile(szr.pszfreq,25) prctile(szr.pszfreq,75)],[0.01 0.01],...
%         'Color',cmap(1,:),'LineWidth',1.5);
%     plot(ax12,median(szr.pszfreq),0.01,'o','MarkerFaceColor',cmap(1,:),...
%         'MarkerEdgeColor','w','MarkerSize',5)
%     
%     
%     % IGE
%     line(ax13,[prctile(syn.igefreq,25) prctile(syn.igefreq,75)],[0.02 0.02],...
%         'Color',cmap(2,:),'LineWidth',1.5);
%     plot(ax13,median(syn.igefreq),0.02,'o','MarkerFaceColor',cmap(2,:),...
%         'MarkerEdgeColor','w','MarkerSize',5)
%     
%     % FE
%     line(ax13,[prctile(syn.focfreq,25) prctile(syn.focfreq,75)],[0.01 0.01],...
%         'Color',cmap(1,:),'LineWidth',1.5);
%     plot(ax13,median(syn.focfreq),0.01,'o','MarkerFaceColor',cmap(1,:),...
%         'MarkerEdgeColor','w','MarkerSize',5)
%     
% elseif strcmp(iaf,'dots') == 1;
%     
%     % Parameters
%     alpha = 0.3;
%     scale = 6;
%     jitter = 0.2;
%     font  = 11;
% 
%     % Panel A
%     ax11 = g(1,1).facet_axes_handles;
%     % Healthy subjects
%     y = ones(1,length(epi.confreq))/60;
%     s = ones(1,length(epi.confreq))*scale;
%     scatter(ax11,epi.confreq,y,s,'o','MarkerFaceColor',cmap(2,:),...
%         'MarkerEdgeColor',cmap(2,:),...
%         'MarkerEdgeAlpha',0,'MarkerFaceAlpha',alpha,...
%         'jitter','on','jitterAmount',jitter);
% 
%     % Epilepsy patients
%     y = ones(1,length(epi.patfreq))/100;
%     s = ones(1,length(epi.patfreq))*scale;
%     scatter(ax11,epi.patfreq,y,s,'o','MarkerFaceColor',cmap(1,:),...
%         'MarkerEdgeColor',cmap(1,:),...
%         'MarkerEdgeAlpha',0,'MarkerFaceAlpha',alpha,...
%         'jitter','on','jitterAmount',jitter);
% 
%  
%     % Panel B
%     ax12 = g(1,2).facet_axes_handles;
%     % GSC patients
%     y = ones(1,length(szr.gszfreq))/60;
%     s = ones(1,length(szr.gszfreq))*scale;
%     scatter(ax12,szr.gszfreq,y,s,'o','MarkerFaceColor',cmap(2,:),...
%         'MarkerEdgeColor',cmap(2,:),...
%         'MarkerEdgeAlpha',0,'MarkerFaceAlpha',alpha,...
%         'jitter','on','jitterAmount',jitter);
% 
%     % PSC patients
%     y = ones(1,length(szr.pszfreq))/100;
%     s = ones(1,length(szr.pszfreq))*scale;
%     scatter(ax12,szr.pszfreq,y,s,'o','MarkerFaceColor',cmap(1,:),...
%         'MarkerEdgeColor',cmap(1,:),...
%         'MarkerEdgeAlpha',0,'MarkerFaceAlpha',alpha,...
%         'jitter','on','jitterAmount',jitter);
% 
%  
%     % Panel C
%     ax13 = g(1,3).facet_axes_handles;
%     % IGE patients
%     y = ones(1,length(syn.igefreq))/60;
%     s = ones(1,length(syn.igefreq))*scale;
%     scatter(ax13,syn.igefreq,y,s,'o','MarkerFaceColor',cmap(2,:),...
%         'MarkerEdgeColor',cmap(2,:),...
%         'MarkerEdgeAlpha',0,'MarkerFaceAlpha',alpha,...
%         'jitter','on','jitterAmount',jitter);
% 
%     % Focal patients
%     y = ones(1,length(syn.focfreq))/100;
%     s = ones(1,length(syn.focfreq))*scale;
%     scatter(ax13,syn.focfreq,y,s,'o','MarkerFaceColor',cmap(1,:),...
%         'MarkerEdgeColor',cmap(1,:),...
%         'MarkerEdgeAlpha',0,'MarkerFaceAlpha',alpha,...
%         'jitter','on','jitterAmount',jitter);   
% end