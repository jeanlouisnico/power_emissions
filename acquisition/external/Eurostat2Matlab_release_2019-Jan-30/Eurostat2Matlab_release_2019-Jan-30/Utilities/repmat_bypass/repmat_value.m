function out = repmat_value(val,n)
% 
% This is to avoid the slow performance of repmat()
% Similar functions: repmat_cellstr(str,n)
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

out(n,1) = 0;
out(:) = val;

end %<eof>