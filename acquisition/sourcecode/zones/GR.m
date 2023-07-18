function TTSync = GR

currenttime = datetime("now",'TimeZone','UTC','Format','uuuuMMdd') ;

url = ['https://www.admie.gr/services/scadaprod.php?date=' char(currenttime)] ;
dataGR = jsondecode(webread(url)) ;

alltime     = datetime(cat(1, dataGR.items(:).recdate) , 'Format', 'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC') ;
itemname    = cat(1, {dataGR.items(:).itemname})' ;
hr          = [dataGR.items(:).hr]' ;
energy      = [dataGR.items(:).energy]' ;

allinput = unique(itemname) ;

for i_in = 1:length(allinput)
    extract = strcmp(allinput(i_in),itemname) ;
    timeextract = alltime(extract) + hours(hr(extract)) ;
    if strcmp('ΣΥΝΟΛΙΚΗ ΑΝΤΛΗΣΗ',allinput{i_in})
        allinput{i_in} = 'TOTAL PUMPING' ;
    end
    energyextract.(makevalidstring(allinput{i_in})) = energy(extract) ;
end
TT = struct2table(energyextract) ;
TSO = table2timetable(TT,'RowTimes',timeextract) ;

lastentry = find(TSO(:,'total_gas').Variables, 1, 'last' ) ;

TTSync.TSO = TSO(lastentry,:) ;

%% Emissionskit method to split the fuel

elecfuel = retrieveEF ;

country = 'Greece' ;

alphadigit = countrycode(country) ;
alldata = fuelmixEU_ind('country',{alphadigit})  ;
solarCF = getSolardata(country) ;
installedcap    = loadEUnrgcap('country',{alphadigit}) ;
predictedcap    = fuelmixEU_lpredict(installedcap.(alphadigit.alpha2),'resolution','year') ;
predictedfuel   = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;
minval          = CF_tech(country) ;

hydro   = {'RA110' 'RA120'} ;
RES     = {'RA310' 'RA320'} ;  
coal    = {'C0000'} ;
gas     = {'G3000'} ;

normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictRES = array2timetable(bsxfun(@rdivide, predictedfuel(:,RES).Variables, sum(predictedfuel(:,RES).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', RES) ;
normalisedpredictcoal = array2timetable(bsxfun(@rdivide, predictedfuel(:,coal).Variables, sum(predictedfuel(:,coal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', coal) ;
normalisedpredictgas = array2timetable(bsxfun(@rdivide, predictedfuel(:,gas).Variables, sum(predictedfuel(:,gas).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', gas) ;

% According to the TSO, the RES production includes wind and solar. However, ENTSOE reports
% RES as wind only and solar is added on top of it.

d = datetime(currenttime,'TimeZone','UTC','Format','dd-MMM-uuuu HH:mm:ss') ;
genbyfuel_solar = predictedcap(end,{'RA410' 'RA420'}).Variables * solarCF.Var1 ;
genbyfuel_solar = array2timetable(genbyfuel_solar, "RowTimes", d, "VariableNames", {'RA410' 'RA420'}) ;

genbyfuel_wind = TTSync.TSO.total_res(end) .* normalisedpredictRES(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", RES) ;

genbyfuel_coal = TTSync.TSO.total_lignite(end) .* normalisedpredictcoal(end,:).Variables/100 ;
genbyfuel_coal = array2timetable(genbyfuel_coal, "RowTimes", d, "VariableNames", coal) ;

genbyfuel_gas = TTSync.TSO.total_gas(end) .* normalisedpredictgas(end,:).Variables/100 ;
genbyfuel_gas = array2timetable(genbyfuel_gas, "RowTimes", d, "VariableNames", gas) ;

genbyfuel_hydro = TTSync.TSO.total_hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", d, "VariableNames", hydro) ;

tables = {genbyfuel_solar, genbyfuel_wind, genbyfuel_coal, genbyfuel_gas, genbyfuel_hydro} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;