function out = tsobj2struct(ts)
%
% Time series generator from a structure of numeric vectors
%
% INPUT: ts ...structure of time series objects
%
% OUTPUT: out ...output structure with tsobj() data converted to numeric values
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

out = structfun(@(x) x.values,ts,'UniformOutput',false);

end %<eof>