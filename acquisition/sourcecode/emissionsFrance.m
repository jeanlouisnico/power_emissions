function [Power, Emissions] = emissionsFrance(Power, EmissionsCategory, Emissionsdatabase, Emissions)


EFSourcelist = {'EcoInvent' 'IPCC'} ;
if isa(Power.FR.TSO.bytech, 'struct')
    temptable = struct2table(Power.FR.TSO.bytech) ;
else
    temptable = table(0,'VariableNames',{'biomass'}) ;
end
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    alltech = fieldnames(Power.FR.TSO.bytech) ;
    hydro               = 0 ;
    solar               = 0 ;
    biogas              = 0 ;
    oil                 = 0 ;
    oilchp              = 0 ; 
    waste               = 0 ;
    nuclear             = 0 ;
    biomass             = 0 ;
    coal                = 0 ;
    gas                 = 0 ;
    gas_chp             = 0 ;
    wind                = 0 ;

    for itechname = 1:length(alltech)
        technameinTSO = alltech{itechname} ;
        switch technameinTSO
            case {'hydro', 'hydrodam', 'hydropumped'}
                if isfield(Power.FR.TSO.bytech,'hydro') && isfield(Power.FR.TSO.bytech,'hydrodam') && isfield(Power.FR.TSO.bytech,'hydropumped')
                    hydro   = Power.FR.TSO.bytech.hydro   * extractdata('hydro_runof', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                            Power.FR.TSO.bytech.hydrodam   * extractdata('hydro_reservoir', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...    
                            Power.FR.TSO.bytech.hydropumped   * extractdata('hydro_pumped', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                elseif isfield(Power.FR.TSO.bytech,'hydro') && isfield(Power.FR.TSO.bytech,'hydrodam') && ~isfield(Power.FR.TSO.bytech,'hydropumped')
                    hydro   = Power.FR.TSO.bytech.hydro   * extractdata('hydro_runof', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...
                            Power.FR.TSO.bytech.hydrodam   * extractdata('hydro_reservoir', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                elseif isfield(Power.FR.TSO.bytech,'hydro') && ~isfield(Power.FR.TSO.bytech,'hydrodam') && isfield(Power.FR.TSO.bytech,'hydropumped')
                    hydro   = Power.FR.TSO.bytech.hydro   * extractdata('hydro_runof', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...  
                            Power.FR.TSO.bytech.hydropumped   * extractdata('hydro_pumped', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                elseif ~isfield(Power.FR.TSO.bytech,'hydro') && isfield(Power.FR.TSO.bytech,'hydrodam') && isfield(Power.FR.TSO.bytech,'hydropumped')
                    hydro   = Power.FR.TSO.bytech.hydrodam   * extractdata('hydro_reservoir', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) + ...    
                            Power.FR.TSO.bytech.hydropumped   * extractdata('hydro_pumped', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                elseif ~isfield(Power.FR.TSO.bytech,'hydro') && ~isfield(Power.FR.TSO.bytech,'hydrodam') && isfield(Power.FR.TSO.bytech,'hydropumped')
                    hydro   = Power.FR.TSO.bytech.hydropumped   * extractdata('hydro_pumped', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                elseif isfield(Power.FR.TSO.bytech,'hydro') && ~isfield(Power.FR.TSO.bytech,'hydrodam') && ~isfield(Power.FR.TSO.bytech,'hydropumped')
                    hydro   = Power.FR.TSO.bytech.hydro   * extractdata('hydro_runof', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                elseif ~isfield(Power.FR.TSO.bytech,'hydro') && isfield(Power.FR.TSO.bytech,'hydrodam') && ~isfield(Power.FR.TSO.bytech,'hydropumped')
                    hydro   = Power.FR.TSO.bytech.hydrodam   * extractdata('hydro_reservoir', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
                end
            case 'solar'
                solar = Power.FR.TSO.bytech.solar * extractdata('solar', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource));
            case 'biogas'
                biogas              = Power.FR.TSO.bytech.biogas   * extractdata('other_biogas', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource));
            case 'oil'
                oil                 = Power.FR.TSO.bytech.oil      * extractdata('oil', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
            case 'oil_chp'
                oilchp              = Power.FR.TSO.bytech.oil_chp      * extractdata('oil_chp', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
            case 'waste' 
                waste               = Power.FR.TSO.bytech.waste      * extractdata('waste', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ; 
            case 'nuclear'
                nuclear             = Power.FR.TSO.bytech.nuclear      * extractdata('nuclear_PWR', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ; 
            case 'biomass'
                biomass             = Power.FR.TSO.bytech.biomass      * extractdata('biomass', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ; 
            case 'coal'
                coal                = Power.FR.TSO.bytech.coal      * extractdata('coal', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
            case 'gas'
                gas                 = Power.FR.TSO.bytech.gas      * extractdata('gas', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
            case 'gas_chp'
                gas_chp             = Power.FR.TSO.bytech.gas_chp      * extractdata('gas_chp', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
            case 'wind'
                wind                = Power.FR.TSO.bytech.wind      * extractdata('windon', 'FR', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
        end
    end
    

    %%%
    % Calculate the emission intensity for FR
    totalprod = sum(temptable(1,{'biogas','biomass','coal','gas','gas_chp','hydro','hydrodam','hydropumped','nuclear','oil','oil_chp','solar','waste','wind'}).Variables) ;
    if totalprod == 0
        % The best would be to retrieve the latest data from the API
        Emissions.FR.TSO.(EFSource).intensityprod = 0 ;
    else
        Emissions.FR.TSO.(EFSource).intensityprod = (hydro + solar + biogas + nuclear + oil + oilchp + waste +  biomass + coal + gas + gas_chp + wind) / ...
                                                    totalprod ;
    end
end
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    EmissionTotal                             = ENTSOEEmissions(Power.FR.ENTSOE.bytech , Emissionsdatabase.(EFSource), 'FR', EmissionsCategory) ;
    if isa(EmissionTotal, 'struct')
        Emissions.FR.ENTSOE.(EFSource).total = sum(struct2array(EmissionTotal)) ;
        Emissions.FR.ENTSOE.(EFSource).intensityprod    = Emissions.FR.ENTSOE.(EFSource).total / sum(struct2array(Power.FR.ENTSOE.bytech)) ;
    else
        Emissions.FR.ENTSOE.(EFSource).total = 0 ;
        Emissions.FR.ENTSOE.(EFSource).intensityprod    = 0 ;
    end
end

%%%
% Re-allocate the energy byfuel for statistical purposes.
Power.FR.TSO.byfuel.nuclear = Power.FR.TSO.bytech.nuclear ;
Power.FR.TSO.byfuel.hydro = Power.FR.TSO.bytech.hydro + Power.FR.TSO.bytech.hydrodam + Power.FR.TSO.bytech.hydropumped;
Power.FR.TSO.byfuel.solar = Power.FR.TSO.bytech.solar ;
Power.FR.TSO.byfuel.oil = Power.FR.TSO.bytech.oil_chp + Power.FR.TSO.bytech.oil ;
Power.FR.TSO.byfuel.coal = Power.FR.TSO.bytech.coal ;
Power.FR.TSO.byfuel.gas = Power.FR.TSO.bytech.gas +  Power.FR.TSO.bytech.gas_chp;
Power.FR.TSO.byfuel.wind = Power.FR.TSO.bytech.wind ;
Power.FR.TSO.byfuel.biomass = Power.FR.TSO.bytech.biomass ;
Power.FR.TSO.byfuel.others = Power.FR.TSO.bytech.waste + Power.FR.TSO.bytech.biogas ;




%% Function extract from table
    function Emissionsextract = extractdata(Tech, Country, EmissionsCategory, Emissions)
        Emissionsextract = Emissions.(EmissionsCategory)(strcmp(Emissions.Technology,Tech) & strcmp(Emissions.Country,Country)) ;
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


end
