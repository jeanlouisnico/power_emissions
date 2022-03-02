function list = xls_allAvailableSheets(obj)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% Go through all sheets (make a list)
allSheets = obj.Sheets;
list = cell(allSheets.Count,1); 
for iSheet = 1:allSheets.Count
    list{iSheet} = allSheets.Item(iSheet).Name; % sheet-order is not guaranteed so must build array
end
    
end %<sheetlist>