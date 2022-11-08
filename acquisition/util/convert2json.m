function convert2json

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;


em_EcoInvent = readtable([fparts{1} filesep 'input' filesep 'general' filesep 'Emissions_Summary.csv']) ;
em_IPCC = EM_EF_decode ;
allcountries = unique(em_EcoInvent.Country) ;

ReCiPefields = {'GlobalWarming' 'kg CO2 eq/MWh'
                 'StratosphericOzoneDepletion' 'kg CFC11 eq/MWh'
                 'IonizingRadiation' 'kBq Co-60 eq/MWh'
                 'OzoneFormation_HumanHealth' 'kg NOx eq/MWh'
                 'FineParticulateMatterFormation' 'kg PM2.5 eq/MWh'
                 'OzoneFormation_TerrestrialEcosystems' 'kg NOx eq/MWh'
                 'TerrestrialAcidification' 'kg SO2 eq/MWh'
                 'FreshwaterEutrophication' 'kg P eq/MWh'
                 'MarineEutrophication' 'kg N eq/MWh'
                 'TerrestrialEcotoxicity' 'kg 1,4-DCB/MWh'
                 'FreshwaterEcotoxicity'  'kg 1,4-DCB/MWh'
                 'MarineEcotoxicity' 'kg 1,4-DCB/MWh'
                 'HumanCarcinogenicToxicity' 'kg 1,4-DCB/MWh'
                 'HumanNon_carcinogenicToxicity' 'kg 1,4-DCB/MWh'
                 'LandUse' 'm2a crop eq/MWh'
                 'MineralResourceScarcity' 'kg Cu eq/MWh'
                 'FossilResourceScarcity' 'kg oil eq/MWh'
                 'WaterConsumption' 'm3/MWh'} ;


for icountry = 1:length(allcountries)
    countrycode = allcountries{icountry} ;
    alltech = em_EcoInvent.Technology(strcmp(countrycode, em_EcoInvent.Country)) ;
    for itech = 1:length(alltech)
        for iKPI = 1:length(ReCiPefields)
            techname = alltech{itech} ;
            s.emissionFactors.EcoInvent.zoneOverrides.(countrycode).(techname).source = 'LCI: EcoInvent 3.4, LCIA: ReCiPe 2016 --> midpoint (I)' ;
            try
                s.emissionFactors.EcoInvent.zoneOverrides.(countrycode).(techname).(ReCiPefields{iKPI,1}).value = em_EcoInvent.(ReCiPefields{iKPI, 1})((strcmp(countrycode, em_EcoInvent.Country) & strcmp(techname, em_EcoInvent.Technology))) ;
            catch
                x= 1;
            end
            s.emissionFactors.EcoInvent.zoneOverrides.(countrycode).(techname).(ReCiPefields{iKPI,1}).unit = ReCiPefields{iKPI, 2} ;
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

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

dlmwrite([fparts{1} filesep 'input' filesep 'general' filesep 'co2eq_parameters_uoulu.json'],jsonencode(s,'PrettyPrint',true),'delimiter','');
