function x = minus(x,y)
%
% INPUT: x ...cell
%        y ...cell/char
% 
% Use1: Drop some cell elements
%       {'a';'b';'e'}-{'a';'e'} yields {'b'}
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ischar(x)
  x = {x};
end
if ischar(y)
  y = {y};
end
[x,where] = setdiff(x,y);
[~,where] = sort(where);
x = x(where);

end %<eof>