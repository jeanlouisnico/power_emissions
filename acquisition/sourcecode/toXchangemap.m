function [exportlist,importlist] = toXchangemap(Emissions)

Emissions = orderfields(Emissions) ;
countrylist = fieldnames(Emissions)  ;
exportlist = zeros(length(countrylist), length(countrylist)) ;
importlist = zeros(length(countrylist), length(countrylist)) ;
source = 'emissionskit' ;
DB = 'EcoInvent' ;

for icountry = 1:length(countrylist)
    countryabb = countrylist{icountry} ;
    try
        allexch = Emissions.(countryabb).(source).(DB).exchange ;
    catch
        continue;
    end
    listallcountries = fieldnames(allexch) ;
    col = find(strcmp(countryabb,countrylist)) ;
    for iexch_country = 1:length(listallcountries)
        row = find(strcmp(listallcountries{iexch_country},countrylist)) ;
        values = allexch.(listallcountries{iexch_country}) ;

        if values(end) < 0
            % Then this is export and can be reported
            exportlist(row, col) = values(end) ;
        else
            importlist(col, row) = values(end) ;
        end
    end
end