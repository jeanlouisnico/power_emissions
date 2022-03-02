function str = repmat_cellstr_empty(n)
% 
% This is to avoid the slow performance of repmat()
% Similar function: repmat_cellstr(n)
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% slower
% str = {''};
% len = 1;
% str = str(len(:,ones(1,n)),1);

% faster
str = cell(n,1);
str(:) = {''};

end %<eof>