%% Plot
S.D      = spm_select(1,'eeg.*\.mat$');  % Select EEG file for sensor information
S.image  = spm_select(1,'image');        % Select EEG image for data values
S.window = [1 1];                        % Looking at averages: have no time dimension
S.clim   = [1.3 4];                      % -log10 p-values
spm_eeg_img2maps(S);                     % Select option FT

%% Edit
f = gcf;
f.Children(2).XLim       = [1.31 4];
f.Children(2).Ticks      = [1.31 4];
f.Children(2).FontName   = 'Arial';
f.Children(2).TickLabels(1) = {'.05'};
f.Children(2).TickLabels(2) = {'.0001'};
f.Children(2).FontSize   = 30;
f.Children(2).Position(4)= 0.05;
f.Children(2).FontSize   = 40;

%% Save
export_fig IGEPSC.png -r300 -png
