function getFontName()
%
% Shows default font name in figures
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
ax = get(0,'defaultAxesFontName');
txt = get(0,'defaultTextFontName');

fprintf('\n\tdefaultAxesFontName:\t%s\n',ax);
fprintf('\n\tdefaultTextFontName:\t%s\n',txt);

end %<eof>