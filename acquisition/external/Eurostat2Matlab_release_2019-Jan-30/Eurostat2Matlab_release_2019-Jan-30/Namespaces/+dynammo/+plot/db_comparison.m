function outstr = db_comparison(this,args,screen_dims)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% -> this branch is called when plot(db1 + db2) is called
% -> struct/plus() returns a cell object of tsobj() only, therefore direct cell input to this function is not advised...
% -> tscoll are filtered out already,
% -> missing data treatment already taken care of

%% Plot type
if ~strcmpi(args.type,'line')
    error_msg('Plot type','Comparison of multiple DBs requires the input plot type set to ''line'':',args.type);
end

%% Plot styling

nDBs = size(this,1);
fields = fieldnames(this{1});
nsubplots = length(fields);

style = dynammo.plot.style(args,nDBs);

%% One huge figure of all subplots

if all(args.subplot==0) % Automatic selection
    
    % Subplot layout dimensions
    args = dynammo.plot.subplot_layout(args,nsubplots);
    
    % X ticks amount
    args.maxticks = max(1,12/args.subplot(2));
    
    % Initialize figure
    shelf = 100;
    
    outstr.fig1.handle = ...
        dynammo.plot.figInitialize('DB comparison',args,[shelf shelf screen_dims(3)-2*shelf screen_dims(4)-2*shelf]);
    
    % Plot the contents
    for isubplot = 1:nsubplots
        args.plotnum = isubplot;
        
        % Concatenation
        plotobj = series_concatenation(this,nDBs,fields,isubplot);
        
        % Plotter fcn
        if isa(plotobj,'tsobj')
            plotname = dynammo.plot.plotnames_tsobj(plotobj,args.caption);
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.line(plotobj,args, ...
                isubplot==1,1,plotname, ...%lg_trigger,caption_trigger,plotname
                args.diffs,style);
            
        elseif isstruct(plotobj)
            plotname = dynammo.plot.plotnames_struct(plotobj,args.caption);
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.freq_mismatch(plotobj,args, ...
                isubplot==1,1,plotname, ...%lg_trigger,caption_trigger,plotname
                style); %diffs_trigger not allowed
            
        else
            error_msg('Plotting','Struct object contains forbidden data type...',class(plotobj));
        end
        
        % Output
        substr = sprintf('sub%d',isubplot);        
        outstr.fig1.(substr).handle = ghandle;
        outstr.fig1.(substr).data   = phandle;
        if lghandle~=0
            outstr.fig1.(substr).legend = lghandle;
        end
        if ~isempty(dhandle)
            outstr.fig1.(substr).diffs = dhandle;
        end
        if ~isempty(emphandle)
            outstr.fig1.(substr).emphasized = emphandle;
        end
        if ~isempty(thandle)
            outstr.fig1.(substr).title = thandle;
        end
        if ~isempty(fill_handle)
            outstr.fig1.(substr).highlighted = fill_handle;
        end
    end
    
    % Super title
    if ~isempty(args.suptitle)
        if strcmpi(args.A4,'dont')
            suphandle = dynammo.plot.suptitle(outstr.fig1.handle,args.suptitle);
        else
            suphandle = dynammo.plot.suptitle_fast(outstr.fig1.handle,args.suptitle,args.A4);
        end
        outstr.fig1.suptitle = suphandle;
    end
    
    return
    
end

%% Manual subplot size selected

[plots_per_page,full_pages,remainder] = dynammo.plot.subplot_design(args,nsubplots);

shelf = 200;
varcount = 0;
for ifig = 1:full_pages

    % Actual varnames
    nowfields = fields(varcount+1:varcount+plots_per_page);

    % Initialize figure
    if strcmpi(args.caption,'name')
        figname = this{1}.(nowfields{1}).name{1};
    else
        figname = this{1}.(nowfields{1}).techname{1};
    end
    
    figstr = sprintf('fig%d',ifig);
    outstr.(figstr).handle = ...
        dynammo.plot.figInitialize(figname,args,[shelf shelf screen_dims(3)-2*shelf screen_dims(4)-2*shelf]);

    % Plot the contents
    for isubplot = 1:plots_per_page
        args.plotnum = isubplot;

        % Concatenation
        plotobj = series_concatenation(this,nDBs,nowfields,isubplot);

        % Plotter fcn
        if isa(plotobj,'tsobj')
            plotname = dynammo.plot.plotnames_tsobj(plotobj,args.caption);
            
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.line(plotobj,args, ...
                isubplot==1,1,plotname, ...%lg_trigger,caption_trigger,plotname
                args.diffs,style);
        elseif isstruct(plotobj)
            plotname = dynammo.plot.plotnames_struct(plotobj,args.caption);
            
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.freq_mismatch(plotobj,args, ...
                isubplot==1,1,plotname, ...%lg_trigger,caption_trigger,plotname
                style);% diffs_trigger not allowed
        else
            error_msg('Plotting','Struct object contains forbidden data type...',class(plotobj));
        end

        % Output
        substr = sprintf('sub%d',isubplot);
        outstr.(figstr).(substr).handle = ghandle;
        outstr.(figstr).(substr).data   = phandle;
        if lghandle~=0
            outstr.(figstr).(substr).legend = lghandle;
        end
        if ~isempty(dhandle)
            outstr.(figstr).(substr).diffs = dhandle;
        end
        if ~isempty(emphandle)
            outstr.(figstr).(substr).emphasized = emphandle;
        end
        if ~isempty(thandle)
            outstr.(figstr).(substr).title = thandle;
        end
        if ~isempty(fill_handle)
            outstr.(figstr).(substr).highlighted = fill_handle;
        end
    end

    % Super title
    if ~isempty(args.suptitle)
        if ifig == 1
            suptitle_str = args.suptitle;
        else
            suptitle_str = sprintf('%s (cont''d)',args.suptitle);
        end
        if strcmpi(args.A4,'dont')
            suphandle = dynammo.plot.suptitle(outstr.(figstr).handle,suptitle_str);
        else
            suphandle = dynammo.plot.suptitle_fast(outstr.(figstr).handle,suptitle_str,args.A4);
        end
        outstr.(figstr).suptitle = suphandle;
    end

    varcount = inc(varcount,plots_per_page);

end

%% Last incomplete figure

if remainder > 0

    % Actual varnames
    nowfields = fields(varcount+1:end);

    % Initialize figure
    if strcmpi(args.caption,'name')
        figname = this{1}.(nowfields{1}).name{1};
    else
        figname = this{1}.(nowfields{1}).techname{1};
    end

    figstr = sprintf('fig%d',full_pages+1);
    outstr.(figstr).handle = ...
        dynammo.plot.figInitialize(figname,args,[shelf shelf screen_dims(3)-2*shelf screen_dims(4)-2*shelf]);

    % Plot the remaining contents
    for isubplot = 1:length(nowfields)
        args.plotnum = isubplot;

        % Concatenation
        plotobj = series_concatenation(this,nDBs,nowfields,isubplot);

        % Plotter fcn
        if isa(plotobj,'tsobj')
            plotname = dynammo.plot.plotnames_tsobj(plotobj,args.caption);
            
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.line(plotobj,args, ...
                isubplot==1,1,plotname, ...%lg_trigger,caption_trigger,plotname
                args.diffs,style);
        elseif isstruct(plotobj)
            plotname = dynammo.plot.plotnames_struct(plotobj,args.caption);
            
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.freq_mismatch(plotobj,args, ...
                isubplot==1,1,plotname, ...%lg_trigger,caption_trigger,plotname
                style); % diffs_trigger not allowed
        else
            error_msg('Plotting','Struct object contains forbidden data type...',class(plotobj));
        end

        % Output
        substr = sprintf('sub%d',isubplot);
        outstr.(figstr).(substr).handle = ghandle;
        outstr.(figstr).(substr).data   = phandle;
        if lghandle~=0
            outstr.(figstr).(substr).legend = lghandle;
        end
        if ~isempty(dhandle)
            outstr.(figstr).(substr).diffs = dhandle;
        end
        if ~isempty(emphandle)
            outstr.(figstr).(substr).emphasized = emphandle;
        end
        if ~isempty(thandle)
            outstr.(figstr).(substr).title = thandle;
        end
        if ~isempty(fill_handle)
            outstr.(figstr).(substr).highlighted = fill_handle;
        end
    end

    % Super title
    if ~isempty(args.suptitle)
        if full_pages == 0
            suptitle_str = args.suptitle;
        else
            suptitle_str = sprintf('%s (cont''d)',args.suptitle);
        end
        if strcmpi(args.A4,'dont')
            suphandle = dynammo.plot.suptitle(outstr.(figstr).handle,suptitle_str);
        else
            suphandle = dynammo.plot.suptitle_fast(outstr.(figstr).handle,suptitle_str,args.A4);
        end
        outstr.(figstr).suptitle = suphandle;
    end

end

%% Nested fcns

    function plotobj = series_concatenation(this,nDBs,nowfields,isubplot)

        plotobj = tsobj();
        freqs_used = {};
        for idb = 1:nDBs
            if isa(plotobj,'tsobj')
                plotobj = [plotobj this{idb}.(nowfields{isubplot})]; %#ok<AGROW>
            else %struct YY QQ MM DD ...though mixed frequencies unlikely to be present
                freq_now_ = this{idb}.(nowfields{isubplot}).frequency;
                if any(strcmp(freq_now_,freqs_used))
                    plotobj.([freq_now_ freq_now_]) = [plotobj.([freq_now_ freq_now_]) this{idb}.(nowfields{isubplot})];  
                else
                    plotobj.([freq_now_ freq_now_]) = this{idb}.(nowfields{isubplot});
                    freqs_used = [freqs_used;freq_now_]; %#ok<AGROW>
                end
            end
        end

    end %<series_concatenation>

end %<eof>