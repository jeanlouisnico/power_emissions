function alldata = rekisterypostgre(update)

% This needs to be modified since the DB has to be set up before in the
% postgres database

conn = connDB ;

tablename = 'rekistery_fi' ;

alldata                 = sqlread(conn, tablename) ;
if isempty(alldata)
    update = true ;
else
    alldata.mainfuel    	= fillmissing(alldata.mainfuel,'constant',"");
    alldata.standbyfuel     = fillmissing(alldata.standbyfuel,'constant',"");
    alldata.standbyfuel_1   = fillmissing(alldata.standbyfuel_1,'constant',"");
end

if update
    feature('DefaultCharacterSet','UTF-8') ;
    filename = 'Energiaviraston voimalaitosrekisteri.xlsx' ;
    %%%
    % Determine where demo folder is.
    folder = fileparts(which(filename)) ;
    fullFileName = fullfile(folder, filename);
    [~, sheetNames] = xlsfinfo(fullFileName) ;
    
    numSheets = length(sheetNames) ;
    n = 0 ;
    i = 0 ;
    while n == 0
        i = i + 1 ;
        if i > numSheets
            errordlg('Missing file name in English');
            return ;
        elseif strcmp(sheetNames{i}, 'English')
            warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
            t1 = readtable(fullFileName, 'Sheet', i) ;
            n = 1 ;
            warning('ON', 'MATLAB:table:ModifiedAndSavedVarnames')
        end
    end
    idmax = max(alldata.id) ;

    if isempty(idmax)
        idmax = 0 ;
    end
    data = addvars(t1,[1:height(t1)]','Before','Name','NewVariableNames', 'id') ;
    sqlwrite(conn,tablename,data, 'ColumnType',["bigserial","varchar(100)","varchar(100)","varchar(100)","varchar(100)","varchar(100)","integer","varchar(100)","varchar(100)","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","varchar(100)","varchar(100)","varchar(100)"]) ;
    alldata = rekisterypostgre(false) ;
end

