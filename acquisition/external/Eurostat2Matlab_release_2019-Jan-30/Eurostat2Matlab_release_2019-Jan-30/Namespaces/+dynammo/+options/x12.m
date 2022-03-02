function varargout = x12(varargin)
%
% Options handling for tsobj/x12() function
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

fcn(p,'mode','add',@(x) any(validatestring(x,{'add','mult','pseudoadd','logadd'})));%case insensitive
fcn(p,'instructions','',@ischar);
fcn(p,'verbose',false,@islogical); 
fcn(p,'deleteResults',true,@islogical); 
fcn(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));
fcn(p,'missing',0,@(x) any(x==[0;1]));% Retain(1)/drop(0) SA estimates for missing values

p.parse(varargin{:});%p.parse(this,varargin{:});
args = p.Results;

%% X13 convertor trigger
% ->This options set is shared by both x12 and x13 methods
% -> external convertor for the specification file is needed in x13 method
args.x13ConvertorNeeded = 0;

%% Print options overview
if  nargin==0 &&  nargout==0      
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

    to_print(end+1,:) = {'mode:',args.mode,'... seasonality type (''add''|''mult''|''pseudoadd''|''logadd'')'};
    to_print(end+1,:) = {'instructions:',args.instructions,'... additional instructions according to X12-ARIMA Reference manual'};
    to_print(end+1,:) = {'','',                            '... Example: ''outlier{types=all;critical=3.75}'''};
    to_print(end+1,:) = {'verbose:',args.verbose,'... 0/1 switch (visible/invisible console output)'};
    to_print(end+1,:) = {'deleteResults:',args.deleteResults,'... 0/1 switch (leaves/deletes temporary files)'};
    to_print(end+1,:) = {'rename:',args.rename,'... 0/1 switch (output is renamed as "x12(...)") by default'};
    to_print(end+1,:) = {'missing:',args.missing,'... 0/1 switch (missing values treatment - retain(1)/drop(0) SA estimates for missing values)'};    
    %to_print{end+1,1} = '#>>> XLS OUTPUT FILE <<<#';% Category name
    
    res.to_print = to_print;
    res.opt_call = 'x12(tsobj(),options)';
    
    end %<definition>

end %<eof>