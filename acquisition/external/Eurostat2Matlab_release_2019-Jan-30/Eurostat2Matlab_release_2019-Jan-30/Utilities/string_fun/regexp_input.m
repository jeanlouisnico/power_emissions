function out = regexp_input(in,what)
% 
% padding of the 'in' string/cellstr with '\' symbol
% so that out is a regular expression
% 
% what [string] ...e.g. '()+-' => all '(', ')', '+' and '-' will be 
%                      replaced with '\(','\)','\+' and '\-'
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~ischar(what)
    error_msg('Parser','Regular expressions work with strings only...');
end

for ii = 1:length(what)
    in = regexprep(in,['\' what(ii)],['\\' what(ii)]);
end

out = in;
%   out = strcat('\<',in,'\>'); % --> does not work with expressions not starting with a letter


end