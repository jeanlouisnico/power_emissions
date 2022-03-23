function XChange = PTXChange

dtLCL = datetime('now', 'TimeZone','local')       ;  
timePT = datetime(dtLCL, 'TimeZone', 'Europe/Lisbon');

sqltime  = (datenum(timePT) * (24*60*60) - ((367)*24*60*60))*10^7 ;

data = webread(['https://datahub.ren.pt/api/Electricity/ImportBalance/1395?culture=en-GB&dayToSearchString=' char((compose("%d",round(sqltime))))]) ;

power.(makevalidstring(data.series(2).name)) = data.series(2).data ;
power.(makevalidstring(data.series(1).name)) = data.series(1).data  ;

power.imports(isnan(power.imports)) = 0 ;
power.exports(isnan(power.exports)) = 0 ;

ES = power.imports + power.exports ;

timeaxis = data.xAxis.categories(1:length(power.exports)) ;

decompose_time = cellfun(@(x) strsplit(x,':'),timeaxis,'UniformOutput',false) ;
timearray = cellfun(@(x) datetime(timePT.Year,timePT.Month, timePT.Day, str2double(x(1)), str2double(x(2)), 0), decompose_time, 'UniformOutput',false) ;
timearray = [timearray{:}]';

XChange = array2timetable(ES,'RowTimes',timearray) ;

% timearray = data.xAxis.categories ;
