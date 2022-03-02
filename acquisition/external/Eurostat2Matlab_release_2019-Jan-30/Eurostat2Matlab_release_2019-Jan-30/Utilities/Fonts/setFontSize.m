function setFontSize(siz)
%
% Resets default font size in figures
%
% INPUT: siz... requested font size
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
set(0,'defaultAxesFontSize',siz);
set(0,'defaultTextFontSize',siz);

end %<eof>