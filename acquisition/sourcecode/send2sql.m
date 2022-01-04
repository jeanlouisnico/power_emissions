function send2sql(datein, value)

tablename = 'emissions_fin' ;

conn = connDB ;
try
    alldata = sqlread(conn, tablename) ;
    
    idmax = max(alldata.id) ;
    
    if isempty(idmax)
	    s.id = 1 ;
    else
	    s.id = idmax + 1 ;
    end
	    
    s.date_time = datein ;
    
    s.emissionintensity = value ;
    
    try
        data = struct2table(s) ;
    catch
        data = struct2table(s, 'AsArray',true) ;
    end
    sqlwrite(conn,'emissions_fin',data, 'ColumnType',["bigserial","timestamp","float"]) ;
	    
    close(conn) ;
catch
    close(conn) ;
end
