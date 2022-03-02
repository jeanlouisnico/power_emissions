function figdebug()
%
% Makes all open figures visible, including their toolbars (+AOT feature is set 'on')
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

figs = findobj('type','figure');

set(figs,'menubar','figure','toolbar','figure','visible','on');

for ii = 1:length(figs)
    pushbuttons(figs(ii));
    AOTfeature(figs(ii));
end


end %<eof>