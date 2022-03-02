function setFontName(font)
%
% Resets default font name in figures
%
% INPUT: font... requested font name
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

myFonts = listfonts();

%% Body
if any(strcmp(myFonts,font))
    set(0,'defaultAxesFontName',font);
    set(0,'defaultTextFontName',font);
else
    error_msg('Font selection','Requested font is not among installed fonts:',myFonts);
end

end %<eof>