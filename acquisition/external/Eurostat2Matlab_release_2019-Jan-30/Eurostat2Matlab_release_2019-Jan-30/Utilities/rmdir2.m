function [st, msg] = rmdir2(folder)       
%
% Matlab's rmdir() sometimes does not work
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

if ispc    
    myCmd = sprintf( 'rmdir /S /Q "%s"', folder);
    [ st, msg ] = system(myCmd);
else
    % todo
    keyboard;
end

end %<eof>