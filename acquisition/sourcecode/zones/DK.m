
function TTSync = DK

pe = pyenv;
if isempty(pe.Version)
    errorlog("Python not installed - Cannot fetch Denmark TSO data --> solution, install python for your machine and define it in MatLab through the PythonEnvironment function") ;
    return ;
end

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-2), filesep) ;
setup_ini = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

try
    pythonpath = setup_ini.python.environment ;
catch
    errorlog("Python environment not defined - Cannot fetch Denmark TSO data --> solution, create a python environment with the required packages. Define the path of this envs in the setupfetcher function") ;
    return ;
end

if ~strcmp(pythonpath(end),filesep)
    pythonpath = [pythonpath filesep] ;
end
system([pythonpath 'python ' '"' filepath filesep 'DK_request.py"']) ;

setup = jsondecode(fileread('data.json'));

alldata = setup.data.electricityprodex5minrealtime ;

% power.windoff = [setup.data.electricityprodex5minrealtime(:).OffshoreWindPower]';
% power.windon  = [setup.data.electricityprodex5minrealtime(:).OnshoreWindPower]';

alltime = datetime(cat(1, alldata(:).Minutes5UTC) , 'Format', 'uuuu-MM-dd''T''HH:mm:ss+00:00', 'TimeZone', 'UTC') ;

alltimeDK = datetime(alltime, 'TimeZone', 'Europe/Copenhagen') ;

allfields = fieldnames(alldata) ;
Area = cat(1, alldata(:).PriceArea) ;
varnames = {} ;
for ifield = 1:length(allfields)
    switch allfields{ifield}
        case {'Minutes5UTC' 'Minutes5DK' 'PriceArea'}

        otherwise
            datain = {setup.data.electricityprodex5minrealtime(:).(allfields{ifield})}';
            dataempty = cellfun(@(x) isempty(x), datain) ;
            datain(dataempty) = {NaN} ;
            powerout.(makevalidstring(allfields{ifield})) = cell2mat(datain) ;
            varnames = [varnames allfields(ifield)];
    end
end

power = array2timetable(struct2array(powerout), 'RowTimes', alltime, 'VariableNames',varnames) ;
power  = addvars(power, Area) ;

TTSync.(power(1,'Area').Variables).TSO = power(1,:) ;
TTSync.(power(2,'Area').Variables).TSO = power(2,:) ;

elecfuel = retrieveEF ;

% In this case, we consider that combined cycle is mainly made of gas chp
% units based on the statistics of powerplants placed in the CC category in
% REE.

[alldata, ~] = fuelmixEU('Denmark', false, 'absolute') ;
alphadigit = countrycode('Denmark') ;

thermal = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'X9900'} ;
predictedfuel = fuelmixEU_lpredict(alldata.(alphadigit.alpha2)) ;

normalisedpredictthermal = array2timetable(bsxfun(@rdivide, predictedfuel(:,thermal).Variables, sum(predictedfuel(:,thermal).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', thermal) ;


replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), normalisedpredictthermal.Properties.VariableNames, 'UniformOutput', false) ;
normalisedpredictthermal.Properties.VariableNames = cat(1, replacestring{:}) ;

PPDB = readtable('conventional_power_plants_EU.csv') ;
PP_DK = PPDB(strcmp(PPDB.country,'DK'),:);

allenergy = unique(PP_DK.energy_source) ;

installedcapL100 = sum(PP_DK.capacity(PP_DK.capacity<=100)) ;
installedcapG100 = sum(PP_DK.capacity(PP_DK.capacity>100))  ;

fueleq = {  'Biomass and biogas'	'biomass'
            'Mixed fossil fuels'	'coal_chp'
            'Hard coal'	'coal_chp'
            'Natural gas'	'gas'
            'Oil'	'oil_chp'
            'Other or unspecified energy sources'	'other' 
            'Waste' 'waste'} ;

eneroutL100 = emptyStruct(unique(fueleq(:,2)), ones(1,length(unique(fueleq(:,2)))))    ;
eneroutG100 = emptyStruct(unique(fueleq(:,2)), ones(1,length(unique(fueleq(:,2)))))    ;

for iener = 1:length(allenergy)
    energ = allenergy{iener} ;
    if isempty(eneroutL100.(fueleq{contains(fueleq, energ),2}))
        eneroutL100.(fueleq{contains(fueleq, energ),2}) = sum(PP_DK.capacity(PP_DK.capacity<=100 & strcmp(PP_DK.energy_source,energ))) ;
    else
        eneroutL100.(fueleq{contains(fueleq, energ),2}) = eneroutL100.(fueleq{contains(fueleq, energ),2}) + sum(PP_DK.capacity(PP_DK.capacity<=100 & strcmp(PP_DK.energy_source,energ))) ;
    end

    if isempty(eneroutG100.(fueleq{contains(fueleq, energ),2}))
        eneroutG100.(fueleq{contains(fueleq, energ),2}) = sum(PP_DK.capacity(PP_DK.capacity>100 & strcmp(PP_DK.energy_source,energ))) ;
    else
        eneroutG100.(fueleq{contains(fueleq, energ),2}) = eneroutG100.(fueleq{contains(fueleq, energ),2}) + sum(PP_DK.capacity(PP_DK.capacity>100 & strcmp(PP_DK.energy_source,energ))) ;
    end
end

eneroutL100           = struct2table(eneroutL100,"AsArray",true);
eneroutG100           = struct2table(eneroutG100,"AsArray",true);

extractcountry_fuel = {'biomass' 'coal_chp' 'other' 'gas' 'oil_chp' 'waste'} ;
extracteurostat = {'biomass' 'coal' 'unknown' 'gas' 'oil' 'waste'} ;

init        = normalisedpredictthermal(end,extracteurostat).Variables / 100 ;
thermalpower.(power(1,'Area').Variables) = TTSync.(power(1,'Area').Variables).TSO.ProductionLt100MW ;
thermalpower.(power(2,'Area').Variables) = TTSync.(power(2,'Area').Variables).TSO.ProductionLt100MW ;

newlimitL.(power(1,'Area').Variables)    = array2table(eneroutL100(1,extractcountry_fuel).Variables/sum(eneroutL100.Variables) * thermalpower.(power(1,'Area').Variables),'VariableNames', extractcountry_fuel)  ;
newlimitL.(power(2,'Area').Variables)    = array2table(eneroutL100(1,extractcountry_fuel).Variables/sum(eneroutL100.Variables) * thermalpower.(power(2,'Area').Variables),'VariableNames', extractcountry_fuel)  ;

thermalpower.(power(1,'Area').Variables) = TTSync.(power(1,'Area').Variables).TSO.ProductionGe100MW ;
thermalpower.(power(2,'Area').Variables) = TTSync.(power(2,'Area').Variables).TSO.ProductionGe100MW ;

newlimitH.(power(1,'Area').Variables)   = array2table(eneroutG100(1,extractcountry_fuel).Variables/sum(eneroutG100.Variables) * thermalpower.(power(1,'Area').Variables),'VariableNames', extractcountry_fuel)  ;
newlimitH.(power(2,'Area').Variables)   = array2table(eneroutG100(1,extractcountry_fuel).Variables/sum(eneroutG100.Variables) * thermalpower.(power(2,'Area').Variables),'VariableNames', extractcountry_fuel)  ;

prodfuel.(power(1,'Area').Variables) = array2table(newlimitL.(power(1,'Area').Variables).Variables + newlimitH.(power(1,'Area').Variables).Variables,'VariableNames', extractcountry_fuel)  ;
prodfuel.(power(2,'Area').Variables) = array2table(newlimitL.(power(2,'Area').Variables).Variables + newlimitH.(power(2,'Area').Variables).Variables,'VariableNames', extractcountry_fuel)  ;

test = TTSync.(power(1,'Area').Variables).TSO ;
    test = removevars(test,{'ProductionGe100MW','ProductionLt100MW','OffshoreWindPower', 'OnshoreWindPower', 'SolarPower', 'ExchangeGreatBelt', 'ExchangeGermany', ...
                            'ExchangeNetherlands', 'ExchangeNorway', 'ExchangeSweden', 'BornholmSE4', 'Area'}) ;
    test = addvars(test,TTSync.(power(1,'Area').Variables).TSO.OffshoreWindPower,'NewVariableNames', 'windoff') ;
    test = addvars(test,TTSync.(power(1,'Area').Variables).TSO.OnshoreWindPower,'NewVariableNames', 'windon') ;
    test = addvars(test,TTSync.(power(1,'Area').Variables).TSO.SolarPower,'NewVariableNames', 'solar') ;
    test = addvars(test, prodfuel.(power(1,'Area').Variables).biomass,'NewVariableNames', 'biomass') ;
    test = addvars(test, prodfuel.(power(1,'Area').Variables).coal_chp,'NewVariableNames', 'coal_chp') ;
    test = addvars(test, prodfuel.(power(1,'Area').Variables).other,'NewVariableNames', 'other') ;
    test = addvars(test, prodfuel.(power(1,'Area').Variables).gas,'NewVariableNames', 'gas') ;
    test = addvars(test, prodfuel.(power(1,'Area').Variables).oil_chp,'NewVariableNames', 'oil_chp') ;
    test = addvars(test, prodfuel.(power(1,'Area').Variables).waste,'NewVariableNames', 'waste') ;

TTSync.(power(1,'Area').Variables).emissionskit = test ;

test = TTSync.(power(2,'Area').Variables).TSO ;
    test = removevars(test,{'ProductionGe100MW','ProductionLt100MW','OffshoreWindPower', 'OnshoreWindPower', 'SolarPower', 'ExchangeGreatBelt', 'ExchangeGermany', ...
                            'ExchangeNetherlands', 'ExchangeNorway','ExchangeSweden', 'BornholmSE4', 'Area'}) ;
    test = addvars(test,TTSync.(power(2,'Area').Variables).TSO.OffshoreWindPower,'NewVariableNames', 'windoff') ;
    test = addvars(test,TTSync.(power(2,'Area').Variables).TSO.OnshoreWindPower,'NewVariableNames', 'windon') ;
    test = addvars(test,TTSync.(power(2,'Area').Variables).TSO.SolarPower,'NewVariableNames', 'solar') ;
    test = addvars(test, prodfuel.(power(2,'Area').Variables).biomass,'NewVariableNames', 'biomass') ;
    test = addvars(test, prodfuel.(power(2,'Area').Variables).coal_chp,'NewVariableNames', 'coal_chp') ;
    test = addvars(test, prodfuel.(power(2,'Area').Variables).other,'NewVariableNames', 'other') ;
    test = addvars(test, prodfuel.(power(2,'Area').Variables).gas,'NewVariableNames', 'gas') ;
    test = addvars(test, prodfuel.(power(2,'Area').Variables).oil_chp,'NewVariableNames', 'oil_chp') ;
    test = addvars(test, prodfuel.(power(2,'Area').Variables).waste,'NewVariableNames', 'waste') ;

TTSync.(power(2,'Area').Variables).emissionskit = test ;


test = TTSync.(power(1,'Area').Variables).emissionskit.Variables + TTSync.(power(2,'Area').Variables).emissionskit.Variables ;
TTSync.emissionskit = array2timetable(test, 'VariableNames',TTSync.(power(2,'Area').Variables).emissionskit.Properties.VariableNames, 'RowTimes',TTSync.(power(2,'Area').Variables).emissionskit.Time) ;

TTSync = rmfield(TTSync,{'DK1', 'DK2'});