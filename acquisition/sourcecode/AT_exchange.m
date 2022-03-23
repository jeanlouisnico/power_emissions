function XChange = AT_exchange

currenttime = datetime("now",'TimeZone','Europe/Vienna','Format','uuuu-MM-dd''T') ;

data = webread(['https://transparency.apg.at/transparency-api/api/v1/Data/CBPF/English/M15/' char(currenttime) '000000/' char(currenttime + caldays(1)) '000000']) ;

headers = {data.ResponseData.ValueColumns.InternalName} ;
headers = cellfun(@(x) x(1:2), headers, 'UniformOutput', false) ;

%%% Find the last entry
n = 0 ;
i = 0 ;
while n == 0
    i = i + 1 ;
    datain = [data.ResponseData.ValueRows(i).V.V]' ;
    if isempty(datain)
        n = 1 ;
        i = i - 1 ;
        dataout = [data.ResponseData.ValueRows(i).V.V]' ;
    elseif i == 96
        n = 1 ;
        dataout = [data.ResponseData.ValueRows(i).V.V]' ;
    end
end

timestr = [data.ResponseData.ValueRows(i).DT ' ' data.ResponseData.ValueRows(i).TT] ;
timestr = datetime(timestr, 'Format', 'dd/MM/uuuu HH:mm','TimeZone','Europe/Vienna') ;
timestr = datetime(timestr,'TimeZone','UTC') ;
XChange = array2timetable(dataout',"RowTimes",timestr,'VariableNames',headers) ;