function plot_topo(X,cfg)
% plot_topo(X,cfg)
% - input
%   X: chans x samples x trials
%
% necessitates fieldtrip 2011 and data2ft.
%
% (c) JeanRémi King 2011

if nargin == 1
    cfg = [];
end
if ~isfield(cfg,'time'), cfg.time = [0 .004]; end
if ~isfield(cfg,'fsample'), cfg.fsample = 250; end
if ~isfield(cfg,'label_start'), cfg.label_start = 'e'; end
if ~isfield(cfg,'shading'), cfg.shading  = 'interp'; end
if ~isfield(cfg,'style'), cfg.style = 'straight'; end
if ~isfield(cfg,'layout'), cfg.layout = load('my_EGI_net.mat'); cfg.layout = cfg.layout.layout; end
if ~isfield(cfg,'fsample'), cfg.fsample = 250; end
if ~isfield(cfg,'dimord'), cfg.dimord = 'chan_time'; end
if ~isfield(cfg,'comment'), cfg.comment = 'no'; end
if std(squeeze(mean(X,3))) < 10^-10, 
    if ~isfield(cfg,'zlim'), 
        cfg.zlim = [squeeze(min(nanmean(X,3))) - 1 squeeze(max(nanmean(X,3))) + 1]; 
    end
end
    


% reshape X
if length(size(X)) == 1
    ft_data = ft_timelockanalysis([],data2ft(cfg,X(:,[1 1],[1 1])));
elseif length(size(X)) == 2
     ft_data = ft_timelockanalysis([],data2ft(cfg,X(:,:,[1 1])));
else
     ft_data = ft_timelockanalysis([],data2ft(cfg,X));
end
ft_data.dimord = cfg.dimord;
ft_topoplotER(cfg,ft_data);hold on;
fill(cfg.layout.mask{2}(:,1),cfg.layout.mask{2}(:,2),'w');
fill(cfg.layout.mask{3}(:,1),cfg.layout.mask{3}(:,2),'w');
axis off image;axis([-.5 .5 -.5 .5]);


    