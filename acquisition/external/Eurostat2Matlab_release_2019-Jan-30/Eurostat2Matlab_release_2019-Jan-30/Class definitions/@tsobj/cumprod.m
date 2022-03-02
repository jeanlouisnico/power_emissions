function this = cumprod(this)
%
% Cumulative product for tsobj(), works well with tsobj() collections 
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

this.values = cumprod(this.values,1);

end %<eof>