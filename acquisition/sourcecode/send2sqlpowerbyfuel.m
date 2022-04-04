function send2sqlpowerbyfuel(datein, Power)
tablesql = 'powerbyfuel' ;
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
    
    % alldata = sqlread(conn, 'powerbyfuel') ;
    % 
    % idmax = max(alldata.id) ;
    % 
    % if isempty(idmax)
    %     idmax = 0 ;
    % 	s(1).id = idmax + 1 ;
    % else
    % 	s(1).id = idmax + 1 ;
    % end
    
    countries = {Power(:).zone}' ;
    powerdatabases = {'ENTSOE' 'TSO'} ;

    % id | date_time | country | fuel | power_generated | powersource
    
    scount = 0 ;
    for icountry = 1:length(countries)
        country_code = countries{icountry} ;

        for iemi = 1:length(powerdatabases)
            try
                switch powerdatabases{iemi}
                    case 'TSO'  
                        Powerin  = Power(icountry).TSO.emissionskit ;  
                        allfuels = Powerin.Properties.VariableNames ;
                        if isa(allfuels,'double')
                            continue ;
                        end
                    case 'ENTSOE'
                        Powerin  = Power(icountry).ENTSOE.bytech.(country_code) ;
                        Powerin  = aggregated_power_ENTSOE(Powerin, country_code) ;
                        allfuels = fieldnames(Powerin) ;
                        if isempty(allfuels)
                            continue ;
                        end
                end
            catch
                continue ;
            end
            
            for ifuel = 1:length(allfuels)
                scount = scount + 1 ;
                if scount > 1
                    s(scount).id = idmax + scount ;
                end 
    
                s(scount).date_time = datein ;
                s(scount).country   = country_code ;
                s(scount).fuel      = allfuels{ifuel} ;
                s(scount).powersource   = powerdatabases{iemi} ;
                try
                    s(scount).power_generated   = Powerin.(allfuels{ifuel}) ;
                catch
                    s(scount).power_generated   = 0 ;
                end
                
            end
        end
    end
    
    try
        data = struct2table(s) ;
    catch
        data = struct2table(s, 'AsArray',true) ;
    end
    sqlwrite(conn,'powerbyfuel',data, 'ColumnType',["bigserial","timestamp","varchar(50)","varchar(50)","VARCHAR(50)","float"]) ;
	    
    close(conn) ;
catch
    close(conn) ;
end
