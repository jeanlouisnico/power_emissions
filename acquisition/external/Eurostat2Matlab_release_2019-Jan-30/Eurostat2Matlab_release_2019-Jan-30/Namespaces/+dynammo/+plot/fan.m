function [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = fan(this,args,lg_trigger,caption_trigger,plotname,style)
% 
% Line plotter for tsobj()
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


data_crit = abs(min_value-max_value);
if data_crit > 1e-10
    yrange = max_value - min_value;
    ymin = min_value - args.margin_bottom*yrange;
    ymax = max_value + args.margin_top*yrange;
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

%% Identify input intervals
% -> we need non-overlapping intervals
% -> the mid point is taken as the main forecast, plotted as line object

% Start range for intervals
nancrit = any(isnan(values),2);
int_rng = this.tind(~nancrit);

% Range in correct format for patch object
% -> we have to go forward+backward, i.e. twice
int_rng = [int_rng; flipud(int_rng)];

% Crop the input values, retain only the final part where intervals are visible
intvals = values(~nancrit,:);

% Test values at a specific time and derive ordering
guinea_pig = values(end,:);
[~,w] = sort(guinea_pig(:));

nint = floor(objs/2);
ints = cell(nint,1);
for iint = 1:nint
    ints{iint} = [intvals(:,w(iint)); flipud(intvals(:,w(end-iint+1)))];
end

% Base values (on the original range)
line_base_vals = values(:,w(ceil(objs/2)));

%% Check 'plotname' property
% -> by default it contains all input time series names/technames, here we want only half of the interval inputs
if length(plotname)>nint && isempty(args.title)
    plotname = plotname(w(1:nint));
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

set(ghandle,'tag','fan');

hold on;
box on;

%% Plot step (line plot)

% Intervals
int_han = cell(nint,1);
for iint = 1:nint
    int_han{iint} = patch(int_rng,ints{iint},[0.9 0.9 0.9]);% 3D trick: [-1 -1 -1 -1],
    set(int_han{iint},'LineStyle','none',style.cell{iint,:});
end

% Emphasizing band
emphandle = cell(1,1);
emphandle{1} = plot(tind,line_base_vals, ...
                    'Color',[1 1 1], ...emphasizing does not use alpha channel 
                    'LineWidth',2+args.emphasize);% LineWidth cannot be inside styling, it would not correspond to patch objects above

% Midcast line
phandle = cell(1,1);
phandle{1} = plot(tind,line_base_vals,'LineWidth',2,'Color',[0 0 0]);

%% Limits
%data_axis = gca;
set(ghandle,'Ylim',[ymin ymax]);
set(ghandle,'xlim',[min_x_limit max_x_limit]);

%% X ticks and labels
[xticks,xlabels] = labels(this,args.maxticks);
set(ghandle,'xtick',xticks);
set(ghandle,'xticklabel',xlabels);

plotname = strrep(plotname,'_','\_');

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
            [lghandle,entries] = legend(cat(1,int_han{:}),strrep(args.legend,'_','\_'));
        else
            [lghandle,entries] = legend(cat(1,int_han{:}),plotname);
        end
        
        % Data envelope (for evalin())
        convHull = [this.tind min(this.values,[],2) max(this.values,[],2)]; %#ok<NASGU>
        
        % Click legend property
        if strcmpi(args.visible,'on')
            for ient = 1:length(int_han)
                set(entries(ient), 'HitTest', 'on', 'ButtonDownFcn',...
                    @(varargin) legendClick(ient,entries,style.struct.FaceColor,int_han), ...
                    'UserData', true);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%
    else % M2016a+
        %%%%%%%%%%%%%%%%%%%%%
        
        if ~isempty(args.legend)
            lghandle = legend(cat(1,int_han{:}),strrep(args.legend,'_','\_'));
        else
            lghandle = legend(cat(1,int_han{:}),plotname);
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
%     elseif any(strcmpi(args.A4,'slide')) %{'4:3';'16:9'}
%         set(lghandle,'orientation','horizontal');
%         pos_ = get(lghandle,'position');
%         pos_(1) = 0.5-pos_(3)/2;
%         pos_(2) = 0.01;
%         set(lghandle,'position',pos_);
%         lgspot = '';
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
% -> not needed for fan charts, but we will use 'dhandle' to store the interval patch objects

% Handles are stored in 'diffs' field, renaming would cause compatibility issues (e.g. gobj_transform() needs to know the field names to work properly)
dhandle = struct();
dhandle.ints = int_han;

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
    
    ylims = get(ghandle,'Ylim');
    
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

    set(ghandle,'children',cat(1,phandle{:},emphandle{:},int_han{:},fill_handle{:}));
    
    set(ghandle,'ygrid','on','gridlinestyle','--');% : --
    set(ghandle,'xgrid','off');
    set(ghandle,'layer','top');
    
else

    set(ghandle,'xgrid','on');
    set(ghandle,'ygrid','on');
    set(ghandle,'gridlinestyle',':');% : --
    
    set(ghandle,'children',cat(1,phandle{:},emphandle{:},int_han{end:-1:1}));
    fill_handle = '';
end

hold off;

end %<eof>