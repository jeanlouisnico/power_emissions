function TTSync = PO

% Get data from Polish TSO

relationship = {'wodne' 'hydro'
                'wiatrowe' 'wind'
                'cieplne' 'thermal'
                'PV' 'solar'
                'inne' 'other_biogas'
                'zapotrzebowanie' 'demand'
                'generacja' 'generation'
                'czestotliwosc' 'frequency'
                } ;

elecfuel = retrieveEF ;

data = webread('https://www.pse.pl/transmissionMapService') ;
d = datetime(data.timestamp/1000, 'ConvertFrom', 'posixtime','TimeZone', 'Europe/Warsaw') ;

TTSync.TSO = struct2table(data.data.podsumowanie) ;
TTSync.TSO = table2timetable(TTSync.TSO, "RowTimes",d) ;

replacestring = cellfun(@(x) relationship(strcmp(relationship(:,1),x),2), TTSync.TSO.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.TSO.Properties.VariableNames = cat(1, replacestring{:}) ; 

[alldata, ~] = fuelmixEU('Poland', false, 'absolute') ;

thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'N9000' 'X9900'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
wind  = {'RA310' 'RA320'} ; 
solar = {'RA410' 'RA420'} ; 


predictedfuel = fuelmixEU_lpredict(alldata.PL) ;
normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;

genbyfuel_hydro = TTSync.TSO.hydro .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

genbyfuel_wind = TTSync.TSO.wind .* normalisedpredictwind(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;

%sum(tabledata.solar(end) .* normalisedpredictsolar(end,:).Variables/100 ,'omitnan') ;
genbyfuel_solar = sum(TTSync.TSO.solar .* normalisedpredictsolar(end,:).Variables/100 ,'omitnan') ;
genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar(1)) ;

genbyfuel_thermal = TTSync.TSO.thermal .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

tables = {genbyfuel_thermal,genbyfuel_solar, genbyfuel_wind, genbyfuel_hydro} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;

%% output
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

changefuel = {  'biomass'	'biomass'
                'coal'	'coal_chp'
                'unknown'	'unknown'
                'gas'	'gas'
                'oil'	'oil'
                'nuclear_PWR'	'nuclear_PWR'
                'waste'	'waste'
                'solar_thermal'	'solar_thermal'
                'windon'	'windon'
                'windoff'	'windoff'
                'hydro_runof'	'hydro_runof'
                'hydro_reservoir'	'hydro_reservoir'
                'hydro_pumped'	'hydro_pumped'} ;
replacestring = cellfun(@(x) changefuel(strcmp(changefuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

TTSync.TSO = convertTT_Time(TTSync.TSO,'UTC') ;
TTSync.emissionskit = convertTT_Time(TTSync.emissionskit,'UTC') ;