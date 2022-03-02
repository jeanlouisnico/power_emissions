function varargout = minus(varargin)
%
% Use1: Range manipulation
%       INPUT: rangein ...e.g. '2011q3'
%              num     ...e.g. -1, +1 (a scalar)
% Use2: Matlab's default behavior needed frequently (!)

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

if nargin==2
    rangein = varargin{1};
    num = varargin{2};
    if isfloat(num)
        varargout{1} = plus(rangein,uminus(num));
        return
    end
end
    
%% Default behavior
varargout{:} = builtin('minus',varargin{:});
    
end %<eof>