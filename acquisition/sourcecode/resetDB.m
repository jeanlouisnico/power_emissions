function resetDB
% Use with caution, this delete all the tables and everything that was
% recorded previously, are you sure you want to reset the table?

str = input(['Use with caution, this delete all the tables and everything that was \n' ...
            'recorded previously, are you sure you want to reset the table? [Y]/N '],'s') ;

if strcmp(str, 'Y') || strcmp(str, '')
    conn = connDB ;
    executeSQLScript(conn,'resetDB.sql') ;
    disp('!! all tables were reset successfully !!');
else
    disp('!! nothing happened, tables were preserved !!');
end

