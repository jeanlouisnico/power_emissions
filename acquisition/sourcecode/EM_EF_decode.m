function emDB = EM_EF_decode
warning('OFF', 'all' )

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

val = jsondecode(fileread([fparts{1} filesep 'input' filesep 'co2eq_parameters.json']));

allzones = fieldnames(val.emissionFactors.zoneOverrides) ;

originaltech = {'biomass';'blast_furnace';'coal';'coal_chp';'gas';'gas_chp';'hard_coal';'hydro_pumped';'hydro_reservoir';'hydro_runof';'nuclear_BWR';'nuclear_PWR';'oil';'oil_chp';'other_biogas';'other_waste';'peat';'solar';'unknown';'waste';'windon'} ;

eq_tech = {'batteryCharge' ''
           'batteryDischarge' ''
           'biomass'        'biomass'
           'coal'           'coal'
           'coal'           'coal_chp'
           'coal'           'hard_coal'
           'coal'           'blast_furnace'
           'gas'            'gas'
           'gas'            'gas_chp'
           'geothermal'     'geothermal'
           'hydro'          'hydro_runof'
           'hydroCharge'    'hydro_pumped'
           'hydroDischarge' 'hydro_pumped'
           'hydro'          'hydro_reservoir'     
           'nuclear'        'nuclear_BWR'
           'nuclear'        'nuclear_PWR'
           'oil'            'oil'
           'oil'            'oil_chp'
           'solar'          'solar'
           'unknown'        'other_biogas'
           'unknown'        'peat'
           'unknown'        'waste'
           'unknown'        'unknown'
           'unknown'        'other_waste'
           'wind'           'windon' 
           } ;
index = 0 ;

for itech = 1:length(originaltech) 
    techname = eq_tech(strcmp(eq_tech(:,2), originaltech{itech}), 1) ;
    for izone = 1:length(allzones)
        index = index + 1 ;
        %%% Fetch the value
        emDB(index).Technology = originaltech{itech} ;
        emDB(index).Country = allzones{izone} ;
        emDB(index).GlobalWarming = val.emissionFactors.defaults.(techname{1}).value ;
    end
end
emDB = struct2table(emDB) ;
%% Special value

for izone = 1:length(allzones)
    index = index + 1 ;
    techlist = fieldnames(val.emissionFactors.zoneOverrides.(allzones{izone})) ;
    for itech = 1:length(techlist)
        alltechchnage = eq_tech(strcmp(techlist{itech}, eq_tech(:,1)), 2) ;
        for itechchange = 1:length(alltechchnage)
            tech2change = alltechchnage{itechchange} ;
            row = find((strcmp(tech2change, emDB.Technology) & strcmp(allzones{izone}, emDB.Country)) == 1) ;
            if ~isempty(row)
                if length(row) > 1
                    % There is a problem
                    x = 1 ;
                else
                    emDB.GlobalWarming(row) = val.emissionFactors.zoneOverrides.(allzones{izone}).(techlist{itech}).value ;
                end
            else
                % This entry does not exist, create it
                emDB.Technology{end + 1} = techlist{itech} ;
                emDB.Country{end} = allzones{izone} ;
                emDB.GlobalWarming(end) = val.emissionFactors.zoneOverrides.(allzones{izone}).(techlist{itech}).value ;
            end
        end
    end
    switch allzones{izone}
        case 'RU'
            emDB.Technology{end + 1} = 'TES' ;
            emDB.Country{end} = 'RU' ;
            emDB.GlobalWarming(end) =   val.emissionFactors.zoneOverrides.(allzones{izone}).unknown.value ;
    end
    %%% Fetch the value
end

warning('OFF', 'all' )
