function convHull = convexHull_legacy2014b(ghandle)
%
% Creates a data envelope (convex hull) for given subplot object
% (Applicable to older versions of Matlab, also used inside legend2())
%
% INPUT: ghandle ...handle to a subplot
%
% OUTPUT: convHull ...[n,3] matrix of timing, min. values and max. values
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% -> Pull all data objects from sub1 parent
kids = get(ghandle,'children'); % Should not matter if we take original kids, 
                                % or kids from the newly established figure, only the data matter

%% Identify data

xdata_pool = [];
ydata_pool = [];
xdata_bar = [];
ydata_bar = [];
for ikid = 1:length(kids)
    tmp_ = get(kids(ikid));
    if isfield(tmp_,'XData')
        if isfield(tmp_,'BarWidth')
            if ~strcmp(tmp_.BarLayout,'stacked')
                %keyboard;
                %error_msg('Compatibility','Only ''stacked'' bar graphs can be processed by figcombine()/figoverlay()/legend2()...');
                % -> legend will ignore such objects
            else
                xdata_bar = [xdata_bar(:);tmp_.XData(:)];
                ydata_bar = [ydata_bar(:);tmp_.YData(:)];                    
            end
        else % Line plot
            xdata_pool = [xdata_pool(:);tmp_.XData(:)];
            ydata_pool = [ydata_pool(:);tmp_.YData(:)];
        end
    end
end

%% Treatment of 'bar' graphs

if ~isempty(xdata_bar)

    % NaN treatment
    ydata_bar(isnan(ydata_bar)) = 0;

    % @sum per time period 
    % (needed separately for both positive and negative contributions)
    [xdata_bar,~,n] = unique(xdata_bar);
    
    ydata_bar_pos = ydata_bar;
    ydata_bar_neg = ydata_bar;
    
    ydata_bar_pos(ydata_bar_pos<0) = 0;
    ydata_bar_neg(ydata_bar_neg>0) = 0;
    
    ydata_bar_pos = accumarray(n, ydata_bar_pos, [], @sum);
    ydata_bar_neg = accumarray(n, ydata_bar_neg, [], @sum);

    xdata_pool = [xdata_pool(:);
                  xdata_bar;
                  xdata_bar];
    ydata_pool = [ydata_pool(:);
                  ydata_bar_pos;
                  ydata_bar_neg];

end

%% Output generation

if ~isempty(xdata_pool)

    % NaN treatment
    ydata_pool(isnan(ydata_pool)) = 0;

    % Sort according to time (timing is not unique)
    [~,where] = sort(xdata_pool);
    xdata_pool = xdata_pool(where);
    ydata_pool = ydata_pool(where);

    % Isolate unique blocks
    [xdata_pool,~,n] = unique(xdata_pool);
    
    convHull = [xdata_pool accumarray(n, ydata_pool, [], @min)  ...
                           accumarray(n, ydata_pool, [], @max)];

else
    convHull = [];
end

end %<eof>