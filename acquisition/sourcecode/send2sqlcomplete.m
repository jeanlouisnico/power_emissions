function send2sqlcomplete(datein, Emissions)

tablesql = 'emissions' ;

conn = connDB ;
try
    sqlquery = ['SELECT id FROM ' tablesql ' ORDER BY id DESC LIMIT 1'];
    idtable = fetch(conn,sqlquery) ;
    
    if isempty(idtable)
        idmax = 0 ;
    else
        idmax = idtable.id ;
    end
    s(1).id = idmax + 1 ;
    
    % alldata = sqlread(conn, 'emissions') ;
    % 
    % idmax = max(alldata.id) ;
    % 
    % if isempty(idmax)
    %     idmax = 0 ;
    % 	s(1).id = idmax + 1 ;
    % else
    % 	s(1).id = idmax + 1 ;
    % end
    
    countries = fieldnames(Emissions) ;
    emdatabases = {'EcoInvent' 'EM'} ;
    
    % id | date_time | country | emdb | emissionintprod | emissionintcons
    scount = 0 ;
    for icountry = 1:length(countries)
        for iemi = 1:length(emdatabases)
            scount = scount + 1 ;
            if scount > 1
                s(scount).id = idmax + scount ;
            end 
            switch emdatabases{iemi}
                case 'EcoInvent'
                    dbemi = 'EcoInvent' ;
                case 'EM'
                    dbemi = 'IPCC' ;
            end
            s(scount).date_time = datein ;
            s(scount).country   = countries{icountry} ;
            s(scount).emdb      = dbemi ;
            try
                s(scount).emissionintprod   = Emissions.(countries{icountry}).emissionskit.(dbemi).intensityprod ;
            catch
                s(scount).emissionintprod   = 0 ;
            end
            try
                s(scount).emissionintcons   = Emissions.(countries{icountry}).emissionskit.(dbemi).intensitycons ;
            catch
                s(scount).emissionintcons   = 0 ;
            end
        end
    end
    
    try
        data = struct2table(s) ;
    catch
        data = struct2table(s, 'AsArray',true) ;
    end
    sqlwrite(conn,'emissions',data, 'ColumnType',["bigserial","timestamp","varchar(50)","varchar(50)","float","float"]) ;
	    
    close(conn) ;
catch
    close(conn) ;
end
