function this = uminus(this)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

this.values = -this.values;
% this = minus(0,this);

this.name = namechange_unary(this.name,'-');
%this.techname = repmat_cellstr_empty(length(this.name));

end