function [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = bar(this,args,lg_trigger,caption_trigger,plotname,style)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Contribution bar plot %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

%     keyboard;

%% Range resolution
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

%% Vertical limits
values = this.values;
maxvalues = max(this.values,0);% result NaN free
minvalues = min(this.values,0);% result NaN free

max_vect = sum(maxvalues,2);
min_vect = sum(minvalues,2);

max_value = max(max_vect);
min_value = min(min_vect);

if abs(min_value-max_value) > 1e-10
    yrange = max_value - min_value;
    ymin = min_value - args.margin_bottom*yrange;
    ymax = max_value + args.margin_top*yrange;
elseif ~isnan(min_value) && ~isnan(max_value)
    ymin = min_value - 1;
    ymax = max_value + 1;
else
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
    tmp_ = subplot(args.subplot(1),args.subplot(2),args.plotnum);%,'align');
    pos_ = get(tmp_,'position');
    delete(tmp_);
    ghandle = axes('position',pos_);

end

% Space for suptitle
%     pos = get(ghandle,'position');
%     pos(2) = pos(2)*args.yscale;
%     pos(4) = pos(4)*args.yscale;
%     set(ghandle,'position',pos);

set(ghandle,'tag','bar');
phandle = cell(2,1);
hold on;
box on;

%% Plot step (bar)

emphandle = cell(1,1);
emph_factor = max(args.emphasize,1);

% Bar contributions
phandle{1} = bar(tind,maxvalues, ...
    'stacked','EdgeColor','none');%[0 0 0]);
phandle{2} = bar(tind,minvalues, ...
    'stacked','EdgeColor','none');%[0 0 0]);

% keyboard;
% Bar styling
[~,objs] = size(this.values);
for ii = 1:objs
    set(phandle{1}(ii),style.cell{ii,:});
    set(phandle{2}(ii),style.cell{ii,:});
end

% Aggregation line
if objs > 1
    emphandle{1} = plot(tind,sum(values,2), ...
        'Color',[1 1 1], ...
        'LineWidth',2+emph_factor);
    phandle{3} = plot(tind,sum(values,2), ...
        'Color',[0 0 0], ...
        'LineWidth',2);
else
    emphandle = '';
    phandle{3} = plot(tind,sum(values,2), ...
        'Color',[0 0 0], ...
        'LineWidth',2);
    set(phandle{3},'Visible','off');
end

% Shuffle the handles to +/- bar contributions
phandle_half1 = phandle{1}(:);
phandle_half2 = phandle{2}(:);

% Limits
%data_axis = gca;
set(ghandle,'Ylim',[ymin ymax]);
set(ghandle,'xlim',[min_x_limit max_x_limit]);

% X ticks and labels
[xticks,xlabels] = labels(this,args.maxticks);
set(ghandle,'xtick',xticks);
set(ghandle,'xticklabel',xlabels);

plotname = strrep(plotname,'_','\_');

% Caption
if caption_trigger
    thandle = title(plotname{1},'FontWeight','normal');
else
    thandle = cell(0,0);
end

%% Legend
if lg_trigger
    
    if ~dynammo.compatibility.M2016a
        
        if ~isempty(args.legend)
            [lghandle,entries] = legend(phandle_half1,strrep(args.legend,'_','\_'));
        else
            [lghandle,entries] = legend(phandle_half1,plotname);
        end
        
        % Data envelope (for evalin())
        convHull = [this.tind min_vect max_vect]; %#ok<NASGU>
        
        % Click legend property
        if strcmpi(args.visible,'on')
            for ient = 1:length(phandle_half1)
                set(entries(ient), 'HitTest', 'on', 'ButtonDownFcn',...
                    @(varargin) legendClick(ient,entries,[],phandle_half1,phandle_half2), ...
                    'UserData', true);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%
    else % M2016a+
        %%%%%%%%%%%%%%%%%%%%%
        
        if ~isempty(args.legend)
            lghandle = legend(phandle_half1,strrep(args.legend,'_','\_'));
        else
            lghandle = legend(phandle_half1,plotname);
        end
        
        % Do not update legend when new objects are generated (e.g. zebra)
        if dynammo.compatibility.isAutoUpdate
           set(lghandle,'autoupdate','off'); 
        end
        
        lghandle.UserData.handles = {phandle_half1;phandle_half2};
        lghandle.UserData.lstrings = lghandle.String(:);%lstrings(:);
        %lghandle.UserData.LabelHandles = entries;
        lghandle.UserData.PlotHandle = ghandle;% Note that this field is not linked as a listener when the value changes
        % -> gobj_generate() uses it, but it should work
        %lghandle.UserData.LegendPosition -> better to take it directly from legend handle (it is connected to listeners, when units/pos change)
        
        % Data envelope (convex hull)
        % -> bar values must be summed!
        lghandle.UserData.convHull = [this.tind min_vect max_vect];% NaNs treated inside legend_best2
        
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
        
    else
        legend_best2(ghandle,lghandle);
        
        % North/south injection changes Y limits, but irrelevant in bar graph
        
    end
    
else
    lghandle = 0;
    
end

% Differences between time series <bars>
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
%     keyboard;
    ylims = get(ghandle,'Ylim');
    ymin = ylims(1)-1e3;
    ymax = ylims(2)+1e3;
    
    for ih = 1:nhigh
        [highlight_per_from,highlight_per_to] = dynammo.plot.get_highlight_range(freq,args,max_x_limit,ih,isZebra);
        fill_handle{ih} = patch([highlight_per_from highlight_per_to highlight_per_to highlight_per_from], ...
            [ymin ymin ymax ymax],0.8*[1 1 1]);% 3D trick: [-1 -1 -1 -1],
        set(fill_handle{ih},'linestyle','none');
        if dynammo.compatibility.newGraphics
            set(fill_handle{ih},'FaceAlpha',0.6);
        end
        
    end
    
    if objs > 1
        set(ghandle,'children',cat(1,phandle{3},emphandle{1},phandle_half1,phandle_half2,fill_handle{:}));
    else
        set(ghandle,'children',cat(1,phandle{3},phandle_half1,phandle_half2,fill_handle{:}));
    end
    
else
    if objs > 1
        set(ghandle,'children',cat(1,phandle{3},emphandle{1},phandle_half1,phandle_half2));
    else
        set(ghandle,'children',cat(1,phandle{3},phandle_half1,phandle_half2));
    end
    fill_handle = '';
    
end

set(ghandle,'ygrid','on');
set(ghandle,'xgrid','off');
if dynammo.compatibility.newGraphics
    set(ghandle,'gridlinestyle','--');
else
    set(ghandle,'gridlinestyle',':');
end
set(ghandle,'layer','top');
hold off;

end %<eof>