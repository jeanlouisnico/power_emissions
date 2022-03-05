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
          
currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

timeextract = datetime('now', 'Format','yyyy.MM.dd', 'TimeZone','Europe/Moscow') ;

url = ['http://br.so-ups.ru/webapi/api/CommonInfo/PowerGeneration?priceZone[]=1&startDate=' ...
        char(timeextract) '&endDate=' ...
        char(timeextract)] ;
data = webread(url);

Power.bytech = data.m_Item2(timeextract.Hour + 1) ;

bytech.nuclear = Power.bytech.P_AES ;
bytech.solar = Power.bytech.P_REN ;
bytech.oil = Power.bytech.P_BS ;
bytech.thermal = Power.bytech.P_TES ;
bytech.hydro = Power.bytech.P_GES ;

byfuel.nuclear = bytech.nuclear ;
byfuel.hydro   = bytech.hydro ;
byfuel.solar   = bytech.solar ;
byfuel.oil     = .023 * bytech.thermal + 2/3 * bytech.oil ;
byfuel.coal    = .4406 * bytech.thermal ;
byfuel.gas     = .5364 * bytech.thermal  + 1/3 * bytech.oil ;

Powerout.TSO = table2timetable(struct2table(bytech),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;
Powerout.emissionskit = table2timetable(struct2table(byfuel),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;