function [emission,power] = emissionsEstonia(energy, Emissionsdatabase, EmissionsCategory, EFSource)

alltech = energy.Properties.VariableNames ;
emission = struct ; 
for itech = 1:width(energy)
    techname = alltech{itech} ;
    switch techname
        case {'heavy_fuel_oil', 'light_fuel_oil', 'shale_oil', 'oil_shale'}
            technamein = 'oil_chp' ;
        case {'milled_peat' 'peat_briquette', 'sod_peat'}
            technamein = 'peat' ;
        case 'coal'
            technamein = 'coal_chp' ;
        case {'firewood', 'pellets', 'wood_chips'}
            technamein = 'biomass' ;
        case 'natural_gas' 
            technamein = 'gas' ;
        case 'wood_waste_industrial'
            technamein = 'waste' ;
        case 'wind'
            technamein = 'windon' ;
        case 'solar'
            technamein = 'solar' ;
        otherwise
            technamein = techname ;
    end
    try
        emi = extractdata(technamein, 'EE', EmissionsCategory, Emissionsdatabase,EFSource) ;
    catch
        emi = extractdata('mean', 'EE', EmissionsCategory, Emissionsdatabase,EFSource) ;
    end
    % extractdata(technameinTSO, cc, EmissionsCategory, Emissionsdatabase.newem.emissionFactors.(EFSource),EFSource);
    if ~isempty(technamein)
        emi = extractdata(technamein, 'EE', EmissionsCategory, Emissionsdatabase,EFSource) ;
    end
    
    if isfield(emission,technamein)
        emission.(technamein) = emission.(technamein) + energy.(techname) .* emi ;
        power.(technamein)    = power.(technamein) + energy.(techname) ;
    else
        emission.(technamein) = energy.(techname) .* emi ;
        power.(technamein) = energy.(techname) .* 1 ;
    end    
end

end
