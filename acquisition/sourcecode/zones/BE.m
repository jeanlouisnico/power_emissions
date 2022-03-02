%% Belgium
function TTSync = BE

dtLCL = datetime('now', 'TimeZone','local')       ;  
timeBE = datetime(dtLCL, 'TimeZone', 'Europe/Brussels') ;

datein = datestr(timeBE, 'yyyy-mm-dd') ;

data = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/generations/generatedcipupowerbyfueltypebyquarterhour/' datein]) ;

solar = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/solareforecasting/chartdataforzone?dateFrom=' datein '&dateTo=' datein '&sourceID=1']);
windoffdata  = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/windforecasting/forecastdata?beginDate=' datein '&endDate=' datein '&region=1&isEliaConnected=&isOffshore=True']) ;
windondata   = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/windforecasting/forecastdata?beginDate=' datein '&endDate=' datein '&region=1&isEliaConnected=&isOffshore=False']) ;
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
powerout = removevars(powerout, "wind") ;

powerout = renamevars(powerout,"solardata", "solar") ;

TTSync.TSO = powerout(end,:) ;
%% Extract emissions
elecfuel = retrieveEF ;

[alldata, ~] = fuelmixEU('Belgium', false, 'absolute') ;
alphadigit = countrycode('Belgium') ;

thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
% wind  = {'RA310' 'RA320'} ; 
% solar = {'RA410' 'RA420'} ; 

predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
% normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
% normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
% normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

d = TTSync.TSO.Time ;

thermalpower = TTSync.TSO.liquidfuel + TTSync.TSO.other  ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

genbyfuel_hydro = TTSync.TSO.water(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

% genbyfuel_wind = TTSync.TSO.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
% genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;

% genbyfuel_solar = TTSync.TSO.solar(end) .* normalisedpredictsolar(end,:).Variables/100  ;
% genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar) ;
% 
% genbyfuel_nuclear = Powerout.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
% genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;

tables = {genbyfuel_thermal, genbyfuel_hydro} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

try 
    TTSync.emissionskit.biomass = TTSync.emissionskit.biomass + TTSync.TSO.biomass ;
catch
end
try 
    TTSync.emissionskit.gas = TTSync.emissionskit.gas + TTSync.TSO.naturalgas ;
catch
end

try 
    TTSync.emissionskit.coal = TTSync.emissionskit.gas + TTSync.TSO.coal ;
catch
end

TTSync.emissionskit = addvars(TTSync.emissionskit, TTSync.TSO.windon, TTSync.TSO.windoff, TTSync.TSO.solar,'NewVariableNames',{'windon','windoff','solar'}) ;










