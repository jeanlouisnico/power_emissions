
function TTSync = DK

alldata = webread('https://api.energidataservice.dk/dataset/ElectricityProdex5MinRealtime?offset=0&sort=Minutes5UTC%20DESC&timezone=dk') ;
alltime = cellfun(@(x) datetime(x, "TimeZone",'UTC'), {alldata.records.Minutes5UTC}') ;
area = {alldata.records.PriceArea}' ;

allfields = fieldnames(alldata.records) ;
varnames = {} ;
for ifield = 1:length(allfields)
    switch allfields{ifield}
        case {'Minutes5UTC' 'Minutes5DK' 'PriceArea'}

        otherwise
            datain = {alldata.records.(allfields{ifield})}';
            dataempty = cellfun(@(x) isempty(x), datain) ;
            datain(dataempty) = {0} ;
            powerout.(makevalidstring(allfields{ifield})) = cell2mat(datain) ;
            varnames = [varnames allfields(ifield)];
    end
end

areacode = unique(area) ;
powerfields = fieldnames(powerout) ;
for icode = 1:length(areacode)
    codename = areacode{icode} ;
    id_extract = strcmp(area, codename) ; 
    timeextract = alltime(id_extract) ;
    for ifield = 1:length(powerfields)
        p.(powerfields{ifield}) = powerout.(powerfields{ifield})(id_extract) ;
    end
    rtemp = struct2table(p) ;
    aa = sortrows(table2timetable(rtemp, "RowTimes",timeextract)) ;
    TTSync.(codename).TSO = aa(end,:) ;
end

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

for icode = 1:length(areacode)
    codename = areacode{icode} ;
    thermalpower.(codename) = TTSync.(codename).TSO.(makevalidstring('ProductionLt100MW'))(end) ;
    newlimitL.(codename)    = array2table(eneroutL100(1,extractcountry_fuel).Variables/sum(eneroutL100.Variables) * thermalpower.(codename),'VariableNames', extractcountry_fuel)  ;
    thermalpower.(codename) = TTSync.(codename).TSO.(makevalidstring('ProductionGe100MW'))(end) ;
    newlimitH.(codename)   = array2table(eneroutG100(1,extractcountry_fuel).Variables/sum(eneroutG100.Variables) * thermalpower.(codename),'VariableNames', extractcountry_fuel)  ;
    prodfuel.(codename) = array2table(newlimitL.(codename).Variables + newlimitH.(codename).Variables,'VariableNames', extractcountry_fuel)  ;

end

for icode = 1:length(areacode)
    codename = areacode{icode} ;
    test = table ;
        test = addvars(test,TTSync.(codename).TSO.(makevalidstring('OffshoreWindPower'))(end),'NewVariableNames', 'windoff') ;
        test = addvars(test,TTSync.(codename).TSO.(makevalidstring('OnshoreWindPower'))(end),'NewVariableNames', 'windon') ;
        test = addvars(test,TTSync.(codename).TSO.(makevalidstring('SolarPower'))(end),'NewVariableNames', 'solar') ;
        test = addvars(test, prodfuel.(codename).biomass,'NewVariableNames', 'biomass') ;
        test = addvars(test, prodfuel.(codename).coal_chp,'NewVariableNames', 'coal_chp') ;
        test = addvars(test, prodfuel.(codename).other,'NewVariableNames', 'other') ;
        test = addvars(test, prodfuel.(codename).gas,'NewVariableNames', 'gas') ;
        test = addvars(test, prodfuel.(codename).oil_chp,'NewVariableNames', 'oil_chp') ;
        test = addvars(test, prodfuel.(codename).waste,'NewVariableNames', 'waste') ;
    
    TTSync.(codename).emissionskit = table2timetable(test,"RowTimes",TTSync.(codename).TSO.Time(end))  ;
end

test = TTSync.(areacode{1}).emissionskit.Variables + TTSync.(areacode{2}).emissionskit.Variables ;
TTSync.emissionskit = array2timetable(test, 'VariableNames',TTSync.(areacode{2}).emissionskit.Properties.VariableNames, 'RowTimes',TTSync.(areacode{2}).emissionskit.Time) ;

test = TTSync.(areacode{1}).TSO.Variables + TTSync.(areacode{2}).TSO.Variables ;
TTSync.TSO = array2timetable(test, 'VariableNames',TTSync.(areacode{2}).TSO.Properties.VariableNames, 'RowTimes',TTSync.(areacode{2}).TSO.Time) ;


TTSync = rmfield(TTSync,{'DK1', 'DK2'});