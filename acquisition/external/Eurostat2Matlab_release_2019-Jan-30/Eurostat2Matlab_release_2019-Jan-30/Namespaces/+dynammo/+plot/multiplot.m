function outstr = multiplot(this,args,screen_dims)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

fields = fieldnames(this);
nsubplots = length(fields);

%% Plot styling

if strcmpi(fields{1},'single_plot_multiline')
    % It appears we have mixed frequencies on input (with .YY, .QQ, .MM, .DD fields)
    % -> we need a single coloring for each input line across all input frequencies
    nobjs = structfun(@(x) size(x,2),this.single_plot_multiline);
    nobjs = cumsum(nobjs);
    style = dynammo.plot.style(args,nobjs(end));
    
else % Multiplots: line formatting stays the same across all subplots (entered as .field=tsobj())
    %             we may, however, have tscoll(), or frequency mismatch inside some fields
    
    nobjs = 0;
    
    % Frequency mismatch
    % Input: this.a.YY = tscoll()
    %        this.a.QQ = tsobj()
    iss = structfun(@isstruct,this);
    if any(iss)
        strfields = fields(iss);
        this_freqmism = this * strfields;
        for istr=1:length(strfields)
            sizes = structfun(@(x) size(x,2),this_freqmism.(strfields{istr}));
            sizes = cumsum(sizes);
            nobjs = max([nobjs;sizes(end)],[],1);
        end
    end
    
    % Standard time series (single line + tscoll())
    istsobj = structfun(@(x) isa(x,'tsobj'),this);
    if any(istsobj)
        this_tsobj = this * fields(istsobj);
        sizes = structfun(@(x) size(x,2),this_tsobj);
        nobjs = max([nobjs;sizes(:)],[],1);
    end
    
    style = dynammo.plot.style(args,nobjs);
    
end

%% Automatic selection 
% -> one huge figure of all subplots

if all(args.subplot==0) 
    
    % Subplot layout dimensions
    args = dynammo.plot.subplot_layout(args,nsubplots);
    %args.subplot = dynammo.plot.subplot_layout(nsubplots);
    
    % Initialize figure
    shelf = 100;
    
    outstr.fig1.handle = ...
        dynammo.plot.figInitialize('DB plot',args,[shelf shelf screen_dims(3)-2*shelf screen_dims(4)-2*shelf]);
    
    % Plot the contents
    for isubplot = 1:nsubplots
        args.plotnum = isubplot;
        now_ = this.(fields{isubplot});
        
        % Plotter fcn
        if isa(now_,'tsobj')
            nlines = size(now_.values,2);
            plotname = dynammo.plot.plotnames_tsobj(now_,args.caption);
            
            switch lower(args.type)
                case 'line'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.line(now_,args, ...
                        nlines>1,nlines==1,plotname, ...%lg_trigger,caption_trigger,plotname
                        args.diffs,style);
                case 'bar'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.bar(now_,args, ...
                        nlines>1,nlines==1,plotname,style);
                case 'fan'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.fan(now_,args, ...
                        nlines>1,nlines==1,plotname, ...
                        style); 
                case 'spaghetti'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.spaghetti(now_,args, ...
                        nlines>1,nlines==1,plotname, ...
                        style); 
            end
            
        elseif isstruct(now_)
            plotname = dynammo.plot.plotnames_struct(now_,args.caption);
            
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.freq_mismatch(now_,args, ...
                1,0,plotname, ...%lg_trigger,caption_trigger,plotname
                style);% diffs_trigger not allowed
        else
            error_msg('Plotting','Struct object contains forbidden data type...',class(now_));
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

%% User-supplied subplot design
    
[plots_per_page,full_pages,remainder] = dynammo.plot.subplot_design(args,nsubplots);

shelf = 200;
varcount = 0;
for ifig = 1:full_pages

    nowstr = this * fields(varcount+1:varcount+plots_per_page);
    nowfields = fieldnames(nowstr);

    % Initialize figure
    if strcmpi(args.caption,'name')
        figname = nowstr.(nowfields{1}).name{1};
    else
        figname = nowstr.(nowfields{1}).techname{1};
    end
    
    figstr = sprintf('fig%d',ifig);
    outstr.(figstr).handle = ...
        dynammo.plot.figInitialize(figname,args,[shelf shelf screen_dims(3)-2*shelf screen_dims(4)-2*shelf]);

    % Plot the contents
    for isubplot = 1:plots_per_page
        args.plotnum = isubplot;
        now_ = nowstr.(nowfields{isubplot});

        % Plotter fcn
        if isa(now_,'tsobj')
            nlines = size(now_.values,2);
            plotname = dynammo.plot.plotnames_tsobj(now_,args.caption);
            
            switch lower(args.type)
                case 'line'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.line(now_,args, ...
                        nlines>1,nlines==1,plotname, ...%lg_trigger,caption_trigger,plotname
                        args.diffs,style);
                case 'bar'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.bar(now_,args, ...
                        nlines>1,nlines==1,plotname,style);
                case 'fan'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.fan(now_,args, ...
                        nlines>1,nlines==1,plotname, ...
                        style); 
                case 'spaghetti'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.spaghetti(now_,args, ...
                        nlines>1,nlines==1,plotname, ...
                        style); 
            end
            
            
        elseif isstruct(now_)
            plotname = dynammo.plot.plotnames_struct(now_,args.caption);
            
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.freq_mismatch(now_,args, ...
                1,0,plotname, ...%lg_trigger,caption_trigger,plotname
                style);% diffs_trigger not allowed
        else
            error_msg('Plotting','Struct object contains forbidden data type...',class(now_));
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
            suptitle_str = [args.suptitle ' (cont''d)'];
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

% Incomplete figure at the end
if remainder > 0

    nowstr = this * fields(varcount+1:end);
    nowfields = fieldnames(nowstr);

    % Initialize figure
    if strcmpi(args.caption,'name')
        figname = nowstr.(nowfields{1}).name{1};
    else
        figname = nowstr.(nowfields{1}).techname{1};
    end
    
    figstr = sprintf('fig%d',full_pages+1);
    
    outstr.(figstr).handle = ...
        dynammo.plot.figInitialize(figname,args,[shelf shelf screen_dims(3)-2*shelf screen_dims(4)-2*shelf]);

    % Plot the remaining contents
    for isubplot = 1:length(nowfields)
        args.plotnum = isubplot;
        now_ = nowstr.(nowfields{isubplot});

        % Plotter fcn
        if isa(now_,'tsobj')
            nlines = size(now_.values,2);
            plotname = dynammo.plot.plotnames_tsobj(now_,args.caption);
                    
            switch lower(args.type)
                case 'line'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.line(now_,args, ...
                            nlines>1,nlines==1,plotname, ...%lg_trigger,caption_trigger,plotname
                            args.diffs,style);
                case 'bar'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.bar(now_,args, ...
                            nlines>1,nlines==1,plotname,style);
                case 'fan'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.fan(now_,args, ...
                        nlines>1,nlines==1,plotname, ...
                        style); 
                case 'spaghetti'
                    [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.spaghetti(now_,args, ...
                        nlines>1,nlines==1,plotname, ...
                        style); 
            end
            
        elseif isstruct(now_)
            plotname = dynammo.plot.plotnames_struct(now_,args.caption);
            
            [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = dynammo.plot.freq_mismatch(now_,args, ...
                1,0,plotname, ...%lg_trigger,caption_trigger,plotname
                style);% diffs_trigger now allowed
        else
            error_msg('Plotting','Struct object contains forbidden data type...',class(now_));
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
            %suptitle_str = [args.suptitle ' (cont''d)'];
            suptitle_str = sprintf('%s (cont''d)',args.suptitle);
        end
        if strcmpi(args.A4,'dont')
            suphandle = dynammo.plot.suptitle( ...
                outstr.(figstr).handle,suptitle_str);
        else
            suphandle = dynammo.plot.suptitle_fast( ...
                outstr.(figstr).handle,suptitle_str,args.A4);
        end
        outstr.(figstr).suptitle = suphandle;
    end

end %<remainder>

end %<eof>