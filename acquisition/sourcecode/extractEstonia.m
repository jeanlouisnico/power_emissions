function TTSync = extractEstonia

currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

%% Get the mix for the previous month to complement the data from statistic Estonia

try 
    systemdata_month = webread('https://dashboard.elering.ee/api/balance/total/latest') ;
catch
    Powerout = 0 ;
    return;
end
t = uint64(systemdata_month.data.timestamp*1000) ;
d = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS') ;

datestart = datestr(datetime('now')  - hours(6), 'yyyy-mm-ddTHH:MM:SS.FFFZ') ;
dateend = datestr(datetime('now')  + hours(6), 'yyyy-mm-ddTHH:MM:SS.FFFZ')   ;
url = ['https://dashboard.elering.ee/api/system/with-plan?start=' datestart '&end=' dateend] ;
systemdata = webread(url) ;

t = uint64(systemdata.data.real(end).timestamp*1000) ;
d = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS','TimeZone','UTC') ;

if isempty(systemdata.data.real(end).production)
    Powerout.production =  0 ;
else
    Powerout.production = systemdata.data.real(end).production ;
end
if isempty(systemdata.data.real(end).consumption)
    Powerout.consumption =  0 ;
else
    Powerout.consumption = systemdata.data.real(end).consumption ;
end
if isempty(systemdata.data.real(end).production_renewable)
    Powerout.production_renewable =  0 ;
else
    Powerout.production_renewable =  systemdata.data.real(end).production_renewable ;
end
% if isempty(systemdata.data.real(end).solar_energy_production)
%     Powerout.solar =  0 ;
% else
%     Powerout.solar =  systemdata.data.real(end).solar_energy_production ;   
% end
Powerout.solar =  systemdata.data.real(end).solar_energy_production ; 
if isempty(Powerout.solar)
    alldates = [systemdata.data.plan.timestamp] ;
    t = uint64(alldates*1000) ;
    alldates = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS','TimeZone','UTC')  ;
    datecompare = datetime('now') ;
    Powerout.solar = systemdata.data.plan(alldates.Hour == d.Hour).solar_energy_forecast ;
end

try
    transmission = webread('https://dashboard.elering.ee/api/transmission/cross-border/latest') ;
catch
    Powerout = 0 ;
    return;
end
Powerout.Finland = transmission.data.finland ;
Powerout.Russia = transmission.data.russia_narva + transmission.data.russia_pihkva ;
Powerout.Latvia = transmission.data.latvia ;
%% HEre is a second extract from the Latvian TSO that has more regular updates for Estonia (about every 3 minutes)

options = weboptions('Timeout',15) ;
timeextract = datestr(now, 'yyyy-mm-dd') ;
try
    estoniaprod = webread(['https://www.ast.lv/lv/ajax/charts/production?productionDate=' timeextract '&countryCode=EE'], options) ;
catch
    estoniaprod = 0 ;
end

if isa(estoniaprod, 'struct')
    try
        t = estoniaprod.data(1).data(end).x ;
        d = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS') + hours(timezone) ;
    
        
        if isempty(estoniaprod.data(1).data(end).y)
            Powerout.thermal =  0 ;
        else
            Powerout.thermal = estoniaprod.data(1).data(end).y ;
        end
        
        if isempty(estoniaprod.data(2).data(end).y)
            Powerout.unknown =  0 ;
        else
            Powerout.unknown = estoniaprod.data(2).data(end).y ;
        end
        
        if isempty(estoniaprod.data(3).data(end).y)
            Powerout.wind =  0 ;
        else
            Powerout.wind = estoniaprod.data(3).data(end).y ;
        end
        
        if isempty(estoniaprod.data(4).data(end).y)
            Powerout.hydro =  0 ;
        else
            Powerout.hydro = estoniaprod.data(4).data(end).y ;
        end

        if isempty(estoniaprod.data(5).data(end).y)
            Powerout.nuclear =  0 ;
        else
            Powerout.nuclear = estoniaprod.data(5).data(end).y ;
        end

        if isempty(estoniaprod.data(6).data(end).y)
            Powerout.productionLV =  0 ;
        else
            Powerout.productionLV = estoniaprod.data(6).data(end).y ;
        end

        if isempty(estoniaprod.data(7).data(end).y)
            Powerout.consumptionLV =  0 ;
        else
            Powerout.consumptionLV = estoniaprod.data(7).data(end).y ;
        end

        if isempty(estoniaprod.data(8).data(end).y)
            Powerout.import =  0 ;
        else
            Powerout.import = estoniaprod.data(8).data(end).y ;
        end
    catch
    end
end

TTSync.TSO = table2timetable(struct2table(Powerout,'AsArray',true),'RowTimes',datetime('now','TimeZone','UTC')) ;

try
    [energy, databyfuel] = extract_estonie_emissions(Powerout) ;

    TTSync.emissionskit = table2timetable(energy.byfuel,'RowTimes',datetime('now','TimeZone','UTC'));
    TTSync.other = table2timetable(struct2table(databyfuel),'RowTimes',datetime('now','TimeZone','UTC'));
catch
    elecfuel = retrieveEF ;
    
    % In this case, we consider that combined cycle is mainly made of gas chp
    % units based on the statistics of powerplants placed in the CC category in
    % REE.
    country = 'EE' ;
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
    
    thermalpower = Powerout.thermal + Powerout.unknown ;
    
    genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
    genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;
        replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
        genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;
    
    genbyfuel_hydro = Powerout.hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
    genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;
        replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_hydro.Properties.VariableNames, 'UniformOutput', false) ;
        genbyfuel_hydro.Properties.VariableNames = cat(1, replacestring{:}) ;
    
    genbyfuel_wind = Powerout.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
    genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;
        replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_wind.Properties.VariableNames, 'UniformOutput', false) ;
        genbyfuel_wind.Properties.VariableNames = cat(1, replacestring{:}) ;
    
    genbyfuel_solar = Powerout.solar(end) .* normalisedpredictsolar(end,:).Variables/100  ;
    genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", solar) ;
        replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_solar.Properties.VariableNames, 'UniformOutput', false) ;
        genbyfuel_solar.Properties.VariableNames = cat(1, replacestring{:}) ;
    
    genbyfuel_nuclear = Powerout.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
    genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;
        replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_nuclear.Properties.VariableNames, 'UniformOutput', false) ;
        genbyfuel_nuclear.Properties.VariableNames = cat(1, replacestring{:}) ;
    
    tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear, genbyfuel_solar} ;
    
    TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');
    
    TTSync.emissionskit = convertTT_Time(TTSync.emissionskit,'UTC') ;
end



