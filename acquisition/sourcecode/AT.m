function TTSync = AT
bid =  {'B01'	'biomass'                             
        'B02'	'lignite'
        'B03'	'gas_coal'
        'B04'	'gas'
        'B05'	'coal'
        'B06'	'oil'
        'B07'	'oil_shale'
        'B08'	'peat'
        'B09'	'geothermal'
        'B10'	'hydro_pumped'
        'B11'	'hydro_runof'
        'B12'	'hydro_reservoir'
        'B13'	'marine'
        'B14'	'nuclear'
        'B15'	'other_biogas'
        'B16'	'solar'
        'B17'	'waste'
        'B18'	'windoff'
        'B19'	'windon'
        'B20'	'other'
        'Sum'   'sum'} ;
currenttime = javaObject("java.util.Date") ; 
timeoffset = minutes(-currenttime.getTimezoneOffset) ;

TZout = getTZ_DT(timeoffset) ;

% This is the time fromt the computer where the script is being run
currenttime = datetime(now,'ConvertFrom','datenum', 'TimeZone',TZout{1}) ; 

% Convert to the time of the TSO 
timeAustria = datetime(currenttime, 'TimeZone', 'Europe/Vienna') ;

datein  = datetime(timeAustria - hours(2), "Format","uuuu-MM-dd'T'HH0000") ; 
dateout = datetime(timeAustria, "Format","uuuu-MM-dd'T'HH0000") ;  

Austria = webread(['https://transparency.apg.at/transparency-api/api/v1/Data/AGPT/English/M15/' ...
                    char(datein) '/' ...
                    char(dateout)]) ;

%%% Check for the last entry in the table

n = 0 ;
irow = 0 ;
while n == 0
    
    data = [Austria.ResponseData.ValueRows(end - irow).V.V] ;
    if isempty(data)
        irow = irow + 1 ;
    else
        n = 1 ;
    end
end

dateexin = Austria.ResponseData.ValueRows(end - irow).DT ;
timeexin = Austria.ResponseData.ValueRows(end - irow).TT ;
outdate = datetime([dateexin ' ' timeexin],"InputFormat","MM/dd/uuuu HH:mm", 'TimeZone', 'Europe/Vienna') ;

TTSync.TSO = array2timetable(data, 'VariableNames', {Austria.ResponseData.ValueColumns.InternalName}, 'RowTimes',outdate) ;
replacestring = cellfun(@(x) bid(strcmp(bid(:,1),x),2), TTSync.TSO.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.TSO.Properties.VariableNames = cat(1, replacestring{:}) ;
%% Get the installed capacity for the latest year
dateinIC    = datetime(datein - calyears(1), 'Format',"uuuu-01-01'T'000000") ;
dateoutIC   = datetime(datein + calyears(1), 'Format',"uuuu-01-01'T'000000") ;
insalledcapacity = webread(['https://transparency.apg.at/transparency-api/api/v1/Data/IGCA/English/Y1/' ...
                            char(dateinIC) '/' ...
                            char(dateoutIC)]) ;

%%% Check for the last entry in the table

n = 0 ;
irow = 0 ;
while n == 0
    
    dataIC = [insalledcapacity.ResponseData.ValueRows(end - irow).V.V] ;
    if isempty(dataIC)
        irow = irow + 1 ;
    else
        n = 1 ;
    end
end

dateexin = insalledcapacity.ResponseData.ValueRows(end - irow).DF ;
timeexin = insalledcapacity.ResponseData.ValueRows(end - irow).TF ;

outdateIC = datetime([dateexin ' ' timeexin],"InputFormat","MM/dd/uuuu HH:mm", 'TimeZone', 'Europe/Vienna') ;

installedcap = array2timetable(dataIC, 'VariableNames', {insalledcapacity.ResponseData.ValueColumns.InternalName}, 'RowTimes',outdateIC) ;
replacestring = cellfun(@(x) bid(strcmp(bid(:,1),x),2), installedcap.Properties.VariableNames, 'UniformOutput', false) ;
installedcap.Properties.VariableNames = cat(1, replacestring{:}) ;
%% Extract emissions

elecfuel = retrieveEF ;

[alldata, ~] = fuelmixEU('Austria', false, 'absolute') ;
alphadigit = countrycode('Austria') ;
% nuclear = {'N9000'} ;
thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900'} ;
% hydro = {'RA110' 'RA120' 'RA130'} ;
% wind  = {'RA310' 'RA320'} ; 
% solar = {'RA410' 'RA420'} ; 

predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
% normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
% normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
% normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
% normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

d = outdate ;
% genbyfuel_hydro = Powerout.hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
% genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;
% 
% genbyfuel_wind = Powerout.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
% genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;
% 
% genbyfuel_solar = sum(tabledata.solar(end) .* normalisedpredictsolar(end,:).Variables/100 ,'omitnan') ;
% genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar(1)) ;
% 
% genbyfuel_nuclear = Powerout.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
% genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;

extractAustria = {'gas' 'coal' 'oil' 'other' 'waste' 'biomass'} ;

thermalpower = sum(TTSync.TSO(:,extractAustria).Variables) ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;
extracteurostat = {'gas' 'coal' 'oil' 'unknown' 'waste' 'biomass'} ;

init = normalisedpredictthermal(end,:).Variables / 100 ;
newlimit = solver_rod(thermalpower, init, installedcap(:,extractAustria)) ;

% proddiff = installedcap(1,extractAustria).Variables - genbyfuel_thermal(:,extracteurostat).Variables ;
% toreallocate = abs(sum(proddiff(proddiff<0))) ;
genbyfuel_thermal(:,extracteurostat).Variables = newlimit(:,extractAustria).Variables ;

% tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear} ;

TTSync.emissionskit = genbyfuel_thermal ;

% replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
% TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

TTSync.emissionskit = synchronize(TTSync.emissionskit, TTSync.TSO(:,{'windon' 'solar' 'geothermal' 'hydro_pumped' 'hydro_reservoir' 'hydro_runof' 'other_biogas'})) ;

