function str = repmat_cellstr(str,n)
% 
% This is to avoid the slow performance of repmat()
% 
% Example: repmat_cellstr('asdf',3) is equal to repmat({'asdf'},3,1)
% 
% Similar functions: repmat_cellstr_empty(n)-> optimized for str= ''
%                    repmat_value(num,n) ...for scalars
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

str = {str};
len = 1;
str = str(len(:,ones(1,n)),1);

end %<eof>