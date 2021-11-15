function databyfuel = ENTSOEbyfuel(Power)

bid =  {'B01'	'Biomass'   'biomass'                          
        'B02'	'Fossil Brown coal/Lignite' 'coal'
        'B03'	'Fossil Coal-derived gas' 'coal'
        'B04'	'Fossil Gas' 'gas'
        'B05'	'Fossil Hard coal' 'coal'
        'B06'	'Fossil Oil' 'oil'
        'B07'	'Fossil Oil shale' 'oil'
        'B08'	'Fossil Peat' 'peat'
        'B09'	'Geothermal' 'geothermal'
        'B10'	'Hydro Pumped Storage' 'hydro'
        'B11'	'Hydro Run-of-river and poundage' 'hydro'
        'B12'	'Hydro Water Reservoir' 'hydro'
        'B13'	'Marine' 'marine'
        'B14'	'Nuclear' 'nuclear'
        'B15'	'Other renewable' 'others'
        'B16'	'Solar' 'solar'
        'B17'	'Waste' 'waste'
        'B18'	'Wind Offshore' 'wind'
        'B19'	'Wind Onshore' 'wind'
        'B20'	'Other' 'others'} ;
    
bidname = bid(:, 2) ;     
nameout = strrep(lower(bidname),' ','_') ;
nameout = strrep(nameout, '/', '_') ;
nameout = strrep(nameout, '-', '_') ;

databyfuel = struct ;       
for ifuel = 1:length(nameout)
    fuelname = bid{ifuel,3} ;
    if isa(Power, 'timetable')
        if any(ismember(Power.Properties.VariableNames,nameout{ifuel}))
            if isfield(databyfuel, fuelname)
                databyfuel.(fuelname) = databyfuel.(fuelname) + Power.(nameout{ifuel}) ;
            else
                databyfuel.(fuelname) = Power.(nameout{ifuel}) ;
            end
        end
    elseif isa(Power, 'struct')
        if isfield(Power,nameout{ifuel})
            if isfield(databyfuel, fuelname)
                databyfuel.(fuelname) = databyfuel.(fuelname) + Power.(nameout{ifuel}) ;
            else
                databyfuel.(fuelname) = Power.(nameout{ifuel}) ;
            end
        end
    end
end
