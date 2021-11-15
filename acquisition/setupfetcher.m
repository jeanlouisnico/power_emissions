function setupfetcher()

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;

if ~isfolder([filepath filesep 'setup'])
    mkdir([filepath filesep 'setup']) ;
end

if ~isfile([filepath filesep 'setup' filesep 'ini.json']) 
    % If it does does not exist, set up from scratch
    %%% Get the data for ENTSOE
    str = input('ENTSOE security token: ','s') ;
    setup.ENTSOE.securityToken = str ;
    %%% Get the data for Fingrid
    str = input('Fingrid security token: ','s') ;
    setup.Fingrid.securityToken = str ;
    %%% Set up the database
        % This requires to have postgresql installed on the computer or on
        % a remote machine
    n = 0 ;
    while n == 0
        setup = postgressetup(setup) ;
        % Try the postgresql connection    
        try
            conn = postgresql(setup.DB.username,setup.DB.password, ...
                              'PortNumber', str2double(setup.DB.port), ...
                              'Server', setup.DB.server, ...
                              'DatabaseName', setup.DB.name) ;
            n = 1 ;
            disp('connection successfull!!');
        catch
            warning('Could not connect to the postgreSQL database. Check that all the data are correct');
            setup.DB
            str = input('Do you want to re-initiliaze postgreSQL connection? [Y]/N ','s') ;
            if strcmp(str, 'Y') || strcmp(str, '')
                n = 0 ;
            else
                setup.DB = '' ;
                n = 1 ;
                warning('The postreSQL connection was not set, re-run this file if you want to set up again.')
            end
        end
    end
else
    % If it exist, display the settings and offer to overwrite the data.
    fileread([filepath filesep 'setup' filesep 'ini.json'])
    setup = jsondecode(fileread([filepath filesep 'setup' filesep 'ini.json']));
    
    n1 = 0 ;
    
    while n1 == 0
        str = input('Do you want to re-initiliaze some input? [Y]/N ','s') ;
        if strcmp(str, 'Y') || strcmp(str, '')
            n2 = 0 ;
            while n2 == 0
                str = input('Which variable would you like to reset? : ','s') ;
                switch str
                    case 'ENTSOE'
                        str = input('ENTSOE security token: ','s') ;
                        setup.ENTSOE.securityToken = str ;
                        n2 = 1 ;
                    case 'DB'
                        n3 = 0 ;
                        while n3 == 0
                            setup = postgressetup(setup) ;
                            % Try the postgresql connection    
                            try
                                conn = postgresql(setup.DB.username,setup.DB.password, ...
                                                  'PortNumber', str2double(setup.DB.port), ...
                                                  'Server', setup.DB.server, ...
                                                  'DatabaseName', setup.DB.name) ;
                                n3 = 1 ;
                                disp('connection successfull!!');
                            catch
                                warning('Could not connect to the postgreSQL database. Check that all the data are correct');
                                setup.DB
                                str = input('Do you want to re-initiliaze postgreSQL connection? [Y]/N ','s') ;
                                if strcmp(str, 'Y') || strcmp(str, '')
                                    n3 = 0 ;
                                else
                                    setup.DB = '' ;
                                    n3 = 1 ;
                                    warning('The postreSQL connection was not set, re-run this file if you want to set up again.')
                                end
                            end
                        end
                        n2 = 1 ;
                    case 'Fingrid'
                        str = input('Fingrid security token: ','s') ;
                        setup.Fingrid.securityToken = str ;
                        n2 = 1 ;
                    otherwise
                        warning('wrong input, try again')
                end
            end
            n1 = 0 ;
        else
            n1 = 1 ;            
            %warning('The postreSQL connection was not set, re-run this file if you want to set up again.')
        end
    end
    
end
try
    dlmwrite([filepath filesep 'setup' filesep 'ini.json'],jsonencode(setup, "PrettyPrint", true),'delimiter','');
    disp('Setup file has been written successfully');
    checkfile(filepath);
catch
    warning('Error in writing the ini file.')
end
%%%%%%%%% postgressetup %%%%%%%%%
    function setup = postgressetup(setup)
        str1 = input('Database server (leave empty if unknown): ','s') ;
            setup = postgresinput(setup, str1, 'server') ;
        str1 = input('Database username: ','s') ;
            setup = postgresinput(setup, str1, 'username') ;
        str1 = input('Database password: ','s') ;
            setup = postgresinput(setup, str1, 'password') ;
        str1 = input('Database port: ','s') ;
            setup = postgresinput(setup, str1, 'port') ;
        str1 = input('Database name: ','s') ;
            setup = postgresinput(setup, str1, 'name') ;
    end
    function setup = postgresinput(setup, str, attr)
        if isempty(str)
            switch attr
                case 'server'
                    setup.DB.(attr) = 'localhost' ; 
                case 'username'
                    setup.DB.(attr) = 'postgres' ; 
                case 'password'
                    setup.DB.(attr) = '' ; 
                case 'port'
                    setup.DB.(attr) = '5432' ; 
                case 'database'
                    setup.DB.(attr) = 'postgres' ; 
            end
        else
            setup.DB.(attr) = str ;
        end
    end
%%%%%%%%% postgressetup %%%%%%%%%
%%%%%%%%% Check input %%%%%%%%%
    function checkfile(filepath)
        setupin = jsondecode(fileread([filepath filesep 'setup' filesep 'ini.json']));
        checkfields = fieldnames(setupin) ;
        
        field2check = {'ENTSOE' 'Fingrid' 'DB'} ;
        for ifield = 1:length(field2check)
                switch field2check{ifield}
                    case {'ENTSOE', 'Fingrid'}
                        if isempty(setupin.(field2check{ifield}).securityToken)
                            warning(['Will not be able to get data from ' field2check{ifield} '. The model might not work properly'])
                        end
                    case 'DB'
                        if isempty(setupin.(field2check{ifield}))
                            warning('Will not be able to save the data into a database. Data will be written in an XML file on your drive')
                        end
                end
        end
    end
%%%%%%%%% Check input %%%%%%%%%
end
