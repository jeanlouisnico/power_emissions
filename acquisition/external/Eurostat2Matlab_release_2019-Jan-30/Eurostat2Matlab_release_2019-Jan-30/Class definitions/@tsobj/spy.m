function spy(this)
%
% Spy function for the values of given tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

figure;spy(~isnan(this.values));

end %<eof>