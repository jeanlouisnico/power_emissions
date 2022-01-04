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

timeextract = datetime(datetime(datestr(now)), 'Format','yyyy.MM.dd') ;

url = ['http://br.so-ups.ru/webapi/api/CommonInfo/PowerGeneration?priceZone[]=1&startDate=' ...
        char(timeextract) '&endDate=' ...
        char(timeextract)] ;
data = webread(url);

Power = data.m_Item2(timeextract.Hour + 1) ;

Powerout.nuclear = Power.P_AES ;
Powerout.solar = Power.P_REN ;
Powerout.oil = Power.P_BS ;
Powerout.thermal = Power.P_TES ;
Powerout.hydro = Power.P_GES ;

