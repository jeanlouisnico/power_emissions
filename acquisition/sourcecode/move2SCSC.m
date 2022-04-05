function move2SCSC

conn = connDB ;
tablename_psql = 'emissions' ;
%Get the latest entry from the emissions data
% datestart     = datestr(currentdate - hours(24), 'yyyy-mm-dd HH:MM:SS') ;

sqlquery = ['SELECT date_time FROM ' tablename_psql ' ORDER BY id DESC LIMIT 1'];
    idtable = fetch(conn,sqlquery) ;


datein = idtable.date_time ;


sqlquery = ['SELECT * FROM ' tablename_psql ' WHERE date_time>=''' char(datein) ''''];
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
    reparsedata(i_id).id = s ; %     2022-04-04 16:10:17
    reparsedata(i_id).date_time = datetime(reparsedata(i_id).date_time,'Format','uuuu-MM-dd HH:mm:SS')  ;
    
end

    try
        data = struct2table(reparsedata) ;
    catch
        data = struct2table(reparsedata, 'AsArray',true) ;
    end

sqlwrite(conn_online,'emissions',data, 'ColumnType',["bigserial","timestamp","varchar(50)","varchar(50)","float","float"]) ;

close(conn) ;
close(conn_online) ;