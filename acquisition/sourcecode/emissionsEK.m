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
    
    switch cc
        case 'EE'
            [emission,temptable] = emissionsEstonia(temptable, Emissionsdatabase.newem.emissionFactors.(EFSource), EmissionsCategory, EFSource) ;
            allem = fieldnames(emission) ;
            temptable = struct2table(temptable) ;
            alltech = fieldnames(temptable) ;
            for eachfield = 1:length(allem)
                powerout.(allem{eachfield}) = emission.(allem{eachfield}) ;
            end
        otherwise
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
    end

    
    
    validfield = {'biomass';'blast_furnace';'coal';'coal_chp';'diesel_chp';'gas';'gas_chp';'geothermal';'hydro_pumped';'hydro_reservoir';'hydro_runof';'lignite_chp';'nuclear_BWR';'nuclear_PWR';'oil';'oil_chp';'other_biogas';'peat';'solar';'solar_small';'waste';'windoff';'windon';'unknown'} ;

    %%%
    % Calculate the emission intensity
    totalprod = sum(temptable(1,validfield(ismember(validfield,alltech))).Variables, 'omitnan') ;
    % The best would be to retrieve the latest data from the API
    Emissions.(cc).emissionskit.(EFSource).intensityprod = 0 ;
    Emissions.(cc).emissionskit.(EFSource).total = 0 ;
    if ~totalprod == 0
        Emissions.(cc).emissionskit.(EFSource).intensityprod = sum(struct2array(powerout)) / totalprod ;
        Emissions.(cc).emissionskit.(EFSource).total = sum(struct2array(powerout)) ;
    else
        Emissions.(cc).emissionskit.(EFSource).intensityprod = extractdata('mean', cc, EmissionsCategory, Emissionsdatabase.newem.emissionFactors.(EFSource),EFSource) ;    
    end
end



end
