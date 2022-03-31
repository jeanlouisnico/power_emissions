function TTSync = BG

request = matlab.net.http.RequestMessage;
uri = matlab.net.URI('http://www.eso.bg/api/rabota_na_EEC_json.php');
r = send(request,uri);
power = struct('nuclear',0, 'thermal',0, 'hydro', 0,'wind',0,'solar',0, 'biomass',0,'consumption',0) ;
for itech = 1:length(r.Body.Data)
    if strfind(r.Body.Data{itech}{1},'АЕЦ') 
        power.nuclear = power.nuclear + r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Кондензационни') 
        power.thermal = power.thermal + r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Топлофикационни') 
        power.thermal = power.thermal + r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Заводски') 
        power.thermal = power.thermal + r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'ВЕЦ') 
        power.hydro = power.hydro + r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Малки') 
        power.hydro = power.hydro + r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'ВяЕЦ') 
        power.wind = r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'ФЕЦ') 
        power.solar = r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Био') 
        power.biomass = r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Товар') 
        power.consumption = r.Body.Data{itech}{2}  ;
    end
end


TTSync.TSO = table2timetable(struct2table(power),'RowTimes',datetime('now','TimeZone','UTC'));

d = TTSync.TSO.Time ;

elecfuel = retrieveEF ;

[alldata, ~] = fuelmixEU('Bulgaria', false, 'absolute') ;
alphadigit = countrycode('Bulgaria') ;

thermal = {'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900'} ;
predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;

genbyfuel_thermal = power.thermal .* normalisedpredictthermal(end,:).Variables/100 ;
genbyfuel_thermal = array2timetable(genbyfuel_thermal, "RowTimes", d, "VariableNames", thermal) ;
replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genbyfuel_thermal.Properties.VariableNames, 'UniformOutput', false) ;
genbyfuel_thermal.Properties.VariableNames = cat(1, replacestring{:}) ;

% tables = {genbyfuel_thermal, genbyfuel_wind, genbyfuel_hydro, genbyfuel_nuclear} ;

TTSync.emissionskit = genbyfuel_thermal ;

% replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
% TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

replacestr = {'wind' 'windon'
              'coal' 'coal_chp'
              'nuclear' 'nuclear_BWR'
              'solar' 'solar'
              'biomass' 'biomass'
              'hydro' 'hydro_runof'
              'unknown' 'unknown'
              'gas' 'gas'
              'oil' 'oil_chp'
              'waste' 'waste'} ;

TTSync.emissionskit = synchronize(TTSync.emissionskit, TTSync.TSO(:,{'nuclear' 'hydro' 'wind' 'solar' 'biomass'})) ;
replacestring = cellfun(@(x) replacestr(strcmp(replacestr(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

