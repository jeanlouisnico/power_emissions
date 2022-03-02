function out_cell = cell_drop_elements(in_cell,drop)
%
% Internal file: no explanation provided
% 
% INPUT:  in_cell  ...[CELL/VECTOR] array to be squeezed
%                     <can be multidim>
%         drop     ...[0X1 VECTOR] yes/no
%                     <univariate vector>
% OUTPUT: out_cell ...[CELL] 
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

transposed = false;
if size(in_cell,1)<size(in_cell,2)
   in_cell = in_cell';
   transposed = true;
end
if size(drop,1)<size(drop,2)
    drop = drop';
end
if size(in_cell)~= size(drop)
    error('||| Vector dimensions not aligned...');
end 

out_cell = in_cell;
for ii = length(drop):-1:1
    if drop(ii)
        out_cell(ii,:) = [];
    end
end

if transposed == true
   out_cell = out_cell';
end

end