%% alpha_toposhift
%% Preliminaries
%--------------------------------------------------------------------------
% Select data
%--------------------------------------------------------------------------
files = spm_select(Inf,'^nrm.*\.mat$','Select power files...');
nsub = size(files,1);
nchan = 19;

% Preallocate results structure
%--------------------------------------------------------------------------
topo          = struct;
topo.date     = date;
topo.filename = cell(nsub,1);
topo.lopwr    = zeros(nsub,nchan);
topo.hipwr    = zeros(nsub,nchan);
topo.shift    = zeros(nsub,nchan);
% alpha.mxpwr    = zeros(size(pwrnorm,1),1);
% topo.iaf      = zeros(nsub,nchan);

%% Loop over subjects
%--------------------------------------------------------------------------

for subi = 1:nsub
   
    % Load data
    %----------------------------------------------------------------------
    load(deblank(files(subi,:)));
    pwr = nrm.powspctrm;
    freq = nrm.freq;
    
    % Remember the filename
    %----------------------------------------------------------------------
    [~,nam,~] = spm_fileparts(files(subi,:));
    topo.filename{subi,1} = nam;
    
    % No loop over channels
    %----------------------------------------------------------------------
    for chani = 1:nchan
          
        % Find low alpha power  
        %------------------------------------------------------------------
        loalphaRange = dsearchn(freq',(6:.1:9)');
        topo.lopwr(subi,chani) = mean(pwr(chani,loalphaRange));

        % Find high alpha power  
        %------------------------------------------------------------------
        hialphaRange = dsearchn(freq',(10:.1:11)');
        topo.hipwr(subi,chani) = mean(pwr(chani,hialphaRange) );

        % Calculate alpha-power shift
        %------------------------------------------------------------------
        topo.shift(subi,chani) = topo.lopwr(subi,chani)./topo.hipwr(subi,chani);

        % IAF (currently unused)
        %------------------------------------------------------------------
%         fullalphaRange = dsearchn(freq',(6:.1:13)');
%         maxPwr = max(pwr(:,fullalphaRange));
%         topo.iaf(subi,1) = freq(dsearchn(avgPwr',maxPwr));
    end
end