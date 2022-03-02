function varargout = hp(varargin)
%
% Options handling for tsobj/hp() function
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

p = inputParser;%input_parser;%
if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end

fcn(p,'output','trend',@(x) any(validatestring(x,{'trend','gap','prcgap'})));
fcn(p,'lambda',1600,@isnumeric);
fcn(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));
fcn(p,'missing',0,@(x) any(x==[0;1]));% Retain(1)/drop(0) HP estimates for missing values

% Internal option
fcn(p,'throw_warnings',1,@(x) any(x==[0;1]));

p.parse(varargin{:});
args = p.Results;

% keyboard;

%% Validation
if args.lambda<0
   error_msg('HP filtering','''lambda'' parameter must be non-negative...'); 
end

%% Print options overview
if nargin==0 && nargout==0
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

    to_print(end+1,:) = {'output:',args.output,'... HP output form (''trend'',''gap'',''prcgap'')'};
    to_print(end+1,:) = {'lambda:',args.lambda,'... smoothing parameter (high-pass filter cut-off)'};
    to_print(end+1,:) = {'rename:',args.rename,'... 0/1 switch (output is renamed as "hp(...)") by default'};
    to_print(end+1,:) = {'missing:',args.missing,'... 0/1 switch (missing values treatment - retain(1)/drop(0) filtered estimates for missing values)'};
    %to_print(end+1,:) = {'throw_warnings:',args.throw_warnings,'... 0/1 switch (leaves/deletes temporary files)'};
    
    %to_print{end+1,1} = '#>>> XLS OUTPUT FILE <<<#';% Category name
    
    res.to_print = to_print;
    res.opt_call = 'hp(tsobj(),options)';
    
    end %<definition>

end %<eof>