function this = round(this,num)
%
% Rounds values in tsobj() to specified number of digits
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

factor = 10^num;
this.values = round(this.values*factor)./factor;

end