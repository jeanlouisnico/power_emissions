function this = minus(first,second)
% 
% Minus operator for the case when either of the operands is a tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

this = plus(first,uminus(second));

%% Names
if isscalar(first) && isa(first,'double')
    first_name = first;
else
    first_name = first.name;
end

if isscalar(second) && isa(second,'double')
    second_name = second;
else
    second_name = second.name;
end

this.name = namechange_binary(first_name,'-',second_name);
% this.techname = repmat({''},length(this.name),1);

this.name = strrep(this.name,'[+]-','[-]');

end