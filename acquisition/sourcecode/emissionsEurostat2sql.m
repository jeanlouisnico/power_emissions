function emissionsEurostat2sql(data)

conn = postgresql('uoulu','rxelmhrhjF3!', 'PortNumber', 5432, 'Server', '128.214.253.150', 'DatabaseName', 'making_city_emissions') ;

tablesql = 'emissionsEurostat' ;

sqlquery = ['SELECT id FROM ' tablesql ' ORDER BY id DESC LIMIT 1'];
idtable = fetch(conn,sqlquery) ;

if isempty(idtable)
	id =  0 ;
else
	id = idtable.id ;
end

% Query the data in the sql to check it is already there, if not, add a new
% row with the correct id number.
allgeo = fieldnames(data) ;
fillinrow = 0 ;
s = struct ;
for igeo = 1:length(allgeo)
    geoname = allgeo{igeo} ;
    alldata = data.(geoname) ;
    allfuels = alldata.Properties.VariableNames ;
    for ifuel = 1:length(allfuels)
        fuelname = allfuels{ifuel} ; 
        for idate = 1:length(data.(geoname).Time)
            date = data.(geoname).Time(idate) ;
            date = datestr(date, 'yyyy-mm-dd') ;
            sqlquery = ['SELECT * FROM ' tablesql ' WHERE fuel=''' fuelname '''' ' and date_time=''' date '''' ' and country=''' geoname ''''] ;
            idtable = fetch(conn,sqlquery) ;
            if isempty(idtable)
                fillinrow = fillinrow + 1 ;
                id = id + 1 ;
                s(fillinrow).id = id ;
                s(fillinrow).date_time = date;
                s(fillinrow).country = geoname ;
                s(fillinrow).fuel = fuelname ;
                s(fillinrow).valuel = data.(geoname).(fuelname)(idate) ;
            end
        end
    end
end
if isempty(fieldnames(s))
    return ;
end
datain = struct2table(s);
writetable(datain, 'tempdata.csv', "WriteVariableNames", false) ;

fid = fopen('tempdata.csv','rt');
fid2 = fopen('temp2.sql', 'w');

fprintf(fid2, '%s\n', 'INSERT INTO');
fprintf(fid2, '%s\n', [tablesql '(id, date_time, country, fuel, valuel)']);
fprintf(fid2, '%s', 'VALUES');
loop = 1 ;
while true
  thisline = fgetl(fid);
  if ~ischar(thisline); break; end  %end of file
    %now check whether the string in thisline is a "word", and store it if it is.
    %then
    if loop > 1
        fprintf(fid2, '%s', ',');
    end
    C = strsplit(thisline,',') ;
    C = ['(' C{1} ',''' strjoin(C(2:end),''',''') '''' ')'] ;
    fprintf(fid2, '\n%s', C);
    loop = 2 ;
end

fprintf(fid2, '\n%s', 'RETURNING *;');

fclose(fid2);

% executeSQLScript(conn,'powerbyfuelhist.sql') ;

scriptfile = 'temp2.sql';
executeSQLScript(conn,scriptfile) ;

sqlwrite(conn,tablesql,datain, 'ColumnType',["bigserial","date","varchar(50)","varchar(50)","numeric"]) ;
