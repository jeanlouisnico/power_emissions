    function [byfuel] = FingridEmissions(CHP_DH_Fuel, Emissionsdatabase, EFSource, CHP_Ind_Fuel, Sep_Fuel, Windpower, WindCat, EmissionsCategory, Power)
        CHPname = fieldnames(CHP_DH_Fuel) ;

        for ichp = 1:length(CHPname)
            Cat = CHPname{ichp} ;
            switch Cat
                case 'others'
                    fuelcat.chp = 'other_biogas' ;
                    fuelcat.sep = 'other_biogas' ;
                case 'coal'
                    fuelcat.chp = 'coal_chp' ;
                    fuelcat.sep = 'coal' ;
                case 'oil'
                    fuelcat.chp = 'oil_chp' ;
                    fuelcat.sep = 'oil' ;
                case 'gas'
                    fuelcat.chp = 'gas_chp' ;
                    fuelcat.sep = 'gas' ;
                otherwise
                    fuelcat.chp = Cat ;
                    fuelcat.sep = Cat ;
            end
            emifactor.chp = extractdata(fuelcat.chp, 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) ; 
            emifactor.sep = extractdata(fuelcat.sep, 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) ; 
            CHP_DH_Emissions.(Cat)  = CHP_DH_Fuel.(Cat) * emifactor.chp ;
            CHP_Ind_Emissions.(Cat) = CHP_Ind_Fuel.(Cat) * emifactor.chp ;
            try 
                Sep_Emissions.(Cat) = Sep_Fuel.(Cat) * emifactor.sep ;
            catch
                Sep_Emissions.(Cat) = 0 ;
            end
        end

        Windname = fieldnames(Windpower) ;

        for iwind = 1:length(Windname)
            Cat = Windname{iwind} ;
            Wind_Emissions.(Cat)  = WindCat.(Cat) * extractdata('windon', 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
        end
        %%% Total Emissions Ecoinvent
        CHP_DH_Emissions.Total  = sum(struct2array(CHP_DH_Emissions)) ;
        CHP_Ind_Emissions.Total = sum(struct2array(CHP_Ind_Emissions)) ;
        Sep_Emissions.Total     = sum(struct2array(Sep_Emissions)) ;
        hydro                   = Power.FI.TSO.bytech.HydroP * extractdata('hydro_runof', 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
        solar                   = Power.FI.TSO.bytech.SolarP * extractdata('solar', 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) ;
        wind                    = sum(struct2array(Wind_Emissions)) ;
        nuclear                 = Power.FI.TSO.bytech.NuclearP * (extractdata('nuclear_PWR', 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) * .36 + ...
                                                                       extractdata('nuclear_BWR', 'FI', EmissionsCategory, Emissionsdatabase.(EFSource)) * .64) ;

%         %%% Total Emissions Energia Teolisuus
%         CHP_DH_EmissionsET.Total  = sum(struct2array(CHP_DH_EmissionsET)) ;
%         CHP_Ind_EmissionsET.Total = sum(struct2array(CHP_Ind_EmissionsET)) ;
%         Sep_EmissionsET.Total     = sum(struct2array(Sep_EmissionsET)) ;

        %%% Final Emissions Ecoinvent
        % This is the final emissions expressed in kgCO2 (in case of global
        % warming indicator)
%         total = nuclear + wind + solar + hydro + Sep_Emissions.Total + CHP_Ind_Emissions.Total + CHP_DH_Emissions.Total ;
        %%%
        % This is the emission intensity expressed in kg/MWh or g/kWh for the
        % EcoInvent database

        %%% Final Emissions Energia Teolisuus
        % This is the final emissions expressed in kgCO2.
        %%%
        % This is the emission intensity expressed in kg/MWh or g/kWh for the
        % Energia Teolisuus database
        
        %%% Emission by fuel EcoInvent
        byfuel.nuclear   = nuclear ;
        byfuel.biomass   = Sep_Emissions.biomass + CHP_Ind_Emissions.biomass + CHP_DH_Emissions.biomass ;
        byfuel.wind      = wind ;
        byfuel.solar     = solar  ;
        byfuel.hydro     = hydro  ;
        byfuel.coal      = Sep_Emissions.coal + CHP_Ind_Emissions.coal + CHP_DH_Emissions.coal ;
        byfuel.oil       = Sep_Emissions.oil + CHP_Ind_Emissions.oil + CHP_DH_Emissions.oil ;
        byfuel.peat      = Sep_Emissions.peat + CHP_Ind_Emissions.peat + CHP_DH_Emissions.peat ;
        byfuel.gas       = Sep_Emissions.gas + CHP_Ind_Emissions.gas + CHP_DH_Emissions.gas ;
        byfuel.others    = Sep_Emissions.others + CHP_Ind_Emissions.others + CHP_DH_Emissions.others ;
        
    end