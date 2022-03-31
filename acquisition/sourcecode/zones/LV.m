function TTSync = LV(country)

options = weboptions('Timeout',15) ;
alphadigit = countrycode(country) ;
d = datetime('now','TimeZone','UTC') ;
dLV = datetime(d, 'TimeZone', 'Europe/Vilnius') ;

timeextract = char(datetime(dLV, 'Format', 'yyyy-MM-dd'));
try
    dataLV = webread(['https://www.ast.lv/lv/ajax/charts/production?productionDate=' timeextract '&countryCode=' alphadigit.alpha2], options) ;
catch
    dataLV = 0 ;
end

if isa(dataLV, 'struct')
    try
        t = dataLV.data(1).data(end).x ;
        dUTC = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS', 'TimeZone', 'UTC') ;

        if isempty(dataLV.data(1).data(end).y)
            Powerout.thermal =  0 ;
        else
            Powerout.thermal = dataLV.data(1).data(end).y ;
        end
        
        if isempty(dataLV.data(2).data(end).y)
            Powerout.unknown =  0 ;
        else
            Powerout.unknown = dataLV.data(2).data(end).y ;
        end
        
        if isempty(dataLV.data(3).data(end).y)
            Powerout.wind =  0 ;
        else
            Powerout.wind = dataLV.data(3).data(end).y ;
        end
        
        if isempty(dataLV.data(4).data(end).y)
            Powerout.hydro =  0 ;
        else
            Powerout.hydro = dataLV.data(4).data(end).y ;
        end

        if isempty(dataLV.data(5).data(end).y)
            Powerout.nuclear =  0 ;
        else
            Powerout.nuclear = dataLV.data(5).data(end).y ;
        end

        if isempty(dataLV.data(6).data(end).y)
            Powerout.productionLV =  0 ;
        else
            Powerout.productionLV = dataLV.data(6).data(end).y ;
        end

        if isempty(dataLV.data(7).data(end).y)
            Powerout.consumptionLV =  0 ;
        else
            Powerout.consumptionLV = dataLV.data(7).data(end).y ;
        end

        if isempty(dataLV.data(8).data(end).y)
            Powerout.import =  0 ;
        else
            Powerout.import = dataLV.data(8).data(end).y ;
        end
        TTSync.TSO = table2timetable(struct2table(Powerout,'AsArray',true),'RowTimes',dUTC) ;
%         Poweroutcell = struct2cell(Powerout) ;
%         emptycell = cellfun(@(x) isempty(x), Poweroutcell) ;
%         Poweroutcell(emptycell) = {0} ;
%         Powerout = cell2table(Poweroutcell', 'VariableNames', fieldnames(Powerout)) ;
% 
%         Powerout = table2timetable(Powerout, "RowTimes",  dUTC  ) ;
        
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

predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
% normalisedpredictsolar = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
normalisedpredicnuclear = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

d = TTSync.TSO.Time(end) ;
genbyfuel_hydro = TTSync.TSO.hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

genbyfuel_wind = TTSync.TSO.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;

genbyfuel_nuclear = TTSync.TSO.nuclear(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;

thermalpower = TTSync.TSO.thermal(end) + TTSync.TSO.unknown(end) ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;

%% output

TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

data = TTSync.emissionskit.Variables ;
data(isnan(TTSync.emissionskit.Variables)) = 0 ;
TTSync.emissionskit.Variables = data ;
% TTSync.TSO = Powerout ;