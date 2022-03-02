function varargout = plot(this,varargin)
%
% Versatile plotter for the class tsobj() with a rich set of options 
% (run dynammo.options.plot() to print all available options to the command window)
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Output structure
% - optional output marked by []
% 
% 1] cellobj <used for the DB comparison>
% 
%  outstr.fig1.handle
%  outstr.fig1.sub1.handle
%  outstr.fig1.sub1.data
% [outstr.fig1.sub1.legend]
% [outstr.fig1.sub1.diffs]      ...diffs stores both axis/data handles, but is nested in sub1 structure
% [outstr.fig1.sub1.emphasized]
% [outstr.fig1.sub1.title]
% [outstr.fig1.sub1.highlighted]
% [outstr.fig1.suptitle] -> only the text field captured, but the sxes object can be accessed via 'parent' option
% 
% 2] structobj <used while plotting data with a frequency mismatch>
% 
% outstr.fig1.handle
% outstr.fig1.sub1.handle
% outstr.fig1.sub1.data
% [outstr.fig1.sub1.legend]
% [outstr.fig1.sub1.diffs]      ...diffs stores both axis/data handles, but is nested in sub1 structure
% [outstr.fig1.sub1.emphasized]
% [outstr.fig1.sub1.title]
% [outstr.fig1.sub1.highlighted]
% [outstr.fig1.suptitle] -> only the text field captured, but the sxes object can be accessed via 'parent' option
% 
% 3] tsobj/tscoll <standard plotter for tsobj class>
% 
% outstr.fig
% outstr.sub
% outstr.data
% outstr.legend  ...legend is mandatory output (always generated)
% [outstr.diffs]                ...diffs stores both axis/data handles
% [outstr.emphasized]
% [outstr.title]
% [outstr.highlighted]
% [outstr.suptitle] -> only the text field captured, but the axes object can be accessed via 'parent' option

%% Parse options

args = dynammo.options.plot(this,varargin{:});

%% Stack control

if ~isempty(args.aux_input) % Multigraph output / DB comparison mode to be launched
    this = args.aux_input; 
    args = args.aux_options;
end

%% Empty input
if isa(this,'tsobj') % struct/plot()+cell/plot() handling
    if isempty(this.values)
        disp(' -> empty time series on input');
        if nargout==1
            varargout{1} = '';
        end
        return
    end
end

%% Predefined plot() call
% -> styling and requested options, which can still be overloaded
if isa(this,'tsobj') && ~isempty(this.plotCallMode)
    gobj = plotCall(this,varargin{:});
    if nargout==1
        varargout{1} = gobj;
    else
        assignin('caller','gobj',gobj);
    end
    return
end

%% Initial arrangements
figstat = get(0,'DefaultFigureWindowStyle');

% Do not dock report plots (dimensions will be modified)
if strcmpi(args.visible,'off')
    args.docked = 0;
end
if args.docked
    set(0,'DefaultFigureWindowStyle','docked');
else
    set(0,'DefaultFigureWindowStyle','normal');
end

screen_dims = get(0,'ScreenSize');

%% Font design

% Retain default values
% fontAxes = get(0,'defaultAxesFontName');
% fontText = get(0,'defaultTextFontName');
% sizeAxes = get(0,'defaultAxesFontSize');
% sizeText = get(0,'defaultTextFontSize');

% Impose user values
% set(0,'defaultAxesFontName','Times');%'Helvetica');%'Times');
% set(0,'defaultTextFontName','Times');
% if any(strcmpi(args.A4,'slide'))
%     set(0,'defaultAxesFontSize',14);
%     set(0,'defaultTextFontSize',14);
% elseif strcmpi(args.A4,'doc1')
%     set(0,'defaultAxesFontSize',8);
%     set(0,'defaultTextFontSize',8);    
% else
%     set(0,'defaultAxesFontSize',11);%11 - report, 16 - presentation
%     set(0,'defaultTextFontSize',11);%11 - report, 16 - presentation    
% end
% -> now we use setFontName() and setFontSize()

% Scaling factor for potential super title 
args.yscale = dynammo.plot.yscale_size(args.A4);

%% Crossroads

% keyboard;

if iscell(this)
    outstr = dynammo.plot.db_comparison(this,args,screen_dims);
    
elseif isstruct(this)
    outstr = dynammo.plot.multiplot(this,args,screen_dims);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%    
else % tsobj/tscoll case
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     keyboard;
    
    nobjs = size(this.values,2);

    % Plot styling
    style = dynammo.plot.style(args,nobjs);
    
	% Name/techname switch (quick drawing)
    if strcmpi(args.caption,'techname')
        plotname = this.techname;
        empties = cellfun('isempty',plotname);
        plotname(empties) = this.name(empties);
    else
        plotname = this.name; % Official mode, no techname substitutions
    end

    % Initialize figure
    fig_height = 520;
    fig_width  = 960;
    
    fhandle = dynammo.plot.figInitialize(plotname{1},args, ...
        [(screen_dims(3)-fig_width)/2 min(350,screen_dims(4)-(fig_height+80)) fig_width fig_height]);
        
    % Triggers
    lg_trigger = 1;
    if ~isempty(args.title)
        caption_trigger = 1;
        plotname{1} = args.title;
        if isempty(args.legend)
            lg_trigger = 0;
        end
    else
        caption_trigger = 0;
    end
            
    % Plot the contents
    args.subplot = [1 1];
    args.plotnum = 1;
    if isa(this,'tsobj')
        switch lower(args.type)
            case 'line'
                [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = ...
                    dynammo.plot.line(this,args,lg_trigger,caption_trigger,plotname,args.diffs,style);                
            case 'bar'
                [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = ...
                    dynammo.plot.bar(this,args,lg_trigger,caption_trigger,plotname,style);
            case 'fan'
                [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = ...
                    dynammo.plot.fan(this,args,lg_trigger,caption_trigger,plotname,style); 
            case 'spaghetti'
                [ghandle,phandle,lghandle,dhandle,emphandle,thandle,fill_handle] = ...
                    dynammo.plot.spaghetti(this,args,lg_trigger,caption_trigger,plotname,style); 
        end
    else
        error_msg('Plotting','Struct object contains forbidden data type...',class(this));
    end
    
    % Super title
    if ~isempty(args.suptitle)
        if strcmpi(args.A4,'dont')
            suphandle = dynammo.plot.suptitle(fhandle,args.suptitle);
        else
            suphandle = dynammo.plot.suptitle_fast(fhandle,args.suptitle,args.A4);
        end
    end
    
    % Output
    outstr.fig    = fhandle;
    outstr.sub    = ghandle;
    outstr.data   = phandle;
    if lghandle~=0
        outstr.legend = lghandle;
    end
    if ~isempty(dhandle)
        outstr.diffs = dhandle;                
    end      
    if ~isempty(emphandle)
        outstr.emphasized = emphandle;                
    end
    if ~isempty(thandle)
        outstr.title = thandle;                
    end
    if ~isempty(fill_handle)
        outstr.highlighted = fill_handle;                
    end    
    if ~isempty(args.suptitle)
        outstr.suptitle = suphandle;
    end
    
end

%% Crop figure in presentation mode
% if strcmpi(args.A4,'slide')
%     dynammo.plot.crop(outstr);
% end

%% Restore 
set(0,'DefaultFigureWindowStyle',figstat);
% set(0,'defaultAxesFontName',fontAxes);
% set(0,'defaultTextFontName',fontText);
% set(0,'defaultAxesFontSize',sizeAxes);
% set(0,'defaultTextFontSize',sizeText);

%% Output
if nargout==1
    varargout{1} = outstr;
else
    assignin('caller','gobj',outstr);
end

end %<eof>