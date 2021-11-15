function Powerout = extractSweden


Powerindex = {'production', ...
              'nuclear', ...
              'hydro', ...
              'thermal', ...
              'wind', ...
              'unknown', ...
              'consumption'} ;

currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

timeextract = datetime(datetime(datestr(now)) - hours(timezone), 'Format','yyyy-MM-dd') ;

url = ['https://www.svk.se/ControlRoom/GetProductionHistory/?productionDate=' char(timeextract) '&countryCode=SE'] ;
data = webread(url);

for itech = 1:length(data)
    Time = datetime(datestr(datenum(1970,1,1, timezone, 0, 0) + ([data(itech).data(:).x]/1000)/(24*3600))) ;
    Power.(Powerindex{data(itech).name}) = timetable([data(itech).data(:).y]', 'RowTimes', Time) ;
end

for itech = 1:length(data)
    Powerextract = tail(Power.(Powerindex{data(itech).name}), 1) ;
%     Powerout.Time = Powerextract.Time ;
    Powerout.(Powerindex{data(itech).name}) = Powerextract.Var1 ;
end