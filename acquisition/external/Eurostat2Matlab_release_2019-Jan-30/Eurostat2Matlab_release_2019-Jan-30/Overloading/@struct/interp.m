function in = interp(in,varargin)
%
% Interpolation of each tsobj() within given struct()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
args = dynammo.options.interp(varargin{:});

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
   in.(fields{ii}) = interp(in.(fields{ii}),args);
end

end %<eof>