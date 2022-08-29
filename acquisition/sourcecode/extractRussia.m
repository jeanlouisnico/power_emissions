function Powerout = extractRussia

Powerindex = {'production', ...
              'nuclear', ...
              'hydro', ...
              'thermal', ...
              'wind', ...
              'unknown', ...
              'consumption'} ;
%%% Technology abbreviation
%     'P_AES': 'nuclear',
%     'P_GES': 'hydro',
%     'P_GRES': 'unknown',
%     'P_TES': 'unknown',
%     'P_BS': 'unknown',
%     'P_REN': 'solar'
          
timeextract = datetime('now', 'Format','yyyy.MM.dd', 'TimeZone','Europe/Moscow') ;

url = ['http://br.so-ups.ru/webapi/api/CommonInfo/PowerGeneration?priceZone[]=1&startDate=' ...
        char(timeextract) '&endDate=' ...
        char(timeextract)] ;
try
    data = webread(url);
    Power.bytech = data.m_Item2(timeextract.Hour + 1) ;

    bytech.nuclear_BWR = Power.bytech.P_AES ;
    bytech.solar = Power.bytech.P_REN ;
    bytech.oil = Power.bytech.P_BS ;
    bytech.thermal = Power.bytech.P_TES ;
    bytech.hydro_runof = Power.bytech.P_GES ;
    
    byfuel.nuclear_BWR = bytech.nuclear_BWR ;
    byfuel.hydro_runof   = bytech.hydro_runof ;
    byfuel.solar   = bytech.solar ;
    byfuel.oil     = .023 * bytech.thermal + 2/3 * bytech.oil ;
    byfuel.coal    = .4406 * bytech.thermal ;
    byfuel.gas     = .5364 * bytech.thermal  + 1/3 * bytech.oil ;
    
    Powerout.TSO = table2timetable(struct2table(bytech),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;
    Powerout.emissionskit = table2timetable(struct2table(byfuel),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;

    Powerout.emissionskit = convertTT_Time(Powerout.emissionskit,'UTC') ;
    Powerout.TSO = convertTT_Time(Powerout.TSO,'UTC') ;

catch
    bytech.nuclear_BWR = 0 ;
    bytech.solar = 0 ;
    bytech.oil = 0 ;
    bytech.thermal = 0 ;
    bytech.hydro_runof = 0 ;
    
    byfuel.nuclear_BWR = 0 ;
    byfuel.hydro_runof   = 0 ;
    byfuel.solar   = 0 ;
    byfuel.oil     = 0 ;
    byfuel.coal    = 0 ;
    byfuel.gas     = 0 ;

    Powerout.TSO = table2timetable(struct2table(bytech),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;
    Powerout.emissionskit = table2timetable(struct2table(byfuel),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;

    Powerout.emissionskit = convertTT_Time(Powerout.emissionskit,'UTC') ;
    Powerout.TSO = convertTT_Time(Powerout.TSO,'UTC') ;

    return ;
end

