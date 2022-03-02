function vals = getNumvals(in)
%
% Extracts all numeric values from the input cell
% (Imported data are usually in 'cell' format)
%
% INPUT: in ...cell object of values imported from a csv/txt/xls file
%
% OUTPUT: out ... matrix of values with NaNs for non-numeric input
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

[r,c] = size(in);
vals = nan(size(in));
for jj = 1:c
for ii = 1:r
   try
       vals(ii,jj) = eval(in{ii,jj});
   catch
       try
           vals(ii,jj) = eval(strrep(in{ii,jj},',','.'));
       end
   end
end
end

end %<eof>