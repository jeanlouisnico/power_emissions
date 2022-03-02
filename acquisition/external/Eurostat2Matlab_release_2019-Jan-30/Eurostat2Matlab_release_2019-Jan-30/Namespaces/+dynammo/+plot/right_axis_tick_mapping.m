function [ymin_right,ymax_right,ticks_right] = right_axis_tick_mapping(ylims_left,yticks_left,ylims_right) %ghandle_left,ghandle_right)
%
% Linear mapping between vertical axes
%
%
% INPUT: ylims_left+yticks_left ... Vertical limits and ticks of the primary graph 
%                                   (of which yticks to be taken as granted)
%        ylims_right            ... Vertical limits of second graph (yticks to be adjusted according to the primary graph)
%
% OUTPUT: ymin_right  ...new minimum of Y axis (second graph)
%         ymax_right  ...new maximum of Y axis (second graph)
%         ticks_right ...new yticks (second graph)
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
%    ylims_left = get(ghandle_left,'ylim');
   ymin = ylims_left(1);
   ymax = ylims_left(2);
   
   relticks = (yticks_left-ymin)./(ymax-ymin);%get(ghandle_left,'ytick')
    tick_num = length(relticks);
    
%     ylims_right = get(ghandle_right,'ylim');
    
%     diffs = this.values(:,1)-this.values(:,2);  
%     if diffs_trigger==2
%        diffs = -diffs; 
%     end
%     diffs_max = max([0;diffs]);
%     diffs_min = min([0;diffs]);
    diffs_range = ylims_right(2) - ylims_right(1);
    
%     if isnan(diffs_range) || diffs_range <= 0 %1e-10
%         diffs_max = 1;
%         diffs_min = -1;
%         diffs_range = 2;
%     end
   
%     % Apply standard x% margin
%     diffs_max = diffs_max + margin_top   *diffs_range;
%     diffs_min = diffs_min - margin_bottom*diffs_range;
%     diffs_range = diffs_max - diffs_min;

    % Units of yaxis (rounded up)
    units = diffs_range/tick_num;
    units_magnitude = 10^floor(log10(units));
    units_ceil = ceil(units/units_magnitude)*units_magnitude;

    % New yticks
    ticks_right = 0:units_ceil:(tick_num-1)*units_ceil;
    ticks_right = ticks_right(:);
    ticks_right = ticks_right + floor(ylims_right(1)/units_ceil)*units_ceil;

    % New ylimits
    slope_factor = (ticks_right(end)-ticks_right(1))/(relticks(end)-relticks(1));
    ymin_right = ticks_right(end) - slope_factor*relticks(end);
    ymax_right = slope_factor + ymin_right;


end %<eof>