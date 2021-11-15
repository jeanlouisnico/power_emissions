function conn = connDB

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;
setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));


conn = postgresql(setup.DB.username,setup.DB.password, ...
                  'PortNumber', str2double(setup.DB.port), ...
                  'Server', setup.DB.server, ...
                  'DatabaseName', setup.DB.name) ;
