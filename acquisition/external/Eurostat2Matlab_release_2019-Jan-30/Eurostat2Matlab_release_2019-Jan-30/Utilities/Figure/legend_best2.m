function lgspot = legend_best2(ghandle,lghandle,varargin)
%
% legend_best2() finds a spot for legend so that it does not cross the plotted data
%  
% INPUT:  ghandle ...handle to a subplot where legend is to be placed
%        lghandle ...handle to the legend
%        [optional] ...anything to ban rescaling of the Y limit
%
% OUTPUT: lgspot ...position for the legend
%
% NOTE: older legend_best() has already been made OBSOLETE
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

drawnow;

%% Graphical object handles
tmp = get(lghandle,'UserData');
% phandle = tmp.handles;% -> In M2014b+ and higher we store all handles here,
%                       %    in older versions of Matlab, however, UserData contains 
%                       %    only handles to those objects that are in the legend
%                       %    itself, therefore the legend might be positioned badly in the end
objs = get(lghandle,'String');% Only # of legend items, data are analyzed based on convexHull only

% Data envelope
convexHull = []; %#ok<NASGU>
if isfield(tmp,'convHull') % M2014b+
    convexHull = tmp.convHull;    
else % M2014b- 
    convexHull = evalin('caller','convHull'); 
end
if isempty(convexHull)
    set(lghandle,'orientation','vertical');
    set(lghandle,'location','northeast');
    lgspot = 'north';
    return
end

% Additive margins
width_margin = 0.05;
height_margin = 0.05;
leftspace = 2; % in percentage points, 2 = 2%

posg= get(ghandle,'position');
xlim = get(ghandle,'xlim');
ylim = get(ghandle,'ylim');
xrng = xlim(2)-xlim(1);

%% Space for horizontal orientation

if length(objs) > 4 %length(phandle) > 4
    set(lghandle,'orientation','vertical');
    set(lghandle,'location','eastoutside');
    lgspot = 'out';
    return
elseif length(objs) > 1 %length(phandle) > 1
    set(lghandle,'orientation','horizontal');
    set(lghandle,'location','south');
    
    %poslg = get(lghandle,'position')
    %rehash;%pause(0.07);
    %pause(0.15);
    poslg = get(lghandle,'position');
    
    if poslg(1) > posg(1)
        enough_vert_space = 1;
    else
        enough_vert_space = 0;
    end
else
    enough_vert_space = 0;
end

%% Fixed Y limit
% -> figoverlay() must not change the Y limits
% -> figcombine() can, but in most cases shoud not
if nargin==3
    enough_vert_space = 1;
end

%% North/South positioning vertical

set(lghandle,'orientation','vertical');
set(lghandle,'location','northeast');
% pause(0.15);
poslg = get(lghandle,'position');

[maxgap1, maxgap2, where1, where2, gaps1, gaps2,lg_rel_height,width_] = ...
                explore_strips(lghandle,width_margin,posg,height_margin,ylim,xlim,xrng,convexHull);
% keyboard;            
if maxgap1>width_ || maxgap2>width_ % Vertical
    if maxgap1 >= maxgap2
        start_ = find(maxgap1==gaps1);
        if start_(end)==1
            set(lghandle,'location','northwest');
        elseif start_(end)==length(gaps1)
            set(lghandle,'location','northeast');
        else
            possible_pos = (where1(start_(end))+where1(start_(end)+1))/2-width_/2;
            possible_pos = max(leftspace,possible_pos);
            possible_pos = min(100-leftspace,possible_pos);
            poslg(1) = posg(1) + possible_pos/100*posg(3);
            set(lghandle,'position',poslg);
        end
        lgspot = 'north';
        return
    else
        start_ = find(maxgap2==gaps2);
        if start_(end)==1
            set(lghandle,'location','southwest');
        elseif start_(end)==length(gaps2)
            set(lghandle,'location','southeast');
        else
            possible_pos = (where2(start_(end))+where2(start_(end)+1))/2-width_/2;
            possible_pos = max(leftspace,possible_pos);
            possible_pos = min(100-leftspace,possible_pos);
            set(lghandle,'location','southeast');
            %pause(0.15);
            poslg = get(lghandle,'position');
            poslg(1) = posg(1) + possible_pos/100*posg(3);
            set(lghandle,'position',poslg);
        end
        lgspot = 'south';
        return
    end
end

%% North/South positioning horizontal

if enough_vert_space
    set(lghandle,'orientation','horizontal');
    set(lghandle,'location','northeast');
    %pause(0.15);
    poslg = get(lghandle,'position');
    
    [maxgap1, maxgap2, where1, where2, gaps1, gaps2,lg_rel_height,width_] = ...
                explore_strips(lghandle,width_margin,posg,height_margin,ylim,xlim,xrng,convexHull);
    
    if maxgap1>width_ || maxgap2>width_ % Vertical
        if maxgap1 >= maxgap2
            start_ = find(maxgap1==gaps1);
            if start_(end)==1
                set(lghandle,'location','northwest');
            elseif start_(end)==length(gaps1)
                set(lghandle,'location','northeast');
            else
                possible_pos = (where1(start_(end))+where1(start_(end)+1))/2-width_/2;
                possible_pos = max(leftspace,possible_pos);
                possible_pos = min(100-leftspace,possible_pos);
                poslg(1) = posg(1) + possible_pos/100*posg(3);
                set(lghandle,'position',poslg);
            end
            lgspot = 'north';
            return
        else
            start_ = find(maxgap2==gaps2);
            if start_(end)==1
                set(lghandle,'location','southwest');
            elseif start_(end)==length(gaps2)
                set(lghandle,'location','southeast');
            else
                possible_pos = (where2(start_(end))+where2(start_(end)+1))/2-width_/2;
                possible_pos = max(leftspace,possible_pos);
                possible_pos = min(100-leftspace,possible_pos);
                set(lghandle,'location','southeast');
                %pause(0.15);
                poslg = get(lghandle,'position');
                poslg(1) = posg(1) + possible_pos/100*posg(3);
                set(lghandle,'position',poslg);
            end
            lgspot = 'south';
            return
        end
    end
    
    % South strip injection
    set(lghandle,'location','south');
   %set(ghandle,'ylim',[ylim(1)-(ylim(2)-ylim(1))*lg_rel_height ylim(2)]); -> cannot inject if figoverlay(), or figcombine with fixed YLims
    lgspot = 'south';
    
else
    % Vertical limit injection
    if maxgap1 >= maxgap2
        start_ = find(maxgap1==gaps1);
        possible_pos = (where1(start_(end))+where1(start_(end)+1))/2-width_/2;
        possible_pos = max(leftspace,possible_pos);
        possible_pos = min(100-leftspace-poslg(3)*100*width_margin,possible_pos);
        poslg(1) = posg(1) + possible_pos/100*posg(3);
        set(lghandle,'position',poslg);
        set(ghandle,'ylim',[ylim(1) ylim(2)+(ylim(2)-ylim(1))*lg_rel_height]);
        lgspot = 'north';
    else
        start_ = find(maxgap2==gaps2);
        possible_pos = (where2(start_(end))+where2(start_(end)+1))/2-width_/2;
        possible_pos = max(leftspace,possible_pos);
        possible_pos = min(100-leftspace,possible_pos);
        set(lghandle,'location','southeast');
        poslg = get(lghandle,'position');
        poslg(1) = posg(1) + possible_pos/100*posg(3);
        set(lghandle,'position',poslg);
        set(ghandle,'ylim',[ylim(1)-(ylim(2)-ylim(1))*lg_rel_height ylim(2)]);
        lgspot = 'south';
    end
end

%% Support functions
    
    function [maxgap1, maxgap2, where1, where2, gaps1, gaps2,lg_rel_height,width_] = ...
                explore_strips(lghandle,width_margin,posg,height_margin,ylim,xlim,xrng,convexHull)
        %pause(0.15);
%         keyboard;
        poslg_= get(lghandle,'position');

        lg_rel_width = poslg_(3)/posg(3);
        lg_rel_width = (ceil(100*lg_rel_width)/100)+width_margin;

        lg_rel_height = poslg_(4)/posg(4);
        lg_rel_height = ceil(100*lg_rel_height)/100+height_margin;

        width_ = round(lg_rel_width*100);
        
        % Strips north/south
        cutoff_ver_value_north = (1-lg_rel_height)*(ylim(2)-ylim(1))+ylim(1);
        cutoff_ver_value_south = (  lg_rel_height)*(ylim(2)-ylim(1))+ylim(1);

        strip_north = zeros(100,1);
        strip_south = zeros(100,1);
%         for ii = 1:length(phandle)
%             xdata = get(phandle(ii),'Xdata');%tind
%             ydata = get(phandle(ii),'Ydata');%this.values

            xdata = convexHull(:,1);
            ydata_min = convexHull(:,2);
            ydata_max = convexHull(:,3);
            
            % Piece-wise linear segments interpolation
%             if length(xdata) < 100
%                 xdata = xdata(~isnan(ydata));
%                 if ~isempty(xdata)
%                     ydata = ydata(~isnan(ydata));
%                     nx = length(xdata);
%                     numseg = (100 - nx)/(nx-1);
%                     numseg = nx + (nx-1)*ceil(numseg);% ceil() pushes numseg above 100 
%                     xnew = linspace(xdata(1),xdata(end),numseg);
%                     ydatanew = interp1q(xdata(:),ydata(:),xnew(:));
%                     dataXY = sortrows([xdata(:) ydata(:);xnew(:) ydatanew(:)]);
%                     xdata = dataXY(:,1);
%                     ydata = dataXY(:,2);
%                 end
%             end
            nx = length(xdata);
            if nx<100
                %xdata = xdata(~isnan(ydata));
                if ~isempty(xdata)
                    %ydata = ydata(~isnan(ydata));
                    numseg = (100 - nx)/(nx-1);
                    numseg = nx + (nx-1)*ceil(numseg);% ceil() pushes numseg above 100 
                    xnew = linspace(xdata(1),xdata(end),numseg);
                    
                    ydatanew_mins = interp1q(xdata(:),ydata_min(:),xnew(:));
                    ydatanew_maxes = interp1q(xdata(:),ydata_max(:),xnew(:));
                    
                    dataXY_min = sortrows([xdata(:) ydata_min(:);xnew(:) ydatanew_mins(:)]);
                    dataXY_max = sortrows([xdata(:) ydata_max(:);xnew(:) ydatanew_maxes(:)]);
                    xdata = dataXY_min(:,1);% the same in both 'max'/'min'?
                    ydata_min = dataXY_min(:,2);
                    ydata_max = dataXY_max(:,2);
                end
            end
            
            %peaks_1 = round(100*(xdata(ydata>=cutoff_ver_value_north)-xlim(1))./xrng)/100;%+xlim(1)
            %peaks_2 = round(100*(xdata(ydata<=cutoff_ver_value_south)-xlim(1))./xrng)/100;%+xlim(1)            
             peaks_1 = round(100*(xdata(ydata_max>=cutoff_ver_value_north)-xlim(1))./xrng)/100;%+xlim(1)
             peaks_2 = round(100*(xdata(ydata_min<=cutoff_ver_value_south)-xlim(1))./xrng)/100;%+xlim(1)
            if ~isempty(peaks_1)
                rounded = max(1,round(peaks_1*100));% round() may result in 0, which is impossible for a position
                strip_north(rounded)=1;
            end
            if ~isempty(peaks_2)
                rounded = max(1,round(peaks_2*100));% round() may result in 0, which is impossible for a position
                strip_south(rounded)=1;
            end
%         end

        where1 = [0;find(strip_north);100];
        where2 = [0;find(strip_south);100];
        gaps1 = diff(where1);
        gaps2 = diff(where2);
        maxgap1 = max(gaps1);
        maxgap2 = max(gaps2);
    end %<explore_strips>

end % <eof>