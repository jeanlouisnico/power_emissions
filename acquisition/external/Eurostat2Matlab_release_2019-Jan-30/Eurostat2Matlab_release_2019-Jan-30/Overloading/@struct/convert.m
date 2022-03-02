function in = convert(in,varargin)
%
% Convertor of all time series objects within given struct() obj.
% into specified frequency
% See also tsobj/convert()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
args = dynammo.options.convert(varargin{:});

%% Body <NEW, faster, tscoll() results in error due to explosion>

tscollind = structfun(@(x) isa(x,'tsobj') && size(x,2)>1,in);
if ~any(tscollind)

    % Implosion makes conversion way faster, tscoll()
    in = implode(in);% only tsobj() imploded...

    % Frequency mismatch
    f = fieldnames(in);
    if any(ismember(f,{'YY';'QQ';'MM';'DD'}))
       error_msg('Frequency mismatch','Each frequency band should be processed separately...'); 
    end

    in = convert(in,args);

    in = explode(in);
    return
    
end

%% Body <OLD, slow, tscoll() ok>

fields = fieldnames(in);
tsobjind = structfun(@(x) isa(x,'tsobj'),in);

% if ~any(tsobjind)
%    varargout{1} = builtin('convert',in,varargin{:}); 
%    return
% end

% Retain tsobj() only
fields = fields(tsobjind);

for ii = 1:length(fields)
   in.(fields{ii}) = convert(in.(fields{ii}),args);
end

end %<eof>