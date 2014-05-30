function smart_legend(data,options)
% function smart_legend(data_structure,<options>) produce legend from a structure where the first
% column defines the type of drawing, and the second columns defines it
% label. Each line correspond to a novel entry.
%-----------------------------------------------------------------------
% options.origin    : defines where data should be plotted
%-----------------------------------------------------------------------
% (c) JeanRemi KING 2011, all righs reserved, jeanremi.king+matlab@gmail.com
if nargin == 1
    options.tmp = [];
end
options.orig = getoption(options,'orig',[0 0]);
hold on;
for ii = 1:size(data,1)
    eval(['plot([options.orig(1) options.orig(2)], [options.orig(1), options.orig(2)], ' data{ii,1} ');']);
end
legend(data(:,2));
end 