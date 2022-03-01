function TTSync = LV(country)

currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

options = weboptions('Timeout',15) ;
alphadigit = countrycode(country) ;
d = datetime(now, 'ConvertFrom', 'datenum','TimeZone',['+0' num2str(timezone) ':00']) ;
dLV = datetime(d, 'TimeZone', 'Europe/Vilnius') ;

timeextract = char(datetime(dLV, 'Format', 'yyyy-MM-dd'));
try
    dataLV = webread(['https://www.ast.lv/lv/ajax/charts/production?productionDate=' timeextract '&countryCode=' alphadigit], options) ;
catch
    dataLV = 0 ;
end

if isa(dataLV, 'struct')
    try
        t = dataLV.data(1).data(end).x ;
        dUTC = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS', 'TimeZone', 'UTC') ;

        datetimecountry = datetime(dUTC, 'TimeZone', 'Europe/Vilnius') ;
        
        Powerout.thermal = dataLV.data(1).data(end).y ;
        Powerout.unknown = dataLV.data(2).data(end).y ;
        Powerout.wind = dataLV.data(3).data(end).y ;
        Powerout.hydro = dataLV.data(4).data(end).y ;
        Powerout.nuclear = dataLV.data(5).data(end).y ;
        Powerout.productionLV = dataLV.data(6).data(end).y ;
        Powerout.consumptionLV = dataLV.data(7).data(end).y ;
        Powerout.import = dataLV.data(8).data(end).y ;

        Poweroutcell = struct2cell(Powerout) ;
        emptycell = cellfun(@(x) isempty(x), Poweroutcell) ;
        Poweroutcell(emptycell) = {0} ;
        Powerout = cell2table(Poweroutcell', 'VariableNames', fieldnames(Powerout)) ;

        Powerout = table2timetable(Powerout, "RowTimes",  dUTC  ) ;
        
    catch
        Powerout = timetable ;
    end
end


elecfuel = retrieveEF ;

[alldata, ~] = fuelmixEU(country, false, 'absolute') ;

nuclear = {'N9000'} ;
thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
wind  = {'RA310' 'RA320'} ; 
% solar = {'RA410' 'RA420'} ; 

predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
% normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

d = Powerout.Time(end) ;
genbyfuel_hydro = Powerout.hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

genbyfuel_wind = Powerout.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;

genbyfuel_nuclear = Powerout.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;

thermalpower = Powerout.thermal(end) + Powerout.unknown(end) ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;

%% output

TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;
TTSync.TSO = Powerout ;