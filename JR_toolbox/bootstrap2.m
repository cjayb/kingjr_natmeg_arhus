function [h p] = bootstrap2(x1,x2,b,alpha,n,parametric,void)
% FUNCTION BOOSTRAP
% bootstrap(x,m,b,alpha,n,parametric,void)
% do a resampling of x1 and x2, according to axis 1, n times, evaluate mean,
% and check whether they significantly differ
% -- input
%      x:           matrix where lines are different instances, and columns
%                   dimensions
%      x2:          same as x1
%      b:           (optional) number of resampling
%      alpha:       (optional) alpha value for test
%      n:           (optional) bonferroni correction
%      parametric:  (optional) h = h_non-parametric * h_parametric
%      void:        (optional) show progressbar
% -- output
%      h:           hypothesis verified up to alpha
%      p:           p value 
%
% parametric depends on stats toolbox
% void necessitate progressbar.m
%--------------------------------------------------------------------------
% (c) JeanRémi KING: jeanremi.king+matlab@gmail.com, all rights reserved
%--------------------------------------------------------------------------
if nargin <= 2
    b = 1000; % number of boostrap loop
end
if nargin <= 3
    alpha = .05; % alpha value
end
if nargin <= 4
    n = numel(x) / size(x,1) ; % bonferronni correction
end
if nargin <= 5
    parametric = 0;
end
if nargin <= 6
    void = 0;
end
alpha = alpha / n;

% reshape x into 2D matrix
x1size = size(x1);
x1 = reshape(x1,size(x1,1),[]);
x2size = size(x2);
x2 = reshape(x2,size(x2,1),[]);
d1 = NaN .* zeros(b,size(x1,2));
d2 = NaN .* zeros(b,size(x2,2));
for ii = 1:b % boostrap n times
    if void == 1
        try progressbar(ii,b);% need progressbar
        catch exception
        end
    end
    % make new distribution
    d1(ii,:) = mean(x1(randi(size(x1,1),1,size(x1,1)),:));
    d2(ii,:) = mean(x2(randi(size(x2,1),1,size(x2,1)),:));
end
% t-test whether it's higher than m
try
p = (sum((d1 - d2) < 0) / b);
catch
    disp('memory error: longer algorithm')
    for s = 1:size(d1,2)
    p(s) = sum((d1(:,s) - d2(:,s) < 0)) / b;
    end
end
h = p < alpha;

if parametric
    [h_p p_p] = ttest2(x1, x2);
    h = h .* h_p;
end

 
%return array as it was
try
p = reshape(p,x1size(2:end));
h = reshape(h,x1size(2:end)) .* reshape(~isnan(squeeze(mean(d1))),x1size(2:end));
end

return