function [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = freq_mismatch(this,args,lg_trigger,caption_trigger,plotname,style)
% 
% Line plot for series with various frequency
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

freqs = fieldnames(this);
num_freqs = length(freqs);

%% Determine lowest frequency present
if any(strcmp(freqs,'YY'))
    freq_king = 'Y';
elseif any(strcmp(freqs,'QQ'))
    freq_king = 'Q';
elseif any(strcmp(freqs,'MM'))
    freq_king = 'M';
else
    freq_king = 'D';
end

%% Time series range
if ~isinf(args.range)
    
    in = args.range;
    
    % Handle integer range input
    if isa(in,'double')
        if all(floor(in)==in)
            in = sprintf('%.0f:%.0f',in(1),in(end));
        else
            dynammo.error.tsobj('The range must be a string or integer array...');
        end
    end
    
    % Start/finish parts
    parts = regexp(in,':','split');
    if length(parts)>2
        error_msg('Range processing','Two many colons identified...',in);
    end
    start_ = parts{1};
    finish_ = parts{end};
    
    % Determine frequency
    seq = {'-';'M';'Q'};
    freq_input = seq(~cellfun('isempty',regexp(upper(start_),seq)));
    freq_input2= seq(~cellfun('isempty',regexp(upper(finish_),seq)));
    if length(freq_input)>1 || length(freq_input2)>1
        error_msg('Range processing','Incorrect input:',in);
    end
    if ischar(freq_input) || ischar(freq_input2)
        if ~strcmp(freq_input{:},freq_input2{:}) % empty, empty problem
            error_msg('Range processing','Incorrect input:',in);
        end
    end
    
    % Process frequency chunks one by one
    for tt = 1:num_freqs
        freq_now = freqs{tt};
        tsobj_now = this.(freq_now);
        switch freq_now
            case 'YY'
                if isempty(freq_input) && isempty(freq_input2) % yearly input
                    in_now = sprintf('%s:%s',start_,finish_);
                elseif strcmpi(freq_input,'Q') || strcmpi(freq_input,'M') || strcmpi(freq_input,'-')
                    in_now = sprintf('%s:%s',start_(1:4),finish_(1:4));
                else
                    error_msg('Range processing','Incorrect input:',in);
                end
                range_adj = in_now;
            case 'QQ'
                if isempty(freq_input) && isempty(freq_input2) % yearly input
                    %in_now = sprintf('%s:%s',start_,finish_);
                    %range_adj = dynammo.tsobj.range_short_notation(in_now,'Q');
                    [start_,finish_] = dynammo.tsobj.range_short_notation('Q',start_,finish_);
                    range_adj = sprintf('%s:%s',start_,finish_);
                elseif strcmpi(freq_input,'Q')
                    range_adj = in;
                elseif strcmpi(freq_input,'M') || strcmpi(freq_input,'-')
                    month1 = eval(start_(6:end));
                    month2 = eval(finish_(6:end));
                    part1 = sprintf('q%d',ceil(month1/3));
                    part2 = sprintf('q%d',ceil(month2/3));
                    in_now = sprintf('%s%s:%s%s',start_(1:4),part1,finish_(1:4),part2);
                    range_adj = in_now;
                else
                    error_msg('Range processing','Incorrect input:',in);
                end
            case 'MM'
                if isempty(freq_input) && isempty(freq_input2) % yearly input
                    %in_now = sprintf('%s:%s',start_,finish_);
                    %range_adj = dynammo.tsobj.range_short_notation(in_now,'M');
                    [start_,finish_] = dynammo.tsobj.range_short_notation('M',start_,finish_);
                    range_adj = sprintf('%s:%s',start_,finish_);
                elseif strcmpi(freq_input,'Q')
                    quarter1 = eval(start_(6));
                    quarter2 = eval(finish_(6));
                    part1 = sprintf('m%d',(quarter1-1)*3+1);
                    part2 = sprintf('m%d',(quarter2-1)*3+1);
                    in_now = sprintf('%s%s:%s%s',start_(1:4),part1,finish_(1:4),part2);
                    range_adj = in_now;
                elseif strcmpi(freq_input,'M')
                    range_adj = in;
                elseif strcmpi(freq_input,'-')
                    part1 = sprintf('%d',eval(start_(6:7)));
                    part2 = sprintf('%d',eval(finish_(6:7)));
                    in_now = sprintf('%sm%s:%sm%s',start_(1:4),part1,finish_(1:4),part2);
                    range_adj = in_now;
                else
                    error_msg('Range processing','Incorrect input:',in);
                end
            case 'DD'
                if isempty(freq_input) && isempty(freq_input2) % yearly input
                    %in_now = sprintf('%s:%s',start_,finish_);
                    %range_adj = dynammo.tsobj.range_short_notation(in_now,'D');
                    [start_,finish_] = dynammo.tsobj.range_short_notation('D',start_,finish_);
                    range_adj = sprintf('%s:%s',start_,finish_);
                elseif strcmpi(freq_input,'Q')
                    quarter1 = eval(start_(6));
                    quarter2 = eval(finish_(6));
                    if quarter1==4
                        part1 = sprintf('-%d-01',(quarter1-1)*3+1);
                    else
                        part1 = sprintf('-0%d-01',(quarter1-1)*3+1);
                    end
                    if quarter2==4
                        part2 = sprintf('-%d-31',(quarter2-1)*3+1);
                    else
                        part2 = sprintf('-0%d-31',(quarter2-1)*3+1);
                    end
                    in_now = sprintf('%s%s:%s%s',start_(1:4),part1,finish_(1:4),part2);
                    range_adj = in_now;
                elseif strcmpi(freq_input,'M')
                    month1 = eval(start_(6:end));
                    month2 = eval(finish_(6:end));
                    if log10(month1) < 1
                        part1 = sprintf('-0%d-01',month1);
                    else
                        part1 = sprintf('-%d-01',month1);
                    end
                    if log10(month2) < 1
                        part2 = sprintf('-0%d-31',month2);
                    else
                        part2 = sprintf('-%d-31',month2);
                    end
                    in_now = sprintf('%s%s:%s%s',start_(1:4),part1,finish_(1:4),part2);
                    range_adj = in_now;
                elseif strcmpi(freq_input,'-')
                    
                    % 2010-01 short range notation for daily data
                    if all(cellfun('length',parts(:))==7)
                        if length(parts)==2
                            range_adj = strcat(start_,'-01:',finish_,'-31');% Feb. data ok if not 31
                        else
                            range_adj = strcat(start_,'-01:',start_,'-31');% Feb. data ok if not 31
                        end
                    else
                        range_adj = in;% Standard range input
                    end
                    
                else
                    error_msg('Range processing','Incorrect input:',in);
                end
            
        end
        
        this.(freq_now) = trim(tsobj_now,range_adj);
        if isempty(this.(freq_now).values)
            close();
            dynammo.error.tsobj('Requested range resulted in empty time series object...'); 
        end
        tind_now = this.(freq_now).tind;
        
        if tt==1
            tind_min = tind_now(1);
            tind_max = tind_now(end);
        else
            tind_min = min(tind_now(1),tind_min);
            tind_max = max(tind_now(end),tind_max);
        end
        
        % Switch to originals
        start_ = parts{1};
        finish_ = parts{end};
            
    end
    
    tind = [tind_min;tind_max];
    
else
    freq_first = freqs{1};
    tind_min = this.(freq_first).tind(1);
    tind_max = this.(freq_first).tind(end);
    
    if num_freqs > 1
        for tt = 2:num_freqs
            tind_now = this.(freqs{tt}).tind;
            tind_min = min(tind_now(1),tind_min);
            tind_max = max(tind_now(end),tind_max);
        end
    end
    tind = [tind_min;tind_max];
    
end

% Multiplot
numlines = length(plotname);

%% Vertical limit
this_now = this.(freqs{1});
values = this_now.values;

min_value = min(values(:));
max_value = max(values(:));

%% Data envelope (convex hull input)
min_vect = cell(num_freqs,1);
max_vect = cell(num_freqs,1);
values2 = values;
values2(isnan(values2)) = 0;% zero line also a part of the convex hull
min_vect{1} = min(values2,[],2);
max_vect{1} = max(values2,[],2);

for tt = 2:num_freqs
    this_now = this.(freqs{tt});
    values = this_now.values;
    min_value = min(min_value,min(values(:)));
    max_value = max(max_value,max(values(:)));
    
    % Data envelope (convex hull input)
    values2 = values;
    values2(isnan(values2)) = 0;% zero line also a part of the convex hull
    min_vect{tt} = min(values2,[],2);
    max_vect{tt} = max(values2,[],2);
end

relevant_content = 0;
data_crit = abs(min_value-max_value);
if data_crit > 1e-10
    yrange = max_value - min_value;
    ymin = min_value - args.margin_bottom*yrange;
    ymax = max_value + args.margin_top*yrange;
    if data_crit > 1e-3
        relevant_content = 1;
    end
elseif ~isnan(min_value) && ~isnan(max_value) % the same value for min/max
    ymin = min_value - 1;
    ymax = max_value + 1;
else % at least one has NaNs
    ymin = 0;
    ymax = 1;
end

%% Horizontal limits
if tind(1)~=tind(end)
    fullspan = tind(end)-tind(1);
    min_x_limit = tind(1)-args.margin_inset*fullspan;
    max_x_limit = tind(end)+args.margin_inset*fullspan;
else
    min_x_limit = tind(1)-args.margin_inset;
    max_x_limit = tind(end)+args.margin_inset;
end

%% Plot step [each freq]
if prod(args.subplot)==1
    ghandle = axes('position',getappdata(gcf,'SubplotDefaultAxesLocation'));
    
else
    tmp_    = subplot(args.subplot(1),args.subplot(2),args.plotnum);%,'align');
    pos_ = get(tmp_,'position');
    delete(tmp_);
    ghandle = axes('position',pos_);

end

% Space for suptitle
%     pos = get(ghandle,'position');
%     pos(2) = pos(2)*args.yscale;
%     pos(4) = pos(4)*args.yscale;
%     set(ghandle,'position',pos);
if relevant_content==1
    set(ghandle,'tag','line');
else
    set(ghandle,'tag','line','Color',[1 0.9 0.9]);
end

phandle = cell(numlines,1);
if args.emphasize>0
    emphandle = cell(numlines,1);
else
    emphandle = cell(0,0);
end
hold on;
box on;

counter = 1;
tind_CH = cell(num_freqs,1);
counter_color = 1; % -> plots with a frequency mismatch must be colored differently
for tt = 1:num_freqs
    this_now = this.(freqs{tt});
    tind = this_now.tind;
    
    % Data envelope:
    tind_CH{tt} = tind;
    
    [~,objs] = size(this_now.values);
    
    if args.emphasize>0
        for ii = 1:objs %size(this_now.values,2)
            
            % Underlying white line to make things visible
            emphandle{counter} = plot(tind,this_now.values(:,ii), ...
                'color',[0.95 1 0.6], ...
                'linewidth',style.struct.LineWidth(counter_color)+args.emphasize);
            
            % Actual data to show
            phandle{counter} = plot(tind,this_now.values(:,ii),style.cell{counter_color,:});
            
            counter = inc(counter);
            counter_color = inc(counter_color);
        end
    else
        for ii = 1:objs %size(this_now.values,2)
            
            %if any(isnan(this.values(:,ii)) -> here ok, but legend_best needs nanfree series
            phandle{counter} = plot(tind,this_now.values(:,ii),style.cell{counter_color,:});
            
            counter = inc(counter);
            counter_color = inc(counter_color);
        end
    end
end

% Limits
%data_axis = gca;
set(gca,'Ylim',[ymin ymax]);
set(gca,'xlim',[min_x_limit max_x_limit]);

% X ticks and labels
[xticks,xlabels] = labels(this.([freq_king freq_king]),args.maxticks);
set(gca,'xtick',xticks);
set(gca,'xticklabel',xlabels);

plotname = strrep(plotname,'_','\_');

% caption
if caption_trigger
    thandle = title(plotname{1},'FontWeight','normal');
else
    thandle = cell(0,0);
end

%% Legend
if lg_trigger
    
    % Data envelope (convex hull)
    all_tind = cat(1,tind_CH{:});
    all_mins = cat(1,min_vect{:});
    all_maxes = cat(1,max_vect{:});
    [~,where] = sort(all_tind);
    all_tind = all_tind(where);
    all_mins = all_mins(where);
    all_maxes = all_maxes(where);
    
    % Isolate unique blocks
    [all_tind,~,n] = unique(all_tind);
    all_mins = accumarray(n, all_mins, [], @min);% Already NaN free
    all_maxes = accumarray(n, all_maxes, [], @max);% Already NaN free
    
    if ~dynammo.compatibility.M2016a
        if ~isempty(args.legend)
            [lghandle,entries] = legend(cat(1,phandle{:}),strrep(args.legend,'_','\_'));
        else
            [lghandle,entries] = legend(cat(1,phandle{:}),plotname);
        end
        
        % Data envelope (for evalin())
        convHull = [all_tind all_mins all_maxes];%#ok<NASGU>
        
        % Click legend property
        if strcmpi(args.visible,'on')
            for ient = 1:length(phandle)
                set(entries(ient), 'HitTest', 'on', 'ButtonDownFcn',...
                    @(varargin) legendClick(ient,entries,style.struct.Color,phandle), ...legendClick(entries(ient),phandle{ient}), ...
                    'UserData', true);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%
    else % M2016a+
        %%%%%%%%%%%%%%%%%%%%%
        
        if ~isempty(args.legend)
            lghandle = legend(cat(1,phandle{:}),strrep(args.legend,'_','\_'));
        else
            lghandle = legend(cat(1,phandle{:}),plotname);
        end
        
        % Do not update legend when new objects are generated (e.g. zebra)
        if dynammo.compatibility.isAutoUpdate
           set(lghandle,'autoupdate','off'); 
        end
        
        lghandle.UserData.handles = double(lghandle.PlotChildren(:));%phans;
        lghandle.UserData.lstrings = lghandle.String(:);%lstrings(:);
        %lghandle.UserData.LabelHandles = entries;
        lghandle.UserData.PlotHandle = ghandle;% Note that this field is not linked as a listener when the value changes
        % -> gobj_generate() uses it, but it should work
        %lghandle.UserData.LegendPosition -> better to take it directly from legend handle (it is connected to listeners, when units/pos change)
        
        lghandle.UserData.convHull = [all_tind all_mins all_maxes];% NaNs treated inside legend_best2
        
        % Click legend property
        if strcmpi(args.visible,'on')
            set(lghandle,'ItemHitFcn',@lgndItemClick);
        end
        
    end
    
    % Find spot for legend
    if (args.subplot(1)*args.subplot(2))>6
        lg_pos = get(lghandle,'position');
        buff_ = 0.05;
        set(lghandle,'position',[pos_(1) pos_(2)+pos_(4)+buff_ lg_pos(3) lg_pos(4)]);
    elseif any(strcmpi(args.A4,'slide')) %{'4:3';'16:9'}
        set(lghandle,'orientation','horizontal');
        pos_ = get(lghandle,'position');
        pos_(1) = 0.5-pos_(3)/2;
        pos_(2) = 0.01;
        set(lghandle,'position',pos_);
%         lgspot = '';        
    else
        legend_best2(ghandle,lghandle);
        % North/south injection changes Y limits, relevant for dynammo.plot.line() graphs only
        
    end
    
else
    lghandle = 0;
    %lgspot = '';
end

% Differences between time series <bars> - not present!
dhandle = '';

%% Highlighting
% + ordering line/bar objs
if ~isempty(args.highlight)
    isZebra = 0;
    if iscell(args.highlight)
        nhigh = length(args.highlight);
        fill_handle = cell(nhigh,1);
        
    else
        if ~isempty(strfind(args.highlight,'zebra'))
            if strcmpi(args.highlight(end),'Y') % Yearly zebra
                isZebra = 2;
                unqtind = unique(floor(this.([freq_king freq_king]).tind));
                if mod(length(unqtind),2)~=0
                    unqtind = [unqtind;unqtind(end)+1];
                end
                unqtind = reshape(unqtind,2,length(unqtind)/2);
                args.highlight = num2cell(unqtind,1);
                args.highlight = args.highlight(:);
                
            else % zebra by period
                isZebra = 1;
                if mod(length(this.([freq_king freq_king]).tind),2)==0
                   %args.highlight = cellfun(@(x,y) [x,':',y],this.range(1:2:end),this.range(2:2:end),'UniformOutput',false);
                    args.highlight = cellfun(@(x) x,this.([freq_king freq_king]).range(1:2:end),'UniformOutput',false);
                else
                   %args.highlight = cellfun(@(x,y) [x,':',y],this.range(1:2:end-1),this.range(2:2:end),'UniformOutput',false);
                    args.highlight = cellfun(@(x) x,this.([freq_king freq_king]).range(1:2:end-1),'UniformOutput',false);
                end
            end
            nhigh = length(args.highlight);
            fill_handle = cell(nhigh,1);             
            
        else        
            nhigh = 1;
            fill_handle = cell(1,1);
            if ischar(args.highlight) || isa(args.highlight,'double')
                args.highlight = {args.highlight};
            end
        
        end
        
    end
    
    ylims = get(ghandle,'Ylim');
    ymin = ylims(1)-1e3;
    ymax = ylims(2)+1e3;
    
    for ih = 1:nhigh
        [highlight_per_from,highlight_per_to] = dynammo.plot.get_highlight_range(freq_king,args,max_x_limit,ih,isZebra);
        
        fill_handle{ih} = patch([highlight_per_from highlight_per_to highlight_per_to highlight_per_from], ...
            [ymin ymin ymax ymax],[0.9 0.9 0.9]);% 3D trick: [-1 -1 -1 -1],
        set(fill_handle{ih},'LineStyle','none');
        if dynammo.compatibility.newGraphics
            set(fill_handle{ih},'FaceAlpha',0.6);
        end
        
    end
    
    set(ghandle,'ygrid','on','gridlinestyle','--');% : --);
    set(ghandle,'xgrid','off');
    set(ghandle,'layer','top');
    set(ghandle,'children',cat(1,phandle{:},emphandle{:},fill_handle{:}));
    
else
    set(ghandle,'xgrid','on');
    set(ghandle,'ygrid','on');
    set(ghandle,'gridlinestyle','--');% : --
    set(ghandle,'children',cat(1,phandle{:},emphandle{:}));
    fill_handle = '';
end

hold off;

end %<eof>