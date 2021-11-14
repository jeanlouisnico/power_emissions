function convert2json

em_EcoInvent = readtable('Emissions_Summary.csv') ;
em_IPCC = EM_EF_decode ;
allcountries = unique(em_EcoInvent.Country) ;

ReCiPefields = {'GlobalWarming'
 'StratosphericOzoneDepletion'
 'IonizingRadiation'
 'OzoneFormation_HumanHealth'
 'FineParticulateMatterFormation'
 'OzoneFormation_TerrestrialEcosystems'
 'TerrestrialAcidification'
 'FreshwaterEutrophication'
 'MarineEutrophication'
 'TerrestrialEcotoxicity'
 'FreshwaterEcotoxicity'
 'MarineEcotoxicity'
 'HumanCarcinogenicToxicity'
 'HumanNon_carcinogenicToxicity'
 'LandUse'
 'MineralResourceScarcity'
 'FossilResourceScarcity'
 'WaterConsumption'} ;


for icountry = 1:length(allcountries)
    countrycode = allcountries{icountry} ;
    alltech = em_EcoInvent.Technology(strcmp(countrycode, em_EcoInvent.Country)) ;
    for itech = 1:length(alltech)
        for iKPI = 1:length(ReCiPefields)
            techname = alltech{itech} ;
            s.emissionFactors.EcoInvent.zoneOverrides.(countrycode).(techname).source = 'LCI: EcoInvent 3.4, LCIA: ReCiPe 2016 --> midpoint (I)' ;
            s.emissionFactors.EcoInvent.zoneOverrides.(countrycode).(techname).(ReCiPefields{iKPI}).value = em_EcoInvent.(ReCiPefields{iKPI})((strcmp(countrycode, em_EcoInvent.Country) & strcmp(techname, em_EcoInvent.Technology))) ;
        end
    end
end

allcountries = unique(em_IPCC.Country) ;
ReCiPefields = {'GlobalWarming'} ;

for icountry = 1:length(allcountries)
    countrycode = allcountries{icountry} ;
    alltech = em_IPCC.Technology(strcmp(countrycode, em_IPCC.Country)) ;
    for itech = 1:length(alltech)
        for iKPI = 1:length(ReCiPefields)
            techname = alltech{itech} ;
            s.emissionFactors.IPCC.zoneOverrides.(countrycode).(techname).source = 'IPCC 2014' ;
            s.emissionFactors.IPCC.zoneOverrides.(countrycode).(techname).(ReCiPefields{iKPI}).value = em_IPCC.(ReCiPefields{iKPI})((strcmp(countrycode, em_IPCC.Country) & strcmp(techname, em_IPCC.Technology))) ;
        end
    end
end

dlmwrite('co2emissions_uoulu.json',jsonencode(s),'delimiter','');
