function Emissions = emissionsEK(Power, EmissionsCategory, Emissionsdatabase, cc)


EFSourcelist = {'EcoInvent' 'IPCC'} ;
if isa(Power, 'struct')
    temptable = struct2table(Power) ;
elseif isa(Power, 'timetable')
    temptable = Power ;
else
    temptable = table(0,'VariableNames',{'biomass'}) ;
end
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    if isa(Power, "double")
        Emissions.(cc).emissionskit.(EFSource).intensityprod = 0 ;
        Emissions.(cc).emissionskit.(EFSource).total = 0 ;
        continue ;
    else
        alltech = Power.Properties.VariableNames ;
    end
    initech = unique(Emissionsdatabase.(EFSource).Technology) ;
    for itech = 1:length(initech)
        powerout.(initech{itech}) = 0 ;
    end

    for itechname = 1:length(alltech)
        technameinTSO = alltech{itechname} ;
        switch technameinTSO
            case {'biomass';'blast_furnace';'coal';'coal_chp';'diesel_chp';'gas';'gas_chp';'geothermal';'hydro_pumped';'hydro_reservoir';'hydro_runof';'lignite_chp';'nuclear_BWR';'nuclear_PWR';'oil';'oil_chp';'other_biogas';'peat';'solar';'solar_small';'waste';'windoff';'windon'}
                powerout.(technameinTSO) = Power.(technameinTSO)(end) * extractdata(technameinTSO, cc, EmissionsCategory, Emissionsdatabase.newem.emissionFactors.(EFSource),EFSource);
            case 'unknown'
                switch EFSource
                    case 'IPCC' 
                        powerout.(technameinTSO) = Power.(technameinTSO)(end) * extractdata('unknown', cc, EmissionsCategory, Emissionsdatabase.newem.emissionFactors.(EFSource),EFSource);
                    case 'EcoInvent'
                        powerout.(technameinTSO) = Power.(technameinTSO)(end) * extractdata('mean', cc, EmissionsCategory, Emissionsdatabase.newem.emissionFactors.(EFSource),EFSource);
                end
        end
    end
    
    validfield = {'biomass';'blast_furnace';'coal';'coal_chp';'diesel_chp';'gas';'gas_chp';'geothermal';'hydro_pumped';'hydro_reservoir';'hydro_runof';'lignite_chp';'nuclear_BWR';'nuclear_PWR';'oil';'oil_chp';'other_biogas';'peat';'solar';'solar_small';'waste';'windoff';'windon';'unknown'} ;

    %%%
    % Calculate the emission intensity for FR
    totalprod = sum(temptable(1,validfield(ismember(validfield,alltech))).Variables, 'omitnan') ;
    % The best would be to retrieve the latest data from the API
    Emissions.(cc).emissionskit.(EFSource).intensityprod = 0 ;
    Emissions.(cc).emissionskit.(EFSource).total = 0 ;
    if ~totalprod == 0
        Emissions.(cc).emissionskit.(EFSource).intensityprod = sum(struct2array(powerout)) / totalprod ;
        Emissions.(cc).emissionskit.(EFSource).total = sum(struct2array(powerout)) ;
    end
end

%%%
% Re-allocate the energy byfuel for statistical purposes.

% Power.FR.TSO.byfuel.nuclear = Power.FR.TSO.bytech.nuclear ;
% Power.FR.TSO.byfuel.hydro = Power.FR.TSO.bytech.hydro + Power.FR.TSO.bytech.hydrodam + Power.FR.TSO.bytech.hydropumped;
% Power.FR.TSO.byfuel.solar = Power.FR.TSO.bytech.solar ;
% Power.FR.TSO.byfuel.oil = Power.FR.TSO.bytech.oil_chp + Power.FR.TSO.bytech.oil ;
% Power.FR.TSO.byfuel.coal = Power.FR.TSO.bytech.coal ;
% Power.FR.TSO.byfuel.gas = Power.FR.TSO.bytech.gas +  Power.FR.TSO.bytech.gas_chp;
% Power.FR.TSO.byfuel.wind = Power.FR.TSO.bytech.wind ;
% Power.FR.TSO.byfuel.biomass = Power.FR.TSO.bytech.biomass ;
% Power.FR.TSO.byfuel.others = Power.FR.TSO.bytech.waste + Power.FR.TSO.bytech.biogas ;


end
