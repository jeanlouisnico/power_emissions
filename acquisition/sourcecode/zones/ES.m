function TTSync = ES
% https://apidatos.ree.es/es/datos/generacion/estructura-generacion?start_date=2014-01-01T00:00&end_date=2018-12-31T23:59&time_trunc=year&geo_trunc=electric_system&geo_limit=ccaa&geo_ids=7
% start_date  = '2018-12-31T00:00' ;
% end_date    = '2018-12-31T23:59' ;

dtLCL = datetime('now', 'TimeZone','local')       ;  
timeSpain = datetime(dtLCL, 'TimeZone', 'Europe/Madrid') ;

timeres = 'day' ;
region = 'ccaa' ;

timearr = timeSpain ; 
outtable = struct ;
for iyear = 1:length(timearr)
    currentdate = timearr(iyear) ;
    filename = 'sunspots_annual.txt';
    websave(filename,...
            ['https://demanda.ree.es/WSvisionaMovilesPeninsulaRest/resources/demandaGeneracionPeninsula?callback=angular.callbacks._6&curva=DEMANDA&fecha=' ...
            sprintf('%02d',currentdate.Year) '-' ...
            sprintf('%02d',currentdate.Month) '-' ...
            sprintf('%02d',currentdate.Day)]) ;
    data = fileread('sunspots_annual.txt') ;
    data = erase(data,'angular.callbacks._6({"valoresHorariosGeneracion":[');
    data = split(data,'{') ;
    for itime = 1:length(data)
        datab1 = data{itime} ;
        if ~isempty(datab1)
            datab1 = erase(datab1,'}') ;
            datab2 = split(datab1,',') ;
            for itech = 1:length(datab2)
                datab3 = split(datab2{itech},':') ;
                if strcmp(datab3{1},'"ts"')
                    timevar = [datab3{2} ':' datab3{3}] ;
                    timevar = erase(timevar,'"') ;
                    try 
                        timevar = datetime(timevar,'InputFormat','yyyy-MM-dd HH:mm') ;
                    catch
                        timevar = outtable.Time(end) +  minutes(10) ;
                    end
                    if isfield(outtable, 'Time')
                        outtable.Time(end + 1,1) = timevar ;
                    else
                        outtable.Time = timevar ;
                    end
                elseif ~isempty(datab3{1})
                    varname = datab3{1} ;
                        varname = erase(varname,'"') ;
                    varvalue = str2double(datab3{2}) ;
                    if strcmp(varname,'cogenResto')
                        x = 1 ;
                    end
                    if isfield(outtable, varname)
                        outtable.(varname)(end + 1,1) = varvalue ;
                    else
                        if isfield(outtable, 'Time')
                            index = length(outtable.Time) ;
                        else
                            index = 1 ;
                        end
                        outtable.(varname)(index,1) = varvalue ;
                    end
                    
                end
            end
        end
    end
end

generation = struct2table(outtable) ;
spainTT = table2timetable(generation, 'RowTimes', generation.Time) ;
spainTT.Time = datetime(spainTT.Time, 'TimeZone', 'Europe/Madrid') ;
% writetable(generation,'2021_Spain.csv') ;
% disp('--- extraction done ---') ;

spaindata = { 'dem'	'demand'
                'eol'	'wind'
                'nuc'	'nuclear'
                'gf'	'gas'
                'car'	'coal'
                'cc'	'gas_chp'
                'hid'	'hydro'
                'aut'	''
                'inter'	''
                'icb'	''
                'sol'	'solar'
                'solFot'	'solar_PV'
                'solTer'	'solar_ther'
                'termRenov'	'biomass'
                'cogenResto'	'waste'} ;

extractdata = {'dem' 'eol' 'nuc' 'gf' 'car' 'cc' 'hid' 'sol' 'solFot' 'solTer' 'termRenov' 'cogenResto'} ;

TTSync.TSO = spainTT(end, extractdata) ;

TTSync.TSO.Properties.DimensionNames{1} = 'Time' ;
TTSync.TSO.Time.TimeZone = 'Europe/Madrid' ;
replacestring = cellfun(@(x) spaindata(strcmp(spaindata(:,1),x),2), TTSync.TSO.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.TSO.Properties.VariableNames = cat(1, replacestring{:}) ;

elecfuel = retrieveEF ;

% In this case, we consider that combined cycle is mainly made of gas chp
% units based on the statistics of powerplants placed in the CC category in
% REE.



[alldata, ~] = fuelmixEU('Spain', false, 'absolute') ;
alphadigit = countrycode('Spain') ;


%%%% Wind is not considered in the split between onshore and offshore since
%%%% the eurostat data does not include them for some reason.

% nuclear = {'N9000'} ;
hydro = {'RA110' 'RA120' 'RA130'} ;
% thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900'} ;
predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredicthydro = array2timetable(bsxfun(@rdivide, predictedfuel(:,hydro).Variables, sum(predictedfuel(:,hydro).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', hydro) ;

genbyfuel_hydro = TTSync.TSO.hydro(end) .* normalisedpredicthydro(end,:).Variables/100 ;
genbyfuel_hydro = array2timetable(genbyfuel_hydro, "RowTimes", TTSync.TSO.Time(end), "VariableNames", hydro) ;

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_hydro.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_hydro.Properties.VariableNames = cat(1, replacestring{:}) ;

TTSync.emissionskit = TTSync.TSO ;

TTSync.emissionskit = removevars(TTSync.emissionskit, 'hydro') ;
TTSync.emissionskit = synchronize(TTSync.emissionskit, genbyfuel_hydro) ;

TTSync.TSO = convertTT_Time(TTSync.TSO,'UTC') ;
TTSync.emissionskit = convertTT_Time(TTSync.emissionskit,'UTC') ;