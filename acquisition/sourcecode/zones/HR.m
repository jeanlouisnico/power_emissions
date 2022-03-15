function TTSync = HR

%%% Gather data from Croatia

data = webread('https://www.hops.hr/Home/PowerExchange') ;

d = datetime(data.updateTime,'Format','uuuu-MM-dd HH:mm:SS','TimeZone','Europe/Zagreb') ;

allSourceName = {data.resources(:).sourceName}' ;

power.wind = data.resources(strcmp('Proizvodnja VE',allSourceName)).value ;
power.production = data.resources(strcmp('Ukupna proizvodnja',allSourceName)).value ;
power.other = power.production - power.wind ;

%% Extract emissions

elecfuel = retrieveEF ;

country = 'Croatia' ;

alphadigit = countrycode(country) ;
alldata = fuelmixEU_ind('country',{alphadigit})  ;

installedcap    = loadEUnrgcap('country',{alphadigit}) ;
predictedcap    = fuelmixEU_lpredict(installedcap.(alphadigit.alpha2),'resolution','year') ;

minval = CF_tech(country) ;

nuclear = {'N9000'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
wind  = {'RA310' 'RA320'} ; 
solar = {'RA410' 'RA420'} ; 
thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900' 'RA500_5160'} ;

other = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900' 'RA110' 'RA120' 'RA130' 'RA410' 'RA420' 'RA500_5160'} ;

predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredictthermal    = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
normalisedpredicthydro      = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;
normalisedpredictwind       = array2timetable(bsxfun(@rdivide, predictedfuel(:,wind).Variables, sum(predictedfuel(:,wind).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', wind) ;
normalisedpredictsolar      = array2timetable(bsxfun(@rdivide, predictedfuel(:,solar).Variables, sum(predictedfuel(:,solar).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', solar) ;
normalisedpredicnuclear     = array2timetable(bsxfun(@rdivide, predictedfuel(:,nuclear).Variables, sum(predictedfuel(:,nuclear).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', nuclear) ;

normalisedpredicother = array2timetable(bsxfun(@rdivide, predictedfuel(:,other).Variables, sum(predictedfuel(:,other).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', other) ;

genbyfuel_wind = power.wind(end) .* normalisedpredictwind(end,:).Variables/100 ;
genbyfuel_wind = array2timetable(genbyfuel_wind, "RowTimes", d, "VariableNames", wind) ;

%%% Remove the baseload form nuclear first
normalisedpredicnuclear = fillmissing(normalisedpredicnuclear,'constant',0) ;

genbyfuel_nuclear = power.other(end) .* normalisedpredicnuclear(end,:).Variables/100 ;
genbyfuel_nuclear = array2timetable(genbyfuel_nuclear, "RowTimes", d, "VariableNames", nuclear) ;

power.other = power.other(end) - genbyfuel_nuclear.Variables ;

%%% Split between the remaining fuel
genbyfuel_other = power.other(end) .* normalisedpredicother(end,:).Variables/100 ;
genbyfuel_other = array2timetable(genbyfuel_other, "RowTimes", d, "VariableNames", other) ;
fuel2redistrbute = 0;
%%% Balancing with the installed capacity
if genbyfuel_other.CF_R - minval.biomass > 0
    %%% There is an over estimation of the biomass
    fuel2redistrbute = genbyfuel_other.CF_R - minval.biomass ;
    genbyfuel_other.CF_R = minval.biomass ;
    thermal(strncmpi(thermal,'CF_R',4)) = [] ;
elseif normalisedpredicother.CF_R(end) == 0
    thermal(strncmpi(thermal,'CF_R',5)) = [] ;
end

%%% Check after the waste element
if genbyfuel_other.X9900 - minval.waste>0
    %%% There is an over estimation of the biomass
    fuel2redistrbute = fuel2redistrbute + (genbyfuel_other.X9900 - minval.waste) ;
    genbyfuel_other.X9900 = minval.waste ;
    thermal(strncmpi(thermal,'X9900',5)) = [] ;
elseif normalisedpredicother.X9900(end) == 0
    thermal(strncmpi(thermal,'X9900',5)) = [] ;
end

%%% Check after the biogas element
if genbyfuel_other.RA500_5160 - minval.otherbiogas > 0
    %%% There is an over estimation of the biomass
    fuel2redistrbute = fuel2redistrbute + (genbyfuel_other.RA500_5160 - minval.otherbiogas) ;
    genbyfuel_other.RA500_5160 = minval.otherbiogas ;
    thermal(strncmpi(thermal,'RA500_5160',7)) = [] ;
elseif normalisedpredicother.RA500_5160(end) == 0
    thermal(strncmpi(thermal,'RA500_5160',5)) = [] ;
end

if fuel2redistrbute > 0
    normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;
    genbyfuel_thermal = fuel2redistrbute .* normalisedpredictthermal(end,:).Variables/100 ;
    genbyfuel_other(end,thermal).Variables = genbyfuel_other(end,thermal).Variables + genbyfuel_thermal ;
end

tables = {genbyfuel_other, genbyfuel_nuclear, genbyfuel_wind} ;
TTSync.emissionskit = synchronize(tables{:,:},'union','nearest');

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

