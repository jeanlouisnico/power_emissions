function TTSync = extractSweden


Powerindex = {'production', ...
              'nuclear', ...
              'hydro', ...
              'thermal', ...
              'wind', ...
              'unknown', ...
              'consumption'} ;

currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

timeextract = datetime('now', 'Format','yyyy-MM-dd','TimeZone','Europe/Stockholm') ;

url = ['https://www.svk.se/ControlRoom/GetProductionHistory/?productionDate=' char(timeextract) '&countryCode=SE'] ;
data = webread(url);

for itech = 1:length(data)
    Time = datetime(datestr(datenum(1970,1,1, timezone, 0, 0) + ([data(itech).data(:).x]/1000)/(24*3600))) ;
    Power.(Powerindex{data(itech).name}) = timetable([data(itech).data(:).y]', 'RowTimes', Time) ;
end

for itech = 1:length(data)
    Powerextract = tail(Power.(Powerindex{data(itech).name}), 1) ;
%     Powerout.Time = Powerextract.Time ;
    Powerout.(Powerindex{data(itech).name}) = Powerextract.Var1 ;
end
if ~isfield(Powerout,'solar')
    Powerout.solar = 0 ;
end
%% The emission kit method
d = datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss') ;
elecfuel = retrieveEF ;

[alldata, ~] = fuelmixEU({'Sweden'}, false, 'absolute') ;
alphadigit = countrycode('Sweden') ;
nuclear = {'N9000'} ;
thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900' 'P1100'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
wind  = {'RA310' 'RA320'} ; 
solar = {'RA410' 'RA420'} ; 

predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

genbyfuel_hydro = Powerout.hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_hydro.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_hydro.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_wind = Powerout.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_wind.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_wind.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_solar = sum(Powerout.solar(end) .* normalisedpredictsolar(end,:).Variables/100 ,'omitnan') ;
genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar(1)) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_solar.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_solar.Properties.VariableNames = cat(1, replacestring{:}) ;

genbyfuel_nuclear = Powerout.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;
    replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_nuclear.Properties.VariableNames, 'UniformOutput', false) ;
    genbyfuel_nuclear.Properties.VariableNames = cat(1, replacestring{:}) ;

thermalpower = Powerout.thermal + Powerout.unknown ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;


tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear} ;

TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');
TTSync.TSO = table2timetable(struct2table(Powerout),'RowTimes',d) ;

TTSync.emissionskit = convertTT_Time(TTSync.emissionskit,'UTC') ;
TTSync.TSO = convertTT_Time(TTSync.TSO,'UTC') ;
