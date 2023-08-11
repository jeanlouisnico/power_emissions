function TTSync = FI_emissionkit(Powerout, installedcap,d)
Powerout = struct2table(Powerout) ;
d = datetime(d,'Format','dd/MM/uuuu HH:mm:ss') ;
%% The emission kit method

elecfuel = retrieveEF ;

[alldata, ~] = fuelmixEU({'Finland'}, false, 'absolute') ;
alphadigit = countrycode('Finland') ;
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

genbyfuel_wind = Powerout.windon(end) .* normalisedpredictwind(end,:).Variables/100 ;
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

extractFinland = {'CHP_DH' 'CHP_Ind' 'other'} ;

thermalpower = sum(Powerout(:,extractFinland).Variables) ;

genbyfuel_thermal = thermalpower .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;
extracteurostat = {'gas' 'coal' 'oil' 'unknown' 'waste' 'biomass' 'peat'} ;

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), normalisedpredictthermal.Properties.VariableNames, 'UniformOutput', false) ;
normalisedpredictthermal.Properties.VariableNames = cat(1, replacestring{:}) ;

%%%% Check for limitation
incap.DHCHP = struct2table(installedcap.DHCHP.totalload) ;
incap.CHP_Ind = struct2table(installedcap.IndCHP.totalload) ;
incap.Sep = struct2table(installedcap.Sep.totalload) ;
    incap.Sep.biomass = 0 ;
    incap.Sep.other = 0 ;
sepfuel = incap.Sep.Properties.VariableNames ;

captotal  = array2table(incap.Sep(end,sepfuel).Variables + incap.CHP_Ind(end,sepfuel).Variables + incap.DHCHP(end,sepfuel).Variables,'VariableNames',sepfuel) ;
captotal.waste = 0 ;
eurostatcap = genbyfuel_thermal(end,strrep(extracteurostat,'other', 'unknown')) ;

changefuel = {'biomass' 'biomass'
                'coal' 'coal_chp'
                'unknown' 'unknown'
                'gas' 'gas'
                'oil' 'oil'
                'waste' 'waste'
                'peat' 'peat'} ;

replacestring = cellfun(@(x) changefuel(strcmp(changefuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;

% excessalloc = captotal.Variables - eurostatcap.Variables ;
% 
% init = normalisedpredictthermal(end,extracteurostat).Variables / 100 ;
% init(isnan(init)) = 0 ;
% newlimit = solver_rod(thermalpower, init, captotal(:,strrep(extracteurostat,'unknown', 'other'))) ;

% proddiff = installedcap(1,extractAustria).Variables - genbyfuel_thermal(:,extracteurostat).Variables ;
% toreallocate = abs(sum(proddiff(proddiff<0))) ;
% genbyfuel_thermal(:,extracteurostat).Variables = newlimit(:,extractFinland).Variables ;

tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear, genbyfuel_solar} ;

TTSync = synchronize(tables{:,:},'union','nearest');

% replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
% TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;