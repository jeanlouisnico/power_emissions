%% Belgium
function TTSync = BE

dtLCL = datetime('now', 'TimeZone','local')       ;  
timeBE = datetime(dtLCL, 'TimeZone', 'Europe/Brussels') ;

datein = datestr(timeBE, 'yyyy-mm-dd') ;

data = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/generations/generatedcipupowerbyfueltypebyquarterhour/' datein]) ;
try
    solar = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/solareforecasting/chartdataforzone?dateFrom=' datein '&dateTo=' datein '&sourceID=1']);
catch
    solar(1).startsOn = datetime(timeBE,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC') ;
    solar(1).realTime = 0 ;
end
try
    windoffdata  = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/windforecasting/forecastdata?beginDate=' datein '&endDate=' datein '&region=1&isEliaConnected=&isOffshore=True']) ;
catch
    windoffdata = [] ;
end
try
    windondata   = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/windforecasting/forecastdata?beginDate=' datein '&endDate=' datein '&region=1&isEliaConnected=&isOffshore=False']) ;
catch
    windondata = [] ;
end
if isempty(windoffdata)
    windoffdata(1).startsOn = datetime(datetime(data(end).timeUtc,'Format', 'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC'),'Format','uuuu-MM-dd''T''HH:mm:ss''+00:00') ;
    windoffdata(1).realtime = 0 ;
end
if isempty(windondata)
    windondata(1).startsOn = datetime(datetime(data(end).timeUtc,'Format', 'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC'),'Format','uuuu-MM-dd''T''HH:mm:ss''+00:00') ;
    windondata(1).realtime = 0 ;
end

alltime = datetime(cat(1, data(:).timeUtc) , 'Format', 'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC') ;

alltimeBE = datetime(alltime, 'TimeZone', 'Europe/Brussels') ;

allfields = fieldnames(data) ;

for ifield = 1:length(allfields)
    if ~strcmp(allfields{ifield}, 'timeUtc')
        powerout.(makevalidstring(allfields{ifield})) = [data(:).(allfields{ifield})]' ;
    end
end

powerout = struct2table(powerout) ;

powerout = table2timetable(powerout, 'RowTimes',alltimeBE) ;
    alltimesolar = datetime(cat(1, solar(:).startsOn) , 'Format', 'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC') ;
    alltimesolar = datetime(alltimesolar, 'TimeZone', 'Europe/Brussels') ;
    solardata = [solar(:).realTime]' ;
    solarTT = array2timetable(solardata, 'RowTimes',alltimesolar(1:length(solardata))) ;
    
    alltimewindon = datetime(cat(1, windondata(:).startsOn) , 'Format', 'uuuu-MM-dd''T''HH:mm:ss''+00:00', 'TimeZone', 'UTC') ;
    alltimewindon = datetime(alltimewindon, 'TimeZone', 'Europe/Brussels') ;
    windon = [windondata(:).realtime]' ;
    windonTT = array2timetable(windon, 'RowTimes',alltimewindon(1:length(windon))) ;
    
    alltimewindoff = datetime(cat(1, windoffdata(:).startsOn) , 'Format', 'uuuu-MM-dd''T''HH:mm:ss''+00:00', 'TimeZone', 'UTC') ;
    alltimewindoff = datetime(alltimewindoff, 'TimeZone', 'Europe/Brussels') ;
    windoff = [windoffdata(:).realtime]' ;
    windoffTT = array2timetable(windoff, 'RowTimes',alltimewindoff(1:length(windoff))) ;
powerout = synchronize(powerout,solarTT) ;
powerout = synchronize(powerout,windonTT) ;
powerout = synchronize(powerout,windoffTT) ;

powerout = removevars(powerout, "solar") ;
if (powerout.windon(end) == 0 || isnan(powerout.windon(end))) && powerout.wind(end) > 0
    powerout = removevars(powerout, "windon") ;
    powerout = removevars(powerout, "windoff") ;
else
    powerout = removevars(powerout, "wind") ;
end
powerout = renamevars(powerout,"solardata", "solar") ;

% Extract valid table
powerout = powerout(~isnan(powerout.nuclear),:) ;

data = powerout.Variables ;
data(isnan(powerout.Variables)) = 0 ;
powerout.Variables = data ;

TTSync.TSO = powerout(end,:) ;
%% Extract emissions
elecfuel = retrieveEF ;

[alldata, ~]    = fuelmixEU('Belgium', false, 'absolute') ;
alphadigit      = countrycode('Belgium') ;

thermal = {'CF_R' 'CF_NR' 'O4000XBIO' 'X9900'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
wind  = {'RA310' 'RA320'} ; 
nuclear = {'N9000'} ;
coal = {'C0000'} ;
gas = {'G3000'} ;
% solar = {'RA410' 'RA420'} ; 

predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
% normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
% normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

d = TTSync.TSO.Time ;

thermalpower = TTSync.TSO.liquidfuel + TTSync.TSO.other  ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

genbyfuel_hydro = TTSync.TSO.water(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

if any(strcmp('wind',TTSync.TSO.Properties.VariableNames))
    genbyfuel_wind = TTSync.TSO.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
    genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;
end
% genbyfuel_solar = TTSync.TSO.solar(end) .* normalisedpredictsolar(end,:).Variables/100  ;
% genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar) ;
% 
genbyfuel_nuclear = TTSync.TSO.nuclear(end) ;
genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;

genbyfuel_coal = TTSync.TSO.coal(end) ;
genbyfuel_coal = array2timetable(genbyfuel_coal, "RowTimes", d, "VariableNames", coal) ;

genbyfuel_gas = TTSync.TSO.naturalgas(end) ;
genbyfuel_gas = array2timetable(genbyfuel_gas, "RowTimes", d, "VariableNames", gas) ;

if any(strcmp('wind',TTSync.TSO.Properties.VariableNames))
    tables = {genbyfuel_thermal, genbyfuel_hydro, genbyfuel_wind, genbyfuel_nuclear, genbyfuel_gas, genbyfuel_coal} ;
else
    tables = {genbyfuel_thermal, genbyfuel_hydro, genbyfuel_nuclear, genbyfuel_gas, genbyfuel_coal} ;
end
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

try 
    TTSync.emissionskit.biomass = TTSync.emissionskit.biomass + TTSync.TSO.biomass ;
catch
end

if any(strcmp('wind',TTSync.TSO.Properties.VariableNames))
    TTSync.emissionskit = addvars(TTSync.emissionskit, TTSync.TSO.solar,'NewVariableNames',{'solar'}) ;
else
    TTSync.emissionskit = addvars(TTSync.emissionskit, TTSync.TSO.windon, TTSync.TSO.windoff, TTSync.TSO.solar,'NewVariableNames',{'windon','windoff','solar'}) ;
end


TTSync.emissionskit = convertTT_Time(TTSync.emissionskit,'UTC') ;
TTSync.TSO = convertTT_Time(TTSync.TSO,'UTC') ;