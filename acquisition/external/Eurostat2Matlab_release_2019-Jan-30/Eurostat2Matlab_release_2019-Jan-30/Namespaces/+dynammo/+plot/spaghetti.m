function [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = spaghetti(this,args,lg_trigger,caption_trigger,plotname,style)
% 
% Spaghetti plotter for tsobj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Range resolution
% Time series range
freq = this.frequency;

if ~isinf(args.range)

    [~,range] = tindrange(freq,args.range);
    
    this = trim(this,strcat(range{1},':',range{end}));
    if isempty(this.values)
       close();
       dynammo.error.tsobj('Requested range resulted in empty time series object...'); 
    end
    tind = this.tind;
else
    tind = this.tind;
end

% Multiline plot
[~,objs] = size(this.values);

%% Vertical limits
values = this.values;
min_value = min(values(:));
max_value = max(values(:));

relevant_content = 0;
data_crit = abs(min_value-max_value);
if data_crit > 1e-10
    yrange = max_value - min_value;
    ymin = min_value - args.margin_bottom*yrange;
    ymax = max_value + args.margin_top*yrange;
    if data_crit > 1e-3
        relevant_content = 1;
    end
elseif ~isnan(min_value) && ~isnan(max_value) % the same value for max/min
    ymin = min_value - 1;
    ymax = max_value + 1;
else % at least one is NaN
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

%% Plot area

if prod(args.subplot)==1
    ghandle = axes('position',getappdata(gcf,'SubplotDefaultAxesLocation'));
    
else
    tmp_ = subplot(args.subplot(1),args.subplot(2),args.plotnum);
    %     keyboard;
    %     title('asdf');
    %drawnow;% -> to let subplot listeners to resize the parent subplot
    % !!! works but is way too slow !!!
    pos_ = get(tmp_,'position');
    delete(tmp_);
    ghandle = axes('position',pos_);
    %     keyboard;
    % Space for suptitle
    %     pos = get(ghandle,'position');
    %     pos(2) = pos(2)*args.yscale;
    %     pos(4) = pos(4)*args.yscale;
    %     set(ghandle,'position',pos);

end

if relevant_content==1
    set(ghandle,'tag','line');
else
    set(ghandle,'tag','line','Color',[1 0.9 0.9]);
end
phandle = cell(objs,1);
hold on;
box on;

%% Plot step (line plot)

if args.emphasize>0
    emphandle = cell(objs,1);
    for ii = 1:objs
        
        % Underlying white line to make things visible
        emphandle{ii} = plot(tind, ...
            this.values(:,ii), ...
            'Color',[0.88 0.98 0.38], ...emphasizing does not use alpha channel 
            'LineWidth',style.struct.LineWidth(ii)+args.emphasize);
        
        % ### Actual data to show
        phandle{ii} = plot(tind, ...
            this.values(:,ii), ...
            style.cell{ii,:});
        % ###
    end
else
    emphandle = cell(0,0);
    for ii = 1:objs
        
        % ### 
        phandle{ii} = plot(tind, ...
            this.values(:,ii), ...
            style.cell{ii,:});
        % ###
    end
end

%% Limits
%data_axis = gca;
set(ghandle,'Ylim',[ymin ymax]);
set(ghandle,'xlim',[min_x_limit max_x_limit]);

%% X ticks and labels
[xticks,xlabels] = labels(this,args.maxticks);
set(ghandle,'xtick',xticks);
set(ghandle,'xticklabel',xlabels);

%% Legend entries
% -> First entry per each block is used by default
plotname = strrep(plotname(args.spaghetti_blocks(:,1)),'_','\_');

%% caption
if caption_trigger
    thandle = title(plotname{1},'FontWeight','normal');
else
    thandle = cell(0,0);
end

%% Legend
if lg_trigger
    if ~dynammo.compatibility.M2016a
        
        if ~isempty(args.legend)
            [lghandle,entries] = legend(cat(1,phandle{args.spaghetti_blocks(:,1)}),strrep(args.legend,'_','\_'));
        else
            [lghandle,entries] = legend(cat(1,phandle{args.spaghetti_blocks(:,1)}),plotname);
        end
        
        % Data envelope (for evalin())
        convHull = [this.tind min(this.values,[],2) max(this.values,[],2)]; %#ok<NASGU>
        
        % Click legend property
        if strcmpi(args.visible,'on')
            for ient = 1:length(phandle)
                set(entries(ient), 'HitTest', 'on', 'ButtonDownFcn',...
                    @(varargin) legendClick(ient,entries,style.struct.Color,phandle), ...
                    'UserData', true);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%
    else % M2016a+
        %%%%%%%%%%%%%%%%%%%%%
        
        if ~isempty(args.legend)
            lghandle = legend(cat(1,phandle{args.spaghetti_blocks(:,1)}),strrep(args.legend,'_','\_'));
        else
            lghandle = legend(cat(1,phandle{args.spaghetti_blocks(:,1)}),plotname);
        end
        
        % Do not update legend when new objects are generated (e.g. zebra)
        if dynammo.compatibility.isAutoUpdate
           set(lghandle,'autoupdate','off'); 
        end        
        
        % Create UserData from scratch (we mimic M2014a- behavior in that all legend listeners are in UserData)
        lghandle.UserData.handles = double(lghandle.PlotChildren(:));%phans;
        lghandle.UserData.lstrings = lghandle.String(:);%lstrings(:);
        %lghandle.UserData.LabelHandles = entries;
        lghandle.UserData.PlotHandle = ghandle;% Note that this field is not linked as a listener when the value changes
        % -> gobj_generate() uses it, but it should work
        %lghandle.UserData.LegendPosition -> better to take it directly from legend handle (it is connected to listeners, when units/pos change)
        
        % Data envelope (convex hull)
        lghandle.UserData.convHull = [this.tind min(this.values,[],2) max(this.values,[],2)];% NaNs treated inside legend_best2
        
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
        lgspot = '';

    else
        lgspot = legend_best2(ghandle,lghandle);

        % North/south injection changes Y limits
        ylims = get(ghandle,'YLim');
        ymin = ylims(1);
        ymax = ylims(2);
        
    end
    
else
    lghandle = 0;
    lgspot = '';
end

%% Differences between time series <bars>

dhandle = '';
diffs_trigger = 0;

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
                unqtind = unique(floor(this.tind));
                if mod(length(unqtind),2)~=0
                    unqtind = [unqtind;unqtind(end)+1];
                end
                unqtind = reshape(unqtind,2,length(unqtind)/2);
                args.highlight = num2cell(unqtind,1);
                args.highlight = args.highlight(:);
                
            else % zebra by period
                isZebra = 1;
                if mod(length(this.tind),2)==0
                    %args.highlight = cellfun(@(x,y) [x,':',y],this.range(1:2:end),this.range(2:2:end),'UniformOutput',false);
                     args.highlight = cellfun(@(x) x,this.range(1:2:end),'UniformOutput',false);
                else
                    %args.highlight = cellfun(@(x,y) [x,':',y],this.range(1:2:end-1),this.range(2:2:end),'UniformOutput',false);
                     args.highlight = cellfun(@(x) x,this.range(1:2:end-1),'UniformOutput',false);
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
    
    if diffs_trigger
        ylims = get(right_axis,'Ylim');
    else
        ylims = get(ghandle,'Ylim');
    end
    
    ymin = ylims(1)-1e3;
    ymax = ylims(2)+1e3;

    for ih = 1:nhigh
        [highlight_per_from,highlight_per_to] = dynammo.plot.get_highlight_range(freq,args,max_x_limit,ih,isZebra);

        fill_handle{ih} = patch([highlight_per_from highlight_per_to highlight_per_to highlight_per_from], ...
            [ymin ymin ymax ymax],[0.9 0.9 0.9]);% 3D trick: [-1 -1 -1 -1],
        set(fill_handle{ih},'LineStyle','none');
        if dynammo.compatibility.newGraphics
            set(fill_handle{ih},'FaceAlpha',0.6);
        end
        
    end
        
    if diffs_trigger        
        set(right_axis,'children',cat(1,bl,bhandle,fill_handle{:}));
        set(right_axis,'layer','bottom');
        set(ghandle,'children',cat(1,phandle{:},emphandle{:}));
    else
        set(ghandle,'children',cat(1,phandle{:},emphandle{:},fill_handle{:}));
    end
    
    set(ghandle,'ygrid','on','gridlinestyle','--');% : --
    set(ghandle,'xgrid','off');
    set(ghandle,'layer','top');
    
else
    if ~diffs_trigger
        set(ghandle,'xgrid','on');
        set(ghandle,'ygrid','on');
        set(ghandle,'gridlinestyle',':');% : --
    else
        set(ghandle,'gridlinestyle','--');% : --
    end
    
    set(ghandle,'children',cat(1,phandle{:},emphandle{:}));
    fill_handle = '';
end

hold off;

end %<eof>