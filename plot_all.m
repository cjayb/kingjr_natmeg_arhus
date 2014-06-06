function plot_all(data,cfg)
% default parameters
if ~exist('cfg','var'), cfg = []; end
if ~isfield(cfg,'plot'),    cfg.plot    = {'img_time', 'topo'}; end
if ~isfield(cfg,'trial'),   cfg.trial   = 1:length(data.trial); end
if ~isfield(cfg,'toi'),     cfg.toi     = -.050:.050:.300;      end % time region of interest
if ~isfield(cfg,'save'),    cfg.save    = false;                end % output image
if ~isfield(cfg,'figure_name'),cfg.figure_name = 'default';     end % output image name
if ~isfield(cfg,'zlim_grad'),cfg.zlim_grad= [0 1]*5e-12;       end % output image
if ~isfield(cfg,'zlim_mag'), cfg.zlim_mag= [-2.5 2.5]*1e-13;        end % output image
if ~isfield(cfg,'tlim_timeXtrial'), cfg.tlim_timeXtrial= [min(data.time{1}) max(data.time{1})];        end % output image

% generic function
get_trials = @(x) reshape(cell2mat(x.trial),[size(x.trial{1}) length(x.trial)]); % fast way of getting ft_trials
selchan = @(c,s) find(cell2mat(cellfun(@(x) ~isempty(strfind(x,s)),c,'uniformoutput', false))==1);
selgrad = @(c) find(cell2mat(cellfun(@(x) ~isempty(strfind(x(1:3),'MEG')) && (~isempty(strfind(x(end),'2')) || ~isempty(strfind(x(end),'3'))),c,'uniformoutput', false))==1);
%% select data
% select trials
data.trial      = data.trial(cfg.trial);
if iscell(data.time), data.time       = data.time(cfg.trial); end
if isfield(data,'trialinfo'), data.trialinfo  = data.trialinfo(cfg.trial,:); end
if isfield(data,'sampleinfo'), data.sampleinfo = data.sampleinfo(cfg.trial,:); end

%% get out of fieldtrip strcture for faster usage
time        = data.time{1};
erf         = trimmean(get_trials(data),90,'round',3); % robust averaging to minimize artefacts
data.avg    = erf;
data.time   = time;
data.dimord = 'chan_time';
data        = rmfield(data,{'trial'});
try data    = rmfield(data,{'cfg','sampleinfo','dims', 'trialinfo'}); end

%% combine in 2D complex space
load('nm306all_neighb.mat', 'neighbours');
cfg_                 = [];
cfg_.neighbours      = neighbours;
cfg_.planarmethod    = 'sincos';
cfg_.combinemethod   = 'complex';
cmb                 = ft_combineplanar_local(cfg_,data);
clear cfg_
% compute norm of average
cmb_norm            = cmb;
cmb_norm.avg        = abs(cmb_norm.avg);

%% plot imagesc time
if ismember('img_time',cfg.plot);
    chan_mag = setdiff(selchan(cmb.label,'MEG'),selchan(cmb.label,'+'));
    chan_cmb = intersect(selchan(cmb.label,'MEG'),selchan(cmb.label,'+'));
    
    fh=figure(1);clf;set(gcf,'color','w','position',[50 1 1551 821]);
    set(fh,'Renderer','painters')
    subplot(3,1,1);
    imagesc(time,[],cmb.avg(chan_mag,:),cfg.zlim_mag);
    title('magnetometers');xlabel('time');ylabel('channels');
    axis tight;box off;colorbar;axis([minmax(cfg.tlim_timeXtrial) ylim]); 
    subplot(3,1,2);
    imagesc(time,[],abs(cmb.avg(chan_cmb,:)),cfg.zlim_grad);
    title('gradiometers (norm)');xlabel('time');ylabel('channels');
    axis tight;box off;colorbar; axis([minmax(cfg.tlim_timeXtrial) ylim]); 
    subplot(3,1,3);
    imagesc(time,[],complex2rgb(cmb.avg(chan_cmb,:),cfg.zlim_grad));
    title('gradiometers (complex)');xlabel('time');ylabel('channels');
    axis tight;box off;colorbar;axis([minmax(cfg.tlim_timeXtrial) ylim]); 
    if cfg.save
        drawnow;
        export_fig_cjb([cfg.figure_name '_time.png']);
    end
end
if ismember('butterfly_time',cfg.plot);
    chan_mag = setdiff(selchan(cmb.label,'MEG'),selchan(cmb.label,'+'));
    chan_grad = selgrad(data.label);
    
    fh=figure(3);clf;set(gcf,'color','w','position',[50 1 1551 821]);
    set(fh,'Renderer','painters')
    subplot(2,1,1);
    plot(time,cmb.avg(chan_mag,:));
    ylm = ylim; set(gca,'Ylim', [max(ylm(1), -5e-13), min(ylm(2), 5e-13)]);
    set(gca,'XLim', minmax(cfg.tlim_timeXtrial));
    title('magnetometers');xlabel('time');ylabel('channels');
    subplot(2,1,2);
    plot(time,data.avg(chan_grad,:));
    ylm = ylim; set(gca,'Ylim', [max(ylm(1), -10e-12), min(ylm(2), 10e-12)]);
    set(gca,'XLim', minmax(cfg.tlim_timeXtrial));
    title('gradiometers');xlabel('time');ylabel('channels');
    if cfg.save
        drawnow;
        export_fig_cjb([cfg.figure_name '_time_butterfly.png']);
    end
end
if ismember('topo',cfg.plot);
    % prepare layout only once
    cfg_        = [];
    cfg_.layout = 'neuromag306mag.lay';
    layout_mag = ft_prepare_layout(cfg_);
    cfg_.layout = 'neuromag306cmb.lay';
    layout_cmb = ft_prepare_layout(cfg_);
    cfg_.layout = 'NM306all.lay';
    cfg_.layout = 'neuromag306all.lay';
    layout = ft_prepare_layout(cfg_);
    clear cfg_
    %% plot classic topo
    fh=figure(2);clf;set(gcf,'color','w','position',[50 1 1551 821]);
    set(fh,'Renderer','painters')
    for t = 1:length(cfg.toi)
        cfg_             = [];
        %cfg_.neighbours  = neighbours;
        cfg_.colorbar    = 'no';
        cfg_.comment     = 'no';
        cfg_.marker      = 'off';
        cfg_.style       = 'straight';
        cfg_.layout      = layout_mag;
        cfg_.interactive = 'no';
        cfg_.xlim        = cfg.toi(t)+[-.01 .01];
        
        % magnetometers
        cfg_.zlim        = cfg.zlim_mag; % TO BE CORRECTED:WHY CHANGING SCALE????? FIELDTRIP BUG !!
        subaxis(2,length(cfg.toi),t, 'SpacingHorizontal',0, 'SpacingVertical',0);
        ft_topoplotER(cfg_,cmb);
        axis tight off;title(round(1000*cfg.toi(t)));
        
        % gradiometers amplitude
        cfg_.layout      = layout_cmb;
        cfg_.zlim        = cfg.zlim_grad;
        cfg_.channel     = 1:102;
        subaxis(2,length(cfg.toi),length(cfg.toi)+t, 'SpacingHorizontal',0, 'SpacingVertical',0);
        ft_topoplotER(cfg_,cmb_norm);
        axis tight off;
    end
    set(gcf,'name',cfg.figure_name);
    
    if cfg.save
        drawnow;
        export_fig_cjb([cfg.figure_name '_topo.png']);
    end
end
