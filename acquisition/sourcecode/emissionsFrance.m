function [Power, Emissions] = emissionsFrance(Power, EmissionsCategory, Emissionsdatabase, Emissions)


EFSourcelist = {'EcoInvent' 'IPCC'} ;
if isa(Power.FR.TSO.bytech, 'struct')
    temptable = struct2table(Power.FR.TSO.bytech) ;
else
    temptable = table(0,'VariableNames',{'biomass'}) ;
end
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    if isa(Power.FR.TSO.bytech, "double")
        Emissions.FR.TSO.(EFSource).intensityprod = 0 ;
        continue ;
    else
        alltech = fieldnames(Power.FR.TSO.bytech) ;
    end
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

%%%
% Re-allocate the energy byfuel for statistical purposes.
if isa(Power.FR.TSO.bytech, "double")
    Power.FR.TSO.byfuel.nuclear = 0;
    Power.FR.TSO.byfuel.hydro = 0;
    Power.FR.TSO.byfuel.solar = 0 ;
    Power.FR.TSO.byfuel.oil = 0 ;
    Power.FR.TSO.byfuel.coal = 0 ;
    Power.FR.TSO.byfuel.gas =0;
    Power.FR.TSO.byfuel.wind = 0;
    Power.FR.TSO.byfuel.biomass = 0 ;
    Power.FR.TSO.byfuel.others = 0 ;
else
    Power.FR.TSO.byfuel.nuclear = Power.FR.TSO.bytech.nuclear ;
    Power.FR.TSO.byfuel.hydro = Power.FR.TSO.bytech.hydro + Power.FR.TSO.bytech.hydrodam + Power.FR.TSO.bytech.hydropumped;
    Power.FR.TSO.byfuel.solar = Power.FR.TSO.bytech.solar ;
    Power.FR.TSO.byfuel.oil = Power.FR.TSO.bytech.oil_chp + Power.FR.TSO.bytech.oil ;
    Power.FR.TSO.byfuel.coal = Power.FR.TSO.bytech.coal ;
    Power.FR.TSO.byfuel.gas = Power.FR.TSO.bytech.gas +  Power.FR.TSO.bytech.gas_chp;
    Power.FR.TSO.byfuel.wind = Power.FR.TSO.bytech.wind ;
    Power.FR.TSO.byfuel.biomass = Power.FR.TSO.bytech.biomass ;
    Power.FR.TSO.byfuel.others = Power.FR.TSO.bytech.waste + Power.FR.TSO.bytech.biogas ;
end

end
