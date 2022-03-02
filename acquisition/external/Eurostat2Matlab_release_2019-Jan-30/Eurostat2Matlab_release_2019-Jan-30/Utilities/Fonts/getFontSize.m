function getFontSize()
%
% Shows default font size in figures
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
ax = get(0,'defaultAxesFontSize');
txt = get(0,'defaultTextFontSize');

fprintf('\n\tdefaultAxesFontSize:\t%g\n',ax);
fprintf('\n\tdefaultTextFontSize:\t%g\n',txt);

end %<eof>