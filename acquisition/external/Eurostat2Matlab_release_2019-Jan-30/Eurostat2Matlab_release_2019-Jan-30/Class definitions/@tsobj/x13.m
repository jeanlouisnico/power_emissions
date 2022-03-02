function this = x13(this,varargin)
% 
% 3rd party seasonal adjustment command line tool for tsobj()
% 
% All x12/x13 settings should be declared here as one single string. 
%    Each line of code should end with a ';' (semicolon).
% 
%    Example 1: ...,'instructions','outlier{types=all;critical=3.75}'
% 
%    Example 2: Series{} command contains the data input, which need not 
%               be declared by the user, thus declaring
%               ...,'instructions','series{precision=1}' will be automatically
%               extended to make sure the data input is set up.
% 
%    Example 3: Combinations of options are allowed:
%               ...,'instructions','outlier{type=all}series{precision=1}'

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Process user input
parseOpt = 1;
if nargin==2
    if isstruct(varargin{1})
        args = varargin{1};
        parseOpt = 0;
    end
end
if parseOpt
    
    % >>> Options <<<
    args = dynammo.options.x12(varargin{:});
    if ~isstruct(args)
       error_msg('Options resolution','This usually happens if you do not enter the function options properly...'); 
    end    
    
end

args.x13ConvertorNeeded = 1;

%% x12() call
this = x12(this,args);

end %<eof>