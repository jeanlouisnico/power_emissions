function in = x12(in,varargin)
%
% Seasonal adjustment of all time series objects within given struct() obj.
% See also tsobj/x12()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
args = dynammo.options.x12(varargin{:});

%% Body

fields = fieldnames(in);
tsobjind = structfun(@(x) isa(x,'tsobj'),in);

% if ~any(tsobjind)
%    varargout{1} = builtin('convert',in,varargin{:}); 
%    return
% end

% Retain tsobj() only
fields = fields(tsobjind);

for ii = 1:length(fields)
   in.(fields{ii}) = x12(in.(fields{ii}),args);
end

end %<eof>