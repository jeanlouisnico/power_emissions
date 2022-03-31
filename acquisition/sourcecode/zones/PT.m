%% Portugal
function TTSync = PT

dtLCL = datetime('now', 'TimeZone','local')       ;  
timePT = datetime(dtLCL, 'TimeZone', 'Europe/Lisbon') ;

sqltime  = (datenum(timePT) * (24*60*60) - ((367)*24*60*60))*10^7 ;

data = webread(['https://datahub.ren.pt/api/Electricity/ProductionBreakdown/1266?culture=en-GB&dayToSearchString=' char((compose("%d",round(sqltime)))) '&useGasDate=false']) ;

% timearray = data.xAxis.categories ;

power.(makevalidstring(data.series{2}.name)) = data.series{2}.data ;
power.(makevalidstring(data.series{1}.name))     = data.series{1}.data - power.consumption ;
power.(makevalidstring(data.series{3}.name))     = data.series{3}.data ;
power.(makevalidstring(data.series{4}.name))     = data.series{4}.data ;
power.(makevalidstring(data.series{5}.name))     = data.series{5}.data ;
power.(makevalidstring(data.series{6}.name))     = data.series{6}.data ;
power.(makevalidstring(data.series{7}.name))     = data.series{7}.data ;
power.(makevalidstring(data.series{8}.name))     = data.series{8}.data ;
power.(makevalidstring(data.series{9}.name))     = data.series{9}.data ;
power.(makevalidstring(data.series{10}.name))     = data.series{10}.data ;
power.(makevalidstring(data.series{11}.name))     = data.series{11}.data ;
 
timeaxis = data.xAxis.categories(1:length(power.coal )) ;

decompose_time = cellfun(@(x) strsplit(x,':'),timeaxis,'UniformOutput',false) ;
timearray = cellfun(@(x) datetime(timePT.Year,timePT.Month, timePT.Day, str2double(x(1)), str2double(x(2)), 0), decompose_time, 'UniformOutput',false) ;
datein = [timearray{:}]';
% 
% datein = cellfun(@(x) datetime(x,'InputFormat', 'HH:mm', 'TimeZone', 'Europe/Lisbon'), timeaxis) ;

powerdata = struct2table(power) ;

TTSync.TSO = table2timetable(powerdata,'RowTimes',datein) ;
TTSync.TSO = TTSync.TSO(end,:) ;

equivalentname = {'consumption'	 'consumption'
                  'consumption__pumping'	'pumping' 
                  'hydro'	'hydro'
                  'solar'	'solar'
                  'wind'	'wind'
                  'natural_gas'	 'gas'
                  'imports'	'imports'
                  'other_thermal'	'thermal'
                  'biomass'	'biomass'
                  'coal'	'coal'
                  'wave' 'wave'} ;

replacestring = cellfun(@(x) equivalentname(strcmp(equivalentname(:,1),x),2), TTSync.TSO.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.TSO.Properties.VariableNames = cat(1, replacestring{:}) ;

elecfuel = retrieveEF ;

% In this case, we consider that combined cycle is mainly made of gas chp
% units based on the statistics of powerplants placed in the CC category in
% REE.

[alldata, ~] = fuelmixEU('Portugal', false, 'absolute') ;
alphadigit = countrycode('Portugal') ;

thermal = {'CF_NR' 'O4000XBIO' 'X9900'} ;
hydro   = {'RA110' 'RA120' 'RA130'} ;
predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro   = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;

thermalpower = TTSync.TSO.thermal ;
hydropower   = TTSync.TSO.hydro ;
d = TTSync.TSO.Time ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_hydro = hydropower .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_hydro.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_hydro.Properties.VariableNames = cat(1, replacestring{:}) ;

tables = {genbyfuel_thermal, genbyfuel_hydro} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

TTSync.emissionskit = synchronize(TTSync.TSO, TTSync.emissionskit) ;
TTSync.emissionskit = removevars(TTSync.emissionskit, 'thermal') ;
TTSync.emissionskit = removevars(TTSync.emissionskit, 'hydro') ;

TTSync.TSO = convertTT_Time(TTSync.TSO,'UTC') ;
TTSync.emissionskit = convertTT_Time(TTSync.emissionskit,'UTC') ;