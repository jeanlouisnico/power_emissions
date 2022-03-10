function TTSync = UK


fuel = {'biomass' 'biomass'
        'hydro_pumped_storage' 'hydro_pumped'
        'hydro_run_of_river_and_poundage' 'hydro_runof'
        'fossil_hard_coal' 'coal'
        'fossil_gas' 'gas'
        'fossil_oil' 'oil'
        'nuclear' 'nuclear'
        'other' 'mean'
        'wind_onshore' 'windon'
        'wind_offshore' 'windoff'
        'solar' 'solar'} ;

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-2), filesep) ;
setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

securitytoken = setup.bmreports.securityToken ;

currentdate = datetime('now','Format','uuuu-MM-dd','TimeZone','Europe/London') ;
format = 'csv' ;
period = '*' ;
report = 'B1620' ;

data = webread(['https://api.bmreports.com/BMRS/' report '/v1?APIKey=' securitytoken '&SettlementDate=' char(currentdate) '&Period=' period '&ServiceType=' format]) ;

extractlatesthour = max(data.SettlementPeriod(1:end-1)) ;

timearray = datetime(data.SettlementDate(data.SettlementPeriod == extractlatesthour),'Format','dd/MM/uuuu HH:mm:ss','TimeZone','Europe/London') + hours(extractlatesthour/2) ;
source = data.PowerSystemResourceType(data.SettlementPeriod == extractlatesthour) ;
production = data.Quantity(data.SettlementPeriod == extractlatesthour) ;

source_valid = makevalidstring(source) ;

for isource = 1:length(source_valid)
    tech = source_valid{isource} ;
    out.(tech) = production(isource) ;
end

TTSync.TSO = table2timetable(struct2table(out),'RowTimes',timearray(1)) ;

replacestring = cellfun(@(x) fuel(strcmp(fuel(:,1),x),2), TTSync.TSO.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.TSO.Properties.VariableNames = cat(1, replacestring{:}) ;

