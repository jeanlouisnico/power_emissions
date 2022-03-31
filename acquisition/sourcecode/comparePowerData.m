function [emout,subDB] = comparePowerData(Country)

% EmissionsCategory = 'GlobalWarming'     ;
% Emissionsdatabase = load_emissions      ;    

% Country = 'Finland' ;

country_code = countrycode(Country) ;
country      = country_code.alpha2 ;

switch country
    case 'EL'
        country2 = country ;
        country = 'GR' ;
    otherwise
        country2 = country ;
end


Powerload = load('testing_xchangev2.mat') ;
Power = Powerload.Power ;

allcountries = {Power(:).zone}' ;

countryindex = contains(allcountries,country2) ;

subDB = {'ENTSOE' 'TSO'} ;
techunique = {} ;
for isubdb = 1:length(subDB)
    subdbname = subDB{isubdb} ;
    switch subdbname
        case 'ENTSOE'
            Powerout = transformENTSOE(Power(countryindex).ENTSOE.bytech.(country), country) ;
            EnergyENTSOE = Powerout ;
            tech = fieldnames(Powerout) ;
        case 'TSO'
            if ~isa(Power(countryindex).TSO, 'double')
                Powerout = Power(countryindex).TSO.emissionskit ;
                tech = Powerout.Properties.VariableNames' ;
            else 
                continue ;
            end
    end
    techunique = [techunique ; tech] ;
end 

tech2loop = unique(techunique) ;
emout = {};
for isubdb = 1:length(subDB)
    subdbname = subDB{isubdb} ;
    switch subdbname
        case 'ENTSOE'
            DB = EnergyENTSOE ;
        case 'TSO'
            if ~isa(Power(countryindex).TSO, 'double')
                DB = table2struct(timetable2table(Power(countryindex).TSO.emissionskit)) ;
            else
                continue;
            end
    end
    startline = 0 ;
    for itech = 1:length(tech2loop)
        techname = tech2loop{itech} ;
        emout{startline + 1,1} = techname ;
        if isfield(DB,techname)
            emout{startline + 1,isubdb + 1} = DB.(techname) ;
        else
            emout{startline + 1,isubdb + 1} = 0 ;
        end
        startline = startline + 1 ;
    end
end 

function Powerout = transformENTSOE(Power, country)
    if isa(Power, 'timetable')
        AllTech = Power.Properties.VariableNames ;
        Powerout = struct ; 
        for itech2 = 1:length(AllTech)
            techname2 = AllTech{itech2} ;
            if Power.(techname2) == 0 
                Powerout.(techname2) = 0;
            else
                switch country
                    case ''
                    otherwise
                        try
                            switch techname2
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
                                    technamein = techname2   ; 
                            end                            
                        catch
                            continue ;
                        end

                        if isfield(technamein, Powerout)
                            Powerout.(technamein) = Powerout.(technamein) + Power.(techname2) ;
                        else
                            Powerout.(technamein) = Power.(techname2)  ;
                        end
                end
            end
        end
    else
        Powerout = 0 ;
    end
end

end