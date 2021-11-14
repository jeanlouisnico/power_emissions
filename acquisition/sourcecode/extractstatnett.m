function power = extractstatnett(country)

datastat = webread(['https://driftsdata.statnett.no/restapi/ProductionConsumption/GetLatestDetailedOverview?timestamp=' num2str(posixtime(datetime('now'))*1000)]) ;

countrylist = {datastat.Headers.value}.';
countryrow = find(strcmp(country, countrylist)==1) ;

if strcmp(datastat.NuclearData(countryrow).value,'-')
    power.nuclear = 0 ;
else
    nuclear = datastat.NuclearData(countryrow).value ;
    nuclear(nuclear < '0' | nuclear > '9') = [];
    power.nuclear = sscanf(nuclear, '%d')  ;
end
if strcmp(datastat.NotSpecifiedData(countryrow).value,'-')
    power.unknown = 0 ;
else
    unknown = datastat.NotSpecifiedData(countryrow).value ;
    unknown(unknown < '0' | unknown > '9') = [];
    power.unknown = sscanf(unknown, '%d')  ;
end
if strcmp(datastat.WindData(countryrow).value,'-')
    power.wind = 0 ;
else
    wind = datastat.WindData(countryrow).value ;
    wind(wind < '0' | wind > '9') = [];
    power.wind = sscanf(wind, '%d') ;
end
if strcmp(datastat.ThermalData(countryrow).value,'-')
    power.thermal = 0 ;
else
    thermal = datastat.ThermalData(countryrow).value  ;
    thermal(thermal < '0' | thermal > '9') = [];
    power.thermal = sscanf(thermal, '%d') ;
end
if strcmp(datastat.HydroData(countryrow).value,'-')
    power.hydro = 0 ;
else
    hydro = datastat.HydroData(countryrow).value ;
    hydro(hydro < '0' | hydro > '9') = [];
    power.hydro = sscanf(hydro, '%d') ;
end



