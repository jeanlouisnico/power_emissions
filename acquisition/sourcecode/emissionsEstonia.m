function emission = emissionsEstonia(energy, Emissionsdatabase, EmissionsCategory)

alltech = energy.byfuel.Properties.VariableNames ;
emission = struct ; 
for itech = 1:width(energy.byfuel)
    techname = alltech{itech} ;
    technamein = [] ;
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
            emi = 500 ;
    end
    if ~isempty(technamein)
        emi = extractdata(technamein, 'EE', EmissionsCategory, Emissionsdatabase) ;
    end
    
    if isfield(techname, emission)
        emission.(techname) = emission.(techname) + Power.(techname) .* emi ;
    else
        emission.(techname) = energy.byfuel.(techname) .* emi ;
    end    
end


%% Function extract from table
    function Emissionsextract = extractdata(Tech, Country, EmissionsCategory, Emissions)
        Emissionsextract = Emissions.(EmissionsCategory)(strcmp(Emissions.Technology,Tech) & strcmp(Emissions.Country,Country)) ;
    end

end
