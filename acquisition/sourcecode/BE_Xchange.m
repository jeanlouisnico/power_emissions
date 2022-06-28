function xCHANGE = BE_Xchange

dtLCL = datetime('now', 'TimeZone','local')       ;  
timeBE = datetime(dtLCL, 'TimeZone', 'Europe/Brussels') ;

datein = datestr(timeBE, 'yyyy-mm-dd') ;

zone = {'FR' 'NL' 'UK' 'LX' 'GE'} ;

for izone = 1:length(zone)       
    try
        data = webread(['https://griddata.elia.be/eliabecontrols.prod/interface/crossbordercapacities/LoadData?mnemonic=BDN=' zone{izone} '&reference=' datein]) ;
    catch
        solar(1).startsOn = datetime(timeBE,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC') ;
        solar(1).realTime = 0 ;
        continue ;
    end
    alltime = datetime(cat(1, data(2).meetring(:).key) , 'Format', 'uuuu-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC') ;
    dataout = [data(2).meetring(:).value]' ;
    switch zone{izone}
        case 'GE'
            exchange.DE = -dataout(end) ;
        case 'UK'
            exchange.GB = -dataout(end) ;
        case 'LX'
            exchange.LU = -dataout(end) ;
        otherwise
            exchange.(zone{izone}) = -dataout(end) ;
    end
end
xCHANGE = table2timetable(struct2table(exchange),'RowTimes',alltime(end)) ;