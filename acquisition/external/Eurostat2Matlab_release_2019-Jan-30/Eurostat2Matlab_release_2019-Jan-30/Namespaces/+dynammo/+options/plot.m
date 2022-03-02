function varargout = plot(inputobj,varargin)
%
% Options handling for tsobj/plot() function
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input parser
p = inputParser;

% Stack control
st = dbstack();
nst = size(st,1)>1;
if nst
   addRequired(p,'inputobj');%, @isstruct || @(x) isa(x,'tsobj') || @iscell);
end

if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end
    
fcn(p,'range',Inf);
fcn(p,'legend','',@(x) iscell(x) || ischar(x));
fcn(p,'margin_top',0.05,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'margin_bottom',0.05,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'margin_inset',0.05,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'highlight','');%,@(x) all(tsobj(x,1).values));
fcn(p,'docked',0);
fcn(p,'caption','techname',@(x) any(validatestring(x,{'techname','name'})));
fcn(p,'title','',@ischar);
fcn(p,'suptitle','',@ischar);
fcn(p,'maxticks',0,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'subplot',[0 0],@(x) isa(x,'double') && length(x)==2);
fcn(p,'diffs',0,@(x) any(x==[0;1;2]));
fcn(p,'style',0);%,@(x) (isscalar(x) && isa(x,'double')) || isstruct(x));
fcn(p,'type','line',@(x) any(validatestring(x,{'line','bar','fan','spaghetti'})));
fcn(p,'emphasize',0,@(x) isscalar(x) && isa(x,'double'));
%fcn(p,'figname','',@ischar); %obsolete, now determined automatically
%fcn(p,'dbnames','',@iscell); % DB comparison names taken from 'legend'
fcn(p,'alpha',0.7,@(x) all(x<=1 && x>=0));
fcn(p,'scaling',1,@(x) length(x)<=2);
fcn(p,'reuse',0,@(x) any(x==[0;1]));

% Reporting options
fcn(p,'visible','on',@(x) any(validatestring(x,{'on','off'})));
fcn(p,'A4','dont',@(x) any(validatestring(x,dynammo.plot.A4types())));
%fcn(p,'clone',0,@(x) any(x==[0;1]));% figcombine() support

% Fan chart options
fcn(p,'midcast',1,@(x) floor(x)==x);

% Internal options used for stack control
fcn(p,'aux_input','');
fcn(p,'aux_options',struct());

fcn(p,'debug',0,@(x) any(x==[0;1]));

if nst
    p.parse(inputobj,varargin{:});% Cannot run in debug mode!
else
    p.parse(varargin{:});
end
args = p.Results;

%% Print options overview
if nargin==0 && nargout==0 % overview of available options
    dynammo.options.args_overview(definition(args));
    return
end

%% Input validation

% if iscell(args.style)
%     if isstruct(inputobj)
%        error_msg('Consistency error',['Option "style" of Matlab type cell is incompatible ' ...
%                                   'with given input object. In this case "style" must be numeric. ' ...
%                                   'This option in cell format is applicable only while ' ...
%                                   'plotting simple tsobj(), i.e. ' ...
%                                   'one subplot in figure.']); 
%     end
% %     if strcmp(args.type,'bar')
% %        error_msg('Consistency error',['Option "style" of Matlab type cell is incompatible ' ...
% %                                   'with given input object type "bar". Either switch to "line" ' ...
% %                                   'type, or use a predefined "style" (numeric reference, not as cell obj.)...']); 
% %     end
% 
% end

% Scaling figure dimensions
if length(args.scaling)==1
    args.scaling = [args.scaling args.scaling];
end

if strcmpi(args.type,'fan')
    args = dynammo.options.validate.fanChart(inputobj,args);
end

%% Output

if nargout>0
    varargout{1} = args;
end

%% Support functions

    function res = definition(args)
        
    to_print = cell(0,0);
    to_print{1,1} = 'OPTION';
    to_print{1,2} = 'DEFAULT VALUE';
    to_print{1,3} = 'COMMENT';
    to_print{2,1} = '#=line#';

    to_print(end+1,:) = {'range:',args.range,'... time span of the plotted data, entire time series are plotted by default'};
    to_print(end+1,:) = {'','',              '    INPUT FORMAT: -> ''2010-01-01:2015-12-31'' (daily data)'};
    to_print(end+1,:) = {'','',              '                  -> ''2010m1:2015m10'' (monthly data)'};
    to_print(end+1,:) = {'','',              '                  -> ''2010q2:2015q4''  (quarterly data)'};
    to_print(end+1,:) = {'','',              '                  -> ''2010:2015''      (yearly data)'};
    to_print(end+1,:) = {'','',              '    SHORT RANGE NOTATION: ''2010:2015'' can also be used to plot all data between 2010 and 2015'};
    to_print(end+1,:) = {'','',              '                                        regardless of the data frequency (D, M, Q, Y)'};
    to_print(end+1,:) = {'','',              '                          ''2010-01''         all Jan. data (applied to data with daily frequency)'};
    to_print(end+1,:) = {'','',              '                          ''2010-01:2010-03'' Jan.-Mar. data (applied to data with daily frequency)'};
    
    to_print(end+1,:) = {'legend:','''''','... cell of legend entries to overrule the default automatic legend generation'};
    to_print(end+1,:) = {'margin_top:',args.margin_top,'... height of blank space above the plotted data (0.05~5% of the data range)'};
    to_print(end+1,:) = {'margin_bottom:',args.margin_bottom,'... height of blank space below the plotted data (0.05~5% of the data range)'};
    to_print(end+1,:) = {'margin_inset:',args.margin_inset,'... width of blank space before and after the plotted data (0.05~5% of the time range)'};
    to_print(end+1,:) = {'highlight:','''''','... shaded region behind plotted objects (the input is expected in range format)'};
    to_print(end+1,:) = {'','',                      '...    examples: ''2010q1:2011q4'' -> specific range gets highlighted'};
    to_print(end+1,:) = {'','',                      '...              ''2010q1'' -> only the start period specified'};
    to_print(end+1,:) = {'','',                      '...             {''2010q1:2010q4'',''2012q1''} -> entire year 2010 and from 2012 onwards get highlighted'};
    to_print(end+1,:) = {'docked:',args.docked,'... opens up a new figure in "docked" mode'};
    to_print(end+1,:) = {'caption:',args.caption,'... primary source of legend entries (default behavior for automatic legend generation)'};
    to_print(end+1,:) = {'','',                  '      ''name''     -> legend entries are inherited from the tsobj() name property'};
    to_print(end+1,:) = {'','',                  '      ''techname'' -> legend entries are inherited from the tsobj() techname property'};
    to_print(end+1,:) = {'title:','''''','... subplot title (to overrule the automatically generated title)'};
    to_print(end+1,:) = {'suptitle:','''''','... super title above all subplot areas'};
    to_print(end+1,:) = {'maxticks:',args.maxticks,'... # of maximum ticks on the horizontal axis'};
    to_print(end+1,:) = {'subplot:',args.subplot,'... [x y] matrix of the subplot design (determined automatically if [0 0])'};
    to_print(end+1,:) = {'diffs:',args.diffs,'... (0/1/2 switch) difference bars between plotted lines (applies to 2-line plots only)'};
    to_print(end+1,:) = {'style:',args.style,'... scalar indicating the plot style number - specification of line colors, markers type, etc.'};
    to_print(end+1,:) = {'','',              '       (defined in mystyle())'};
    to_print(end+1,:) = {'','',              '       !!! visualization_tutorial() shows another way of passing the plot style using a user-defined cell object with the styling properties'};
    to_print(end+1,:) = {'type:',args.type,'... graph type of the output figure'};
    to_print(end+1,:) = {'','',            '       ''line'' -> standard line plot'};
    to_print(end+1,:) = {'','',            '       ''bar''  -> contribution bars with an aggregation line'};
    to_print(end+1,:) = {'','',            '       ''fan''       -> fan chart [still to be implemented]'};
    to_print(end+1,:) = {'','',            '       ''spaghetti'' -> [still to be implemented]'};
    to_print(end+1,:) = {'emphasize:',args.emphasize,'... line width; Marker pen can be used to emphasize all plotted line objects'};
    to_print(end+1,:) = {'','',                      '       HINT: if only a subset of lines should be highlighted, you can generate'};
    to_print(end+1,:) = {'','',                      '             two separate figures (one with emphasize>0) and put the result'};
    to_print(end+1,:) = {'','',                      '             together using figoverlay() function'};
    to_print(end+1,:) = {'alpha:',args.alpha,'... [0,1] alpha channel controlling transparency of plotted objects'};
    to_print(end+1,:) = {'','',              '           (available in M2014b+)'};
    to_print(end+1,:) = {'scaling:',args.scaling,'... figure dimensions are controlled mainly by ''A4'' option, figure width/height'};
    to_print(end+1,:) = {'','',                  '           can be fine tuned by ''scaling'', [1 1.2] will increase only the height by 20%, leaving width untouched'};
    to_print(end+1,:) = {'reuse:',args.reuse,'... 0/1 switch; figure window can be generated from scratch, or we can re-use previously generated window to speed things up'};
    to_print(end+1,:) = {'debug:',args.reuse,'... 0/1 switch; Makes figure constantly visible using the always-on-top JAVA feature'};
    
    to_print{end+1,1} = '#>>> FAN CHART SUPPORT <<<#';% Category name
    to_print(end+1,:) = {'midcast:',args.midcast,'... order of the main forecast line within the input collection of time series'};
    
    to_print{end+1,1} = '#>>> REPORTING <<<#';% Category name
    to_print(end+1,:) = {'visible:',args.visible,'... ''on''/''off'' switch; Figures can be made invisible to speed up the generating process'};
    to_print(end+1,:) = {'A4:',args.A4,'... Paper orientation setting'};
    to_print(end+1,:) = {'','',       ['       ''' strjoin2(dynammo.plot.A4types(),'''|''') '''']};%''dont''|''portrait''|''landscape''|''slide'''};%''4:3''|''16:9'''
    to_print(end+1,:) = {'','',        '         -> the default ''dont'' settings should be changed only in'};
    to_print(end+1,:) = {'','',        '            final figures that are to be exported to PDF, paper orientation'};
    to_print(end+1,:) = {'','',        '            need not be set for all byproduct-figures used to generate final figures'};
    to_print(end+1,:) = {'','',        '            using figoverlay() and figcombine() functions'};
   %to_print(end+1,:) = {'','',        '         -> ''4:3'', or ''16:9'' are intended for use in presentations'};
    
    res.to_print = to_print;
    res.opt_call = 'plot(tsobj(),options)';
    
    end %<definition>
    
end %<eof>