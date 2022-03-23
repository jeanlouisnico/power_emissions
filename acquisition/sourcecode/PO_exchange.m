function TTSync = PO_exchange

% Get data from Polish TSO

data = webread('https://www.pse.pl/transmissionMapService') ;
d = datetime(data.timestamp/1000, 'ConvertFrom', 'posixtime','TimeZone', 'Europe/Warsaw') ;
d = datetime(d,'TimeZone','UTC') ;
T = struct2table(data.data.przesyly) ;
TTSync = array2timetable(T.wartosc', "RowTimes",d, 'VariableNames',T.id') ;