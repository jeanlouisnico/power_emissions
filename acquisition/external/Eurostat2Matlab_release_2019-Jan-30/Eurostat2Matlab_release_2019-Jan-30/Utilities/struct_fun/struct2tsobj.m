function out = struct2tsobj(str,range)
%
% Time series generator from a structure of numeric vectors
%
% INPUT: str ...input structure containing individual vectors
%        range ...time periods in tsobj() format
%
% OUTPUT: out ...output structure with data converted to tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

out = structfun(@(x) tsobj(range,x),str,'UniformOutput',false);

% This leaves empty 'name' property, the user can add it according to 
% techname if needed via explode(implode(... name assignment ...)) commands

end %<eof>