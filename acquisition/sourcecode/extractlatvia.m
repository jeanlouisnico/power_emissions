function powerout = extractlatvia

options = weboptions('Timeout',15) ;

timeextract = datestr(now, 'yyyy-mm-dd') ;

try 
    latviaprod = webread(['https://www.ast.lv/lv/ajax/charts/production?productionDate=' timeextract '&countryCode=LV'], options)  ;
catch
    latviaprod = 0 ;
end

t = latviaprod.data(1).data(end).x ;
d = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS') + hours(3) ;

powerout.thermal = latviaprod.data(1).data(end).y ;
powerout.unknown = latviaprod.data(2).data(end).y ;
powerout.wind = latviaprod.data(3).data(end).y ;
powerout.hydro = latviaprod.data(4).data(end).y ;
powerout.nuclear = latviaprod.data(5).data(end).y ;
powerout.production = latviaprod.data(6).data(end).y ;
powerout.consumption = latviaprod.data(7).data(end).y ;
powerout.import = latviaprod.data(8).data(end).y ;

