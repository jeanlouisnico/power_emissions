function structobj = values2struct(val,names)
% 
% Matrix into struct object conversion
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% structobj = cell2struct(num2cell(val),names,1);
  structobj = cell2struct(mat2cell(val,ones(length(names),1)),names,1);

end