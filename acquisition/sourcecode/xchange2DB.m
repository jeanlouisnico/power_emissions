function xchange2DB(Power)

tablesql = 'xchange' ;
conn = connDB ;

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-2), filesep) ;

country_codein = {Power(:).zone}';

try
    sqlquery = ['SELECT id FROM ' tablesql ' ORDER BY id DESC LIMIT 1'];
    idtable = fetch(conn,sqlquery) ;
    
    if isempty(idtable)
        idmax = 0 ;
    else
        idmax = idtable.id ;
    end
    s(1).id = idmax  ;
    emdatabases = {'ENTSOE' 'TSO'} ;

    scount = 1 ;
    for icountry = 1:length(country_codein)
        for iemi = 1:length(emdatabases)           
            country_code = country_codein{icountry} ;
            
            switch emdatabases{iemi}
                case 'ENTSOE'
                     % Exchange ENTSOE
                    FileInfo = dir([fparts{1} filesep 'Xchange.json']) ;
                    datecompare = datetime('now') ;
                    datefile    = datetime(FileInfo.datenum, "ConvertFrom", "datenum") ;
                
                    % Check daily if the data have changed
                    if minutes(datecompare-datefile) >= 20
                        Xchnage = jsondecode(fileread([fparts{1} filesep 'Xchange.json']));
                        XChange_country = Xchnage.(country_code) ;   
                        
                        currenttime = datestr(datetime(XChange_country.Time,'InputFormat','dd-MMM-uuuu HH:mm:ss', 'TimeZone', 'UTC')) ;
                                            
                        tocountry = fieldnames(XChange_country) ;
                        
                        for i2cou = 1:numel(tocountry)
                            if ~strcmp(tocountry{i2cou},'Time')
                                s(scount).id = idmax + scount ;
                                s(scount).source = emdatabases{iemi} ;
                                s(scount).date_time = currenttime ;                    
                                s(scount).fromcountry = country_code ;   
                                s(scount).tocountry = tocountry{i2cou} ;
                                s(scount).powerexch = XChange_country.(tocountry{i2cou}) ;
                                scount = scount + 1 ;
                            end
                        end
                    end

                case 'TSO'
                    getcountry = ismember({Power.zone},country_code) ;
                    if ~isa(Power(getcountry).xCHANGE,"double")
                        % This means that there are no data from the TSO,
                        % use the data from ENTSOE
                        XChange_TSO = Power(getcountry).xCHANGE ;
                        tocountry = XChange_TSO.Properties.VariableNames ;
                        for i2cou = 1:numel(tocountry)
                            if ~strcmp(tocountry{i2cou},'Time')
                                s(scount).id = idmax + scount ;
                                s(scount).source = emdatabases{iemi} ;
                                s(scount).date_time = datestr(datetime(XChange_TSO.Time,'Format','dd-MMM-uuuu HH:mm:ss')) ;
                                s(scount).fromcountry = country_code ; 
                                s(scount).tocountry = tocountry{i2cou} ;
                                s(scount).powerexch = XChange_TSO.(tocountry{i2cou}) ;
                                scount = scount + 1 ;
                            end
                        end
                    end
            end
        end
    end
    try
        data = struct2table(s) ;
    catch
        data = struct2table(s, 'AsArray',true) ;
    end

    sqlwrite(conn,tablesql,data, 'ColumnType',["bigserial","timestamp","varchar(50)","varchar(50)","varchar(50)","float"]) ;
    executeSQLScript(conn,'clear_xchange_sql.sql') ;    
    close(conn) ;
catch
    close(conn) ;
end



