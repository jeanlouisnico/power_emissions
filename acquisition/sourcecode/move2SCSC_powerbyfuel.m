function move2SCSC_powerbyfuel

conn = connDB ;
tablename_psql = 'powerbyfuel' ;
% Get the latest entry from the emissions data
% datestart     = datestr(currentdate - hours(24), 'yyyy-mm-dd HH:MM:SS') ;

sqlquery = ['SELECT date_time FROM ' tablename_psql ' ORDER BY id DESC LIMIT 1'];
    idtable = fetch(conn,sqlquery) ;

datein = idtable.date_time ;

sqlquery = ['SELECT * FROM ' tablename_psql ' WHERE date_time>=''' char(datein) ''' AND country=''FI''' ];
    data = fetch(conn,sqlquery) ;

    reparsedata = table2struct(data) ;
    
% Get the data from online
conn_online = postgresql('uoulu','rxelmhrhjF3!', 'PortNumber', 5432, 'Server', '128.214.253.150', 'DatabaseName', 'making_city_emissions') ;
sqlquery = ['SELECT id FROM ' tablename_psql ' ORDER BY id DESC LIMIT 1'];
    idtable = fetch(conn_online,sqlquery) ;
    
    if isempty(idtable)
        idmax = 0 ;
    else
        idmax = idtable.id ;
    end
s = idmax ;

for i_id = 1:length(reparsedata)
    s = s + 1 ;
    reparsedata(i_id).id = s ;
    reparsedata(i_id).date_time = datetime(reparsedata(i_id).date_time,'Format','uuuu-MM-dd HH:mm:SS')  ;
end

    try
        data = struct2table(reparsedata) ;
    catch
        data = struct2table(reparsedata, 'AsArray',true) ;
    end

data = movevars(data,'powersource','After','power_generated') ;

sqlwrite(conn_online,'powerbyfuel',data, 'ColumnType',["bigserial","timestamp","varchar(50)","varchar(50)","VARCHAR(50)","float"]) ;

close(conn) ;
close(conn_online) ;