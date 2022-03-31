function TTSync = extractstatnett(country)

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
power.solar = 0 ;

d = datetime('now','TimeZone','Europe/Oslo') ;

elecfuel = retrieveEF ;

% In this case, we consider that combined cycle is mainly made of gas chp
% units based on the statistics of powerplants placed in the CC category in
% REE.

[alldata, ~] = fuelmixEU({country}, false, 'absolute') ;
% alphadigit = countrycode('Portugal') ;

nuclear = {'N9000'} ;
thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900' 'P1100'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
wind  = {'RA310' 'RA320'} ; 
solar = {'RA410' 'RA420'} ; 

predictedfuel = fuelmixEU_lpredict(alldata.(country)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

genbyfuel_thermal = power.thermal .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_hydro = power.hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_hydro.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_hydro.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_wind = power.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_wind.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_wind.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_solar = sum(power.solar(end) .* normalisedpredictsolar(end,:).Variables/100 ,'omitnan') ;
genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar(1)) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_solar.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_solar.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_nuclear = power.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_nuclear.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_nuclear.Properties.VariableNames = cat(1, replacestring{:}) ;

tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear, genbyfuel_solar} ;

TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');
TTSync.TSO  = power ;

data = TTSync.emissionskit.Variables ;
data(isnan(TTSync.emissionskit.Variables)) = 0 ;
TTSync.emissionskit.Variables = data ;
