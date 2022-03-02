function this = cumsum(this)
%
% Cumulative summation for tsobj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

this.values = cumsum(this.values,1);

end %<eof>