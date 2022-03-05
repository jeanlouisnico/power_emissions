function emissionskit(src, eventdata)
% This is the main routine for running the emission code from MatLab

%% Exchange of Power
% For the other countries, it is necessary to loop through each connected
% country. Country can be added or removed by editing the cell array.
Country = {'Russia', 'Sweden', 'Estonia', 'Norway', 'Finland', 'France'} ;

country_code = countrycode(Country) ;


for icountry = 1:length(Country)
    [ENTSOE, TSO, PoweroutLoad] = CallCountryPower(Country{icountry}) ;
    Power.(country_code{icountry}).ENTSOE.bytech = ENTSOE ;
    Power.(country_code{icountry}).ENTSOE.byfuel = ENTSOEbyfuel(ENTSOE) ;
    Power.(country_code{icountry}).ENTSOE.TotalConsumption = PoweroutLoad ;
    Power.(country_code{icountry}).TSO = TSO ;
end

%% Load Emissions data
% Emissions from EcoInvent are gathered and stored in a .csv file
% associated to this file Emissions_Summary.csv. The data are gathered from
% EcoInvent 3.6 and characterised with the ReCiPe 2016 method. All
% categories are reported therefore, it is possible to choose from any of
% the 18 categories
EmissionsCategory = 'GlobalWarming' ;
Emissionsdatabase = load_emissions ;

%% Emissions Finland
% Re-allocate the emissions per type of technology

%% Calculate Emissions
% Emissions are then calculated by multipliying the emission factor (/MWh)
% to the power produced by the same technology.
EFSourcelist = {'EcoInvent' 'ET' 'IPCC'} ;
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    [Emissions.FI.TSO.(EFSource).byfuel] = FingridEmissions(CHP_DH_Fuel, Emissionsdatabase, EFSource, CHP_Ind_Fuel, Sep_Fuel, Windpower, WindCat, EmissionsCategory,Power) ;
    Emissions.FI.TSO.(EFSource).total = sum(struct2array(Emissions.FI.TSO.(EFSource).byfuel)) ;
    Emissions.FI.TSO.(EFSource).intensityprod = Emissions.FI.TSO.(EFSource).total / Power.FI.TSO.TotalProduction ;
end

% Finland is extracted from ENTSOE
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    EmissionTotal                             = ENTSOEEmissions(Power.FI.ENTSOE.bytech , Emissionsdatabase.(EFSource), 'FI', EmissionsCategory) ;
    if isa(EmissionTotal, 'struct')
        Emissions.FI.ENTSOE.(EFSource).total = sum(struct2array(EmissionTotal)) ;
        Emissions.FI.ENTSOE.(EFSource).intensityprod    = Emissions.FI.ENTSOE.(EFSource).total / sum(struct2array(Power.FI.ENTSOE.bytech)) ;
    else
        Emissions.FI.ENTSOE.(EFSource).total = 0 ;
        Emissions.FI.ENTSOE.(EFSource).intensityprod    = 0 ;
    end
end

%%% Final Emissions Fingrid
EmissionsFingrid_Total =   Power.FI.TSO.bytech.CHP_DH       * Emissionsdatabase.Fingrid.DH_CHP + ...
                           Power.FI.TSO.bytech.CHP_Ind      * Emissionsdatabase.Fingrid.Ind_CHP + ...
                           Power.FI.TSO.bytech.NuclearP     * Emissionsdatabase.Fingrid.Nuclear + ...
                           Power.FI.TSO.bytech.OtherProd    * Emissionsdatabase.Fingrid.Other + ...
                           Power.FI.TSO.bytech.WindP        * Emissionsdatabase.Fingrid.Wind + ...
                           Power.FI.TSO.bytech.SolarP       * Emissionsdatabase.Fingrid.Solar + ...
                           Power.FI.TSO.bytech.HydroP       * Emissionsdatabase.Fingrid.Hydro ;

Emissions.FI.TSO.TSO.bytech.nuclear    = Power.FI.TSO.bytech.NuclearP  * Emissionsdatabase.Fingrid.Nuclear ;
Emissions.FI.TSO.TSO.bytech.CHP_DH     = Power.FI.TSO.bytech.CHP_DH    * Emissionsdatabase.Fingrid.DH_CHP ;
Emissions.FI.TSO.TSO.bytech.CHP_Ind    = Power.FI.TSO.bytech.CHP_Ind   * Emissionsdatabase.Fingrid.Ind_CHP ;
Emissions.FI.TSO.TSO.bytech.other      = Power.FI.TSO.bytech.OtherProd * Emissionsdatabase.Fingrid.Other ;
Emissions.FI.TSO.TSO.bytech.wind       = Power.FI.TSO.bytech.WindP     * Emissionsdatabase.Fingrid.Wind ;
Emissions.FI.TSO.TSO.bytech.solar      = Power.FI.TSO.bytech.SolarP    * Emissionsdatabase.Fingrid.Solar ;
Emissions.FI.TSO.TSO.bytech.hydro      = Power.FI.TSO.bytech.HydroP    * Emissionsdatabase.Fingrid.Hydro ;                       

Emissions.FI.TSO.TSO.intensityprod = EmissionsFingrid_Total / Power.FI.TSO.TotalProduction  ; 
% Emissions.FI.TSO.TSO.intensitycons = EmissionsFingrid_Total / Power.FI.TSO.TotalConsumption ;

%% Emissions Russia
% Emissions from Russia are extracted
EFSourcelist = {'EcoInvent' 'IPCC'} ;
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    Hydro             = Power.RU.TSO.bytech.hydro   * extractdata('hydro_runof', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
    Solar             = Power.RU.TSO.bytech.solar   * extractdata('solar', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource));
    %%%
    % The thermal production of electricity in Western Russia, close to the
    % Finnish border, it somewhat different from the rest of the country.. More
    % information available in the link below
    %%%
    % <https://www.tgc1.ru/production/complex/karelia-branch/petrozavodskaya-chpp/>
    %%%
    % <https://www.tgc1.ru/production/complex/kolsky-branch/apatitskaya-chpp/>
    %%%
    % <https://www.tgc1.ru/production/complex/kolsky-branch/murmanskaya-chpp/>
    %%%
    % Overall, the thermal power is made of 53% of gas CHP, 44% of coal CHP,
    % and 2.5% of CHP oil.
    switch EFSource
        case 'IPCC'
            thermal           = Power.RU.TSO.bytech.thermal * extractdata('TES', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource))  ; 
            oil               = Power.RU.TSO.bytech.oil     * extractdata('TES', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource))  ; 
        case 'EcoInvent'
            %%%
            % The BS technology that produce electricity are coming from pulp and paper
            % factories in Karelia and uses 2/3 of oil and 1/3 of gas, and burn
            % corrosive waste.
            thermal           = Power.RU.TSO.bytech.thermal * (.5364 * extractdata('gas_chp', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                                                           .4406 * extractdata('coal_chp', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                                                           .0230 * extractdata('oil_chp', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource))) ;
            oil               = Power.RU.TSO.bytech.oil     * (2/3 * extractdata('oil_chp', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                                                           1/3 * extractdata('gas_chp', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource))) ;                                           
    end
    
    Nuclear           = Power.RU.TSO.bytech.nuclear * extractdata('nuclear_PWR', 'RU', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
    
    
    %%%
    % Calculate the emission intensity for RU
    Emissions.RU.TSO.(EFSource).intensityprod = (Hydro + Solar + thermal + Nuclear + oil) / sum(struct2array(Power.RU.TSO.bytech)) ;
end
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    EmissionTotal                             = ENTSOEEmissions(Power.RU.ENTSOE.bytech , Emissionsdatabase.(EFSource), 'RU', EmissionsCategory) ;
    if isa(EmissionTotal, 'struct')
        Emissions.RU.ENTSOE.(EFSource).total = sum(struct2array(EmissionTotal)) ;
        Emissions.RU.ENTSOE.(EFSource).intensityprod    = Emissions.RU.ENTSOE.(EFSource).total / sum(struct2array(Power.RU.ENTSOE.bytech)) ;
    else
        Emissions.RU.ENTSOE.(EFSource).total = 0 ;
        Emissions.RU.ENTSOE.(EFSource).intensityprod    = 0 ;
    end
end

%% Emissions Norway
%%% Emissions from EcoInvent
% Norway is extracted from ENTSOE
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    EmissionTotal = ENTSOEEmissions(Power.NO.ENTSOE.bytech , Emissionsdatabase.(EFSource), 'NO', EmissionsCategory) ;
    if isa(EmissionTotal, 'struct')
        Emissions.NO.ENTSOE.(EFSource).total = sum(struct2array(EmissionTotal)) ;
        Emissions.NO.ENTSOE.(EFSource).intensityprod    = Emissions.NO.ENTSOE.(EFSource).total / sum(struct2array(Power.NO.ENTSOE.bytech)) ;
    else
        Emissions.NO.ENTSOE.(EFSource).total = 0 ;
        Emissions.NO.ENTSOE.(EFSource).intensityprod    = 0 ;
    end
end

%% Emissions Sweden
%%% Emissions from EcoInvent
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
        switch EFSource
            case 'EcoInvent'
                %%%
                % Thermal power production from Sweden is taken from Sweden statistics share of
                % each technology: 1.3% oil chp, 2.4% coal chp + 2 % peat + 42.6% biomass
                % (Finland average), 3.1% gas, .2% biogas, 5% black furnace, 33.4%
                % municipal waste, 9.9% others
                %%%
                % Get the statsitics from the Swedeish statistic API
                yearstat = datetime(now, 'ConvertFrom', 'datenum').Year ;
                [databyfuel] = importswedenfuel(yearstat) ;
                databyfuelT = struct2table(databyfuel) ;
                ratiofuel = array2table(struct2array(databyfuel) / sum(databyfuelT(1,{'oil','coal','peat','biomass','gas','biogas','black_furnace','waste','other'}).Variables), ...
                                         "VariableNames", databyfuelT.Properties.VariableNames) ;
                % <https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__EN__EN0105/BrforelARb/table/tableViewLayout1/>
                thermalchp = ratiofuel.oil * extractdata('oil_chp', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                             ratiofuel.coal * extractdata('hard_coal', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                             ratiofuel.peat * extractdata('peat', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                             ratiofuel.biomass * extractdata('biomass', 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) + ... % No data for Sweden
                             ratiofuel.gas * extractdata('gas_chp', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                             ratiofuel.biogas * extractdata('other_biogas', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                             ratiofuel.black_furnace * extractdata('blast_furnace', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                             ratiofuel.waste * extractdata('waste', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                             ratiofuel.other * (ratiofuel.oil * extractdata('oil_chp', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                              ratiofuel.coal * extractdata('hard_coal', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                              ratiofuel.peat * extractdata('peat', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                              ratiofuel.biomass * extractdata('biomass', 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) + ... % No data for Sweden
                              ratiofuel.gas * extractdata('gas_chp', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                              ratiofuel.biogas * extractdata('other_biogas', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                              ratiofuel.black_furnace * extractdata('blast_furnace', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                              ratiofuel.waste * extractdata('waste', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource))) ;
              case 'IPCC'
                   thermalchp = extractdata('unknown', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) ; 
        end

        Hydro             = Power.SE.TSO.bytech.hydro   * extractdata('hydro_runof', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
        %%%
        % Unknown technology are averaged between biogas and municipal waste
        unknown           = Power.SE.TSO.bytech.unknown * thermalchp ; 
        thermal           = Power.SE.TSO.bytech.thermal * thermalchp ; 
        Nuclear           = Power.SE.TSO.bytech.nuclear * extractdata('nuclear_PWR', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
        Wind              = Power.SE.TSO.bytech.wind    * extractdata('windon', 'SE', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                
        % Calculate the emission intensity for Sweden
        Emissions.SE.TSO.(EFSource).total = Hydro + unknown + thermal + Nuclear + Wind ;
        Emissions.SE.TSO.(EFSource).intensityprod = (Emissions.SE.TSO.(EFSource).total) / sum(Power.SE.TSO.bytech.hydro + ...
                                                                                                      Power.SE.TSO.bytech.unknown + ...
                                                                                                      Power.SE.TSO.bytech.thermal + ...
                                                                                                      Power.SE.TSO.bytech.nuclear + ...
                                                                                                      Power.SE.TSO.bytech.wind) ;
end

for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    EmissionTotal = ENTSOEEmissions(Power.SE.ENTSOE.bytech , Emissionsdatabase.(EFSource), 'SE', EmissionsCategory) ;
    if isa(EmissionTotal, 'struct')
        Emissions.SE.ENTSOE.(EFSource).total = sum(struct2array(EmissionTotal)) ;
        Emissions.SE.ENTSOE.(EFSource).intensityprod    = Emissions.SE.ENTSOE.(EFSource).total / sum(struct2array(Power.SE.ENTSOE.bytech)) ;
    else
        Emissions.SE.ENTSOE.(EFSource).total = 0 ;
        Emissions.SE.ENTSOE.(EFSource).intensityprod    = 0 ;
    end
end

%%%
% Re-allocate the energy byfuel for statistical purposes.
Power.SE.TSO.byfuel.nuclear     = Power.SE.TSO.bytech.nuclear ;
Power.SE.TSO.byfuel.wind        = Power.SE.TSO.bytech.wind ;
Power.SE.TSO.byfuel.hydro       = Power.SE.TSO.bytech.hydro ;
Power.SE.TSO.byfuel.oil         = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.oil ;
Power.SE.TSO.byfuel.coal        = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.coal ;
Power.SE.TSO.byfuel.peat        = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.peat ;
Power.SE.TSO.byfuel.biomass     = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.biomass ;
Power.SE.TSO.byfuel.gas         = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.gas ;
Power.SE.TSO.byfuel.biogas      = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.biogas ;
Power.SE.TSO.byfuel.black_furnace     = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.black_furnace ;
Power.SE.TSO.byfuel.waste       = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.waste ;
Power.SE.TSO.byfuel.other       = (Power.SE.TSO.bytech.thermal + Power.SE.TSO.bytech.unknown) * ratiofuel.other ;
%% Emissions EE
%%% Emissions from EcoInvent
[energy, Power.EE.TSO.byfuel] = extract_estonie_emissions(Power.EE.TSO.bytech) ;
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    switch EFSource
        case 'EcoInvent'
            EmissionTotal = emissionsEstonia(energy, Emissionsdatabase.(EFSource), EmissionsCategory) ;
        case 'IPCC'
            EmissionTotal = emissionsEstonia(energy, Emissionsdatabase.(EFSource), EmissionsCategory) ;
    end
    if isa(EmissionTotal, 'struct')
        Emissions.EE.TSO.(EFSource).total = sum(struct2array(EmissionTotal)) ;
        if isfield(Power.EE.TSO.bytech, 'productionLV')
            Emissions.EE.TSO.(EFSource).intensityprod = Emissions.EE.TSO.(EFSource).total / Power.EE.TSO.bytech.productionLV  ;
        else
            Emissions.EE.TSO.(EFSource).intensityprod = Emissions.EE.TSO.(EFSource).total / Power.EE.TSO.bytech.production  ;
        end
    end
end


% EE is extracted from ENTSOE
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    EmissionTotal = ENTSOEEmissions(Power.EE.ENTSOE.bytech , Emissionsdatabase.(EFSource), 'EE', EmissionsCategory) ;
    if isa(EmissionTotal, 'struct')
        Emissions.EE.ENTSOE.(EFSource).total = sum(struct2array(EmissionTotal)) ;
        Emissions.EE.ENTSOE.(EFSource).intensityprod    = Emissions.EE.ENTSOE.(EFSource).total / sum(struct2array(Power.EE.ENTSOE.bytech)) ;
    else
        Emissions.EE.ENTSOE.(EFSource).total = 0 ;
        Emissions.EE.ENTSOE.(EFSource).intensityprod    = 0 ;
    end
end

%% Emissions France
[Power, Emissions] = emissionsFrance(Power, EmissionsCategory, Emissionsdatabase, Emissions) ;

%% Emissions balanced
Source = {'IPCC'
          'EcoInvent'} ;
FIsource = {'ENTSOE'
            'TSO'} ;
for ipower = 1:length(FIsource)
    SourceFI = FIsource{ipower} ;
    for iEFSource = 1:length(Source)
        EFSource = EFSourcelist{iEFSource} ;
        if Power.FI.TSO.TradeRU > 0 
            %%%
            % Import from RU. Add the emissions to the Finnish energy
            % mix
            EmissionTrade.RU = Power.FI.TSO.TradeRU * Emissions.RU.TSO.(EFSource).intensityprod ;
        else
            %%%
            % Export to RU. educe the emissions from the Finnish energy
            % mix
            EmissionTrade.RU = Power.FI.TSO.TradeRU * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
        end
        if Power.FI.TSO.TradeNO > 0 
            %%%
            % Import from NO
            EmissionTrade.NO = Power.FI.TSO.TradeNO * Emissions.NO.ENTSOE.(EFSource).intensityprod ;
        else
            %%%
            % Export to NO
            EmissionTrade.NO = Power.FI.TSO.TradeNO * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
        end
        if Power.FI.TSO.TradeEE > 0 
            %%%
            % Import from EE
            EmissionTrade.EE = Power.FI.TSO.TradeEE * Emissions.EE.(SourceFI).(EFSource).intensityprod ;
        else
            %%%
            % Export to EE
            EmissionTrade.EE = Power.FI.TSO.TradeEE * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
        end
        if Power.FI.TSO.TradeSE > 0 
            %%%
            % Import from SE
            EmissionTrade.SE = Power.FI.TSO.TradeSE * Emissions.SE.(SourceFI).(EFSource).intensityprod ;
        else
            %%%
            % Export to SE
            EmissionTrade.SE = Power.FI.TSO.TradeSE * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
        end
        Balance = Emissions.FI.(SourceFI).(EFSource).total + sum(struct2array(EmissionTrade)) ;
        %%%
        % Recalculate the emission intensity based on the consumption of
        % electricity in FI and including the traded electricity and their
        % emission impact.
        Emissions.FI.(SourceFI).(EFSource).intensitycons = Balance / Power.FI.(SourceFI).TotalConsumption ;
    end
end
%% Save all values in XML files

currenttime = datetime(now, "ConvertFrom", "datenum") ;

%% Send the data to the server

try 
    % Test the connection, if it is valid then continue saving in the sql
    % database. If it is not valid, save using the xml format
    conn = connDB ;
    close(conn);
    send2sqlcomplete(currenttime, Emissions) ;
    send2sqlpowerbyfuel(currenttime, Power) ;
catch
    % All variables are stored in xml format saved at the same location than
    % this function as XMLEmissions.xml. We are not storing data
    % therefore only the latest data are provided.
    p = mfilename('fullpath') ;
    [filepath,~,~] = fileparts(p) ;
    fparts = split(filepath, filesep) ;
    fparts = join(fparts(1:end-1), filesep) ;
    
    archivepath = [fparts{1} filesep 'output'] ;

    Filename = [sprintf('%02d',currenttime.Year) sprintf('%02d',currenttime.Month) sprintf('%02d',currenttime.Day) sprintf('%02d',currenttime.Hour) '_Emissions.xml'] ;

    if isfile(Filename)
        archive = false ;
        s = xml2struct2(Filename) ;
        nbrexistingdata = length(s.EmissionsFinland.Data) ;
        if nbrexistingdata == 1
            s.EmissionsFinland.Data(nbrexistingdata+1).Date = datestr(currenttime, 'dd-mm-yyyy HH:MM:SS') ;
            s.EmissionsFinland.Data(nbrexistingdata+1).Power = Power ;
            s.EmissionsFinland.Data(nbrexistingdata+1).Emissions = Emissions ;
        else
            s.EmissionsFinland.Data{nbrexistingdata+1}.Date = datestr(currenttime, 'dd-mm-yyyy HH:MM:SS') ;
            s.EmissionsFinland.Data{nbrexistingdata+1}.Power = Power ;
            s.EmissionsFinland.Data{nbrexistingdata+1}.Emissions = Emissions ;
        end
    else  
        archive = true ;
        s.EmissionsFinland.Data(1).Date = datestr(currenttime, 'dd-mm-yyyy HH:MM:SS') ;
        s.EmissionsFinland.Data(1).Power = Power ;
        s.EmissionsFinland.Data(1).Emissions = Emissions ;
    end
    
    struct2xml(s, [archivepath filesep Filename]);
%     extract4Tableau(archivepath) ;
    
    %%% Archive the data
    if archive
        %%% Archive old files
        currenttimetemp = datetime(now, "ConvertFrom", "datenum")- hours(1) ;
        Filenameold = [sprintf('%02d',currenttimetemp.Year) ...
                       sprintf('%02d',currenttimetemp.Month) ...
                       sprintf('%02d',currenttimetemp.Day) ...
                       sprintf('%02d',currenttimetemp.Hour) '_Emissions.xml'] ;


        archivepath = [archivepath filesep 'archive' filesep 'xml'] ;

        if ~exist(archivepath, 'dir')
           mkdir(archivepath)
        end
        try
            archivepathtemp = 'C:\TEMP\archive\xml' ;
            if ~exist(archivepathtemp, 'dir')
               mkdir(archivepathtemp)
            end
            copyfile(Filenameold, archivepathtemp) ;
            disp('file copied')
        catch
            % Error might happen if data were missing
        end
        try 
            movefile(Filenameold, archivepath)
            disp('file moved')
        catch
            % Error might happen if data were missing
        end
        %%% Archive old files
    end 
end

%% Function extract from table
    function Emissionsextract = extractdata(Tech, Country, EmissionsCategory, Emissions)
        if isa(Emissions, 'table')
            % This is the original table extract
            Emissionsextract = Emissions.(EmissionsCategory)(strcmp(Emissions.Technology,Tech) & strcmp(Emissions.Country,Country)) ;
        elseif isa(Emissions, 'struct')
            % This is from the json data
            Emissionsextract = Emissions.emissionFactors.EcoInvent.zoneOverrides.(Country).(Tech).(EmissionsCategory).value ;
        end
            
    end
%% Function emission extract ENTSOE
    function emission = ENTSOEEmissions(Power, Emissions, country, EmissionsCategory)
        %%%
        % For a given country, emissions are calculated from the ENTSOE
        % database. Equivalence table between the ENTSOE database and the
        % emission database is given in the switch form below.
        if isa(Power, 'struct')
            AllTech = fieldnames(Power) ;
            emission = struct ; 
            for itech = 1:length(AllTech)
                techname = AllTech{itech} ;
                if Power.(techname) == 0 
                    emission.(techname) = 0;
                else
                    switch country
                        case ''
                        otherwise
                            try
                                switch techname
                                    case {'fossil_brown_coal_lignite','fossil_coal_derived_gas', 'fossil_hard_coal'}
                                        technamein = 'coal_chp' ;
                                    case {'fossil_gas'}
                                        technamein = 'gas' ;
                                    case {'fossil_peat'}
                                        technamein = 'peat' ;
                                    case {'fossil_oil_shale', 'fossil_oil'}
                                        technamein = 'oil_chp' ;
                                    case 'hydro_pumped_storage'
                                        technamein = 'hydro_pumped' ;
                                    case 'hydro_run_of_river_and_poundage'
                                        technamein = 'hydro_runof' ;
                                    case 'hydro_water_reservoir'
                                        technamein = 'hydro_reservoir' ;
                                    case 'other_renewable'
                                        technamein = 'biomass' ;
                                    case 'wind_offshore'
                                        technamein = 'windoff' ;
                                    case 'wind_onshore'
                                        technamein = 'windon' ;
                                    case 'nuclear'
                                        technamein = 'nuclear_PWR' ;
                                    case 'other'
                                        technamein = 'other_biogas' ;
                                    otherwise
                                        technamein = techname   ; 
                                end
                                emi = extractdata(technamein, country, EmissionsCategory, Emissions) ;
                            catch
                                emi = 500 ;
                            end
                            %%%
                            % A default factor of 500 kgCO2/MWh is used in case
                            % of error (but there should not be for this
                            % specific dataset of technology.
                            if isempty(emi)
                                emi = 100 ;
                            end
                            if isfield(techname, emission)
                                emission.(techname) = emission.(techname) + Power.(techname) * emi ;
                            else
                                emission.(techname) = Power.(techname) * emi ;
                            end
                    end
                end
            end
        else
            emission = 0 ;
        end
        %%%
        % Total emissions from all the technologies from ENTSOE [kg]
%         EmissionTotal = sum(struct2array(emission)) ;
    end
%% function 


end
