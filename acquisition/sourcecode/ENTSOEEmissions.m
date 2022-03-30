%% Function emission extract ENTSOE
    function emission = ENTSOEEmissions(Power, Emissions, country, EmissionsCategory, EFSource)
        %%%
        % For a given country, emissions are calculated from the ENTSOE
        % database. Equivalence table between the ENTSOE database and the
        % emission database is given in the switch form below.
        switch country
            case 'EL'
                country = 'GR' ;
        end
        if isa(Power, 'timetable')
            AllTech = Power.Properties.VariableNames ;
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
                                emi = extractdata(technamein, country, EmissionsCategory, Emissions, EFSource) ;
                                if isempty(emi)
                                    x  =1 ;
                                end
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