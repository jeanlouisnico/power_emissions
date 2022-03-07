function TTSync = RO
currenttime = javaObject("java.util.Date") ;
timezone    = -currenttime.getTimezoneOffset()/60 ;
d1 = datetime('now', 'TimeZone','Europe/Sofia') ;

timestartepoch  = d1 - hours(1) ;
timeendepoch    = d1 ;
timestartUNIX   = posixtime(d1  - hours(1)) * 1000;
timeendUNIX     = posixtime(d1) * 1000 ;

header = {'consumption'
        'average consumption'
        'production'
        'coal'
        'gas'
        'water'
        'nuclear'
        'wind'
        'solar'
        'biomass'
        'balance'};

data = webread(['https://www.transelectrica.ro/widget/web/tel/sen-grafic?p_p_id=SENGrafic_WAR_SENGraficportlet&p_p_lifecycle=2&p_p_state=maximized&p_p_mode=view&p_p_cacheability=cacheLevelPage&_SENGrafic_WAR_SENGraficportlet_random=random' ...
               '&_SENGrafic_WAR_SENGraficportlet_start_day=' num2str(timestartepoch.Day)...
               '&_SENGrafic_WAR_SENGraficportlet_start_month=' num2str(timestartepoch.Month) ...
               '&_SENGrafic_WAR_SENGraficportlet_start_year=' num2str(timestartepoch.Year) ...
               '&_SENGrafic_WAR_SENGraficportlet_start_Hour=' num2str(timestartepoch.Hour) ...
               '&_SENGrafic_WAR_SENGraficportlet_start_Minute=' num2str(timestartepoch.Minute) ...
               '&_SENGrafic_WAR_SENGraficportlet_end_day=' num2str(timeendepoch.Day) ... 
               '&_SENGrafic_WAR_SENGraficportlet_end_month=' num2str(timeendepoch.Month) ...
               '&_SENGrafic_WAR_SENGraficportlet_end_year=' num2str(timeendepoch.Year) ...
               '&_SENGrafic_WAR_SENGraficportlet_end_Hour=' num2str(timeendepoch.Hour) ...
               '&_SENGrafic_WAR_SENGraficportlet_end_Minute=' num2str(timeendepoch.Minute)...
               '&_=' num2str(floor(timestartUNIX))]);
data = split(data,'|',1) ;
data2 = cellfun(@(x) split(x,';',2), data, 'UniformOutput', false) ;
databis2 = {} ;
for irow = 1:length(data2)
    if ~isempty(data2{irow}{1})
        databis2 = [databis2 ; data2{irow}] ;
    end
end

tabledata = cellfun(@(x) str2double(x),databis2(:,2:end-1)) ;

tabledata = array2timetable(tabledata, "VariableNames",header, "RowTimes",cellfun(@(x) datetime(x, 'InputFormat', 'dd-MM-uuuu HH:mm:ss', 'TimeZone','Europe/Sofia'), databis2(:,1))) ;

elecfuel = retrieveEF ;

[alldata, ~] = fuelmixEU('Romania', false, 'absolute') ;

nuclear = {'N9000'} ;
thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
wind  = {'RA310' 'RA320'} ; 
solar = {'RA410' 'RA420'} ; 

predictedfuel = fuelmixEU_lpredict(alldata.RO) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

d = tabledata.Time(end) ;
genbyfuel_hydro = tabledata.water(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

genbyfuel_wind = tabledata.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;

genbyfuel_solar = sum(tabledata.solar(end) .* normalisedpredictsolar(end,:).Variables/100 ,'omitnan') ;
genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar(1)) ;

genbyfuel_nuclear = tabledata.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;

thermalpower = tabledata.production(end) - sum(tabledata(end,{'solar' 'wind' 'water' 'nuclear'}).Variables) ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

tables = {genbyfuel_thermal,genbyfuel_solar, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;

%% output

TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;
TTSync.TSO = tabledata(end,{'consumption' 'production' 'coal' 'gas' 'water' 'nuclear' 'wind' 'solar' 'biomass'}) ;

TTSync.emissionskit = convertTT_Time(TTSync.emissionskit,'UTC') ;
TTSync.TSO = convertTT_Time(TTSync.TSO,'UTC') ;