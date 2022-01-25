function setupdb_psql(dbname)

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

fid = fopen(fullfile(fparts{1},'setup', 'createdb.sql'), 'w');
if fid == -1
  error('Cannot open createdb.sql file.');
end
fprintf(fid, '%s %s %s\n', 'CREATE DATABASE', dbname, ';');
fclose(fid);