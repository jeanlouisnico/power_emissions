function power = BG

request = matlab.net.http.RequestMessage;
uri = matlab.net.URI('http://www.eso.bg/api/rabota_na_EEC_json.php');
r = send(request,uri);
power = struct('nuclear',0, 'coal',0,'gas',0, 'hydro', 0,'wind',0,'solar',0, 'biomass',0,'consumption',0) ;
for itech = 1:length(r.Body.Data)
    if strfind(r.Body.Data{itech}{1},'АЕЦ') 
        power.nuclear = power.nuclear + r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Кондензационни') 
        power.coal = r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Топлофикационни') 
        power.gas = r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Заводски') 
        power.gas = r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'ВЕЦ') 
        power.hydro = r.Body.Data{itech}{2}  ;
    elseif strfind(r.Body.Data{itech}{1},'Малки') 
        power.hydro = r.Body.Data{itech}{2}  ;
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