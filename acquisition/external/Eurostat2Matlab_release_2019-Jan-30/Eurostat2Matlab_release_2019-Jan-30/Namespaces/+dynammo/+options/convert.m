function varargout = convert(varargin)
%
% Options handling for tsobj/convert() function
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% if nargin==(1+1)% options already processed in struct
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

fcn(p,'freq','Q',@(x) any(validatestring(x,{'M','Q','Y'})));%case insensitive
fcn(p,'aggregation','average', ...M->Y
                @(x) any(validatestring(x,{'average','lastobs','lastavailable','sum'})));
fcn(p,'interpolation','clone', ...the opposite of aggregation (Y->M)
                @(x) any(validatestring(x,{'clone','clone_flow','smooth','smooth_flow','linear'})));
fcn(p,'nan_as_zero',0, @(x) any(x==[0;1])); 

p.parse(varargin{:});%p.parse(this,varargin{:});
args = p.Results;

% keyboard;

%% Print options overview
if nargin==0 && nargout==0 % overview of available options
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

    to_print(end+1,:) = {'freq:',args.freq,'... data output frequency (''Y''|''Q''|''M''), conversion to daily data is not supported'};
    to_print(end+1,:) = {'aggregation:',args.aggregation,'... method for conversion of high frequency data into lower frequency'};
    to_print(end+1,:) = {'','',                          '...   ''average'' -> average value per each outpur period returned'};
    to_print(end+1,:) = {'','',                          '...   ''lastobs'' -> very last observation taken (can be NaN)'};
    to_print(end+1,:) = {'','',                          '...   ''lastavailable'' -> last non-NaN observation'};
    to_print(end+1,:) = {'','',                          '...   ''sum'' -> sum of all values (all must be non-NaN,'};
    to_print(end+1,:) = {'','',                          '...              except if ''nan_as_zero'' switch is set to 1)'};
    to_print(end+1,:) = {'interpolation:',args.interpolation,'... methods for interpolation of low frequency data into higher frequency'};
    to_print(end+1,:) = {'','',                          '...   ''clone'' -> particular value will be repeated for all periods'};
    to_print(end+1,:) = {'','',                          '...   ''clone_flow'' -> the sum of 4 quarters in a year yields the input yearly figure'};
    to_print(end+1,:) = {'','',                          '...   ''smooth'' -> spline interpolation'};
    to_print(end+1,:) = {'','',                          '...   ''smooth_flow'' -> spline interpolation for flow-type variables'};
    to_print(end+1,:) = {'','',                          '...   ''linear'' -> linear interpolation between two consecutive input values'};
    to_print(end+1,:) = {'nan_as_zero:',args.nan_as_zero,'... NaN values can be treated equally as zeros (to be switched on in rare cases only)'};
    
    %to_print{end+1,1} = '#>>> XLS OUTPUT FILE <<<#';% Category name
    
    res.to_print = to_print;
    res.opt_call = 't = convert(tsobj(),options) -> file name may contain partial/absolute path';
    
    end %<definition>

end %<eof>