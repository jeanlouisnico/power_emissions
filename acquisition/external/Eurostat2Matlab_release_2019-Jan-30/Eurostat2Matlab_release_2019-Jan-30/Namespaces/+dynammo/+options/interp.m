function varargout = interp(varargin)
%
% Options handling for general tsobj/interp() function
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if nargin==(1)% options already processed in struct
    if nargout == 1
        varargout{1} = varargin{1};
    end
    return
end   

p = inputParser;
if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end

fcn(p,'type','clone',@(x) any(validatestring(x, ...
    {'clone','clone_forward','linear','nearest','next','previous','spline','pchip','cubic','v5cubic'})));% inheritance of interp1() methods

p.parse(varargin{:});%p.parse(this,varargin{:});
args = p.Results;

% keyboard;

%% Print options overview
if nargin==0 % overview of available options
    dynammo.options.args_overview(definition(args));
    return
end

varargout{1} = args;

%% Support functions

    function res = definition(args)
        
    to_print = cell(0,0);
    to_print{1,1} = 'OPTION';
    to_print{1,2} = 'DEFAULT VALUE';
    to_print{1,3} = 'COMMENT';
    to_print{2,1} = '#=line#';

    to_print(end+1,:) = {'type:',args.type,'... selection of specific interpolation technique'};
    to_print(end+1,:) = {'','','...    ''clone'' -> in a first stage, all NaN values get overwritten'};
    to_print(end+1,:) = {'','','...               by the last known value (for a specific segment of NaNs);'};
    to_print(end+1,:) = {'','','...               in a second stage, the reverse process fills all NaNs'};
    to_print(end+1,:) = {'','','...               at the beginning of the sample by the first known value'};
    to_print(end+1,:) = {'','','...    ''clone_forward'' -> similar to stage #1 of "clone" option'};
    to_print(end+1,:) = {'','','...    ''linear''/''spline''/... -> standard Matlab''s interp1() interpolation methods accepted'};

    res.to_print = to_print;
    res.opt_call = 'interp(tsobj(),options)';
    
    end %<definition>

end %<eof>