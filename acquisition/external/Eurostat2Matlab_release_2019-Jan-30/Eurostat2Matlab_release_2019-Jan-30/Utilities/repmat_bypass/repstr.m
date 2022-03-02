function str = repstr(str,n)
%
% repstr('a',5) gives 'aaaaa'

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

len = (1:length(str))';
str = str(1,len(:,ones(1,n)));

end %<eof>