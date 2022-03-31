%% Function extract from table
    function Emissionsextract = extractdata(Tech, Country, EmissionsCategory, Emissions, source)
    switch Country
        case 'EL'
            Country = 'GR' ;
    end
        if isa(Emissions, 'table')
            % This is the original table extract
            Emissionsextract = Emissions.(EmissionsCategory)(strcmp(Emissions.Technology,Tech) & strcmp(Emissions.Country,Country)) ;
        elseif isa(Emissions, 'struct')
            % This is from the json data
            try
                Emissionsextract = Emissions.zoneOverrides.(Country).(Tech).(EmissionsCategory).value ;
            catch
                switch source
                    case 'EcoInvent'
                        if isfield(Emissions.zoneOverrides.RoW, Tech)
                            Emissionsextract = Emissions.zoneOverrides.RoW.(Tech).(EmissionsCategory).value ;
                        else
                            Emissionsextract = 500 ;
                        end
                    case 'IPCC'
                        if isfield(Emissions.zoneOverrides.(Country), Tech)
                            Emissionsextract = Emissions.zoneOverrides.(Country).(Tech).(EmissionsCategory).value ;
                        else
                            Emissionsextract = 500 ;
                        end
                end
            end
        end
        if isempty(Emissionsextract)
            wx=1 ;
        end
    end