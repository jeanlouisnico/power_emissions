function [emout,subDB] = compareEmData(EmissionsCategory, Emissionsdatabase, Country)

% EmissionsCategory = 'GlobalWarming'     ;
% Emissionsdatabase = load_emissions      ;    

country_code = countrycode(Country) ;
country      = country_code.alpha2 ;


switch country
    case 'EL'
        country = 'GR' ;
end


EmDB = Emissionsdatabase.newem.emissionFactors ;

subDB = fieldnames(EmDB) ;
techunique = {} ;
for isubdb = 1:length(subDB)
    subdbname = subDB{isubdb} ;
    DB = EmDB.(subdbname).zoneOverrides.(country) ;
    tech = fieldnames(DB) ;
    techunique = [techunique ; tech] ;
end 

tech2loop = unique(techunique) ;
emout = {};
for isubdb = 1:length(subDB)
    subdbname = subDB{isubdb} ;
    DB = EmDB.(subdbname).zoneOverrides.(country) ;
    startline = 0 ;
    for itech = 1:length(tech2loop)
        techname = tech2loop{itech} ;
        emout{startline + 1,1} = techname ;
        if isfield(DB,techname)
            emout{startline + 1,isubdb + 1} = DB.(techname).(EmissionsCategory).value ;
        else
            emout{startline + 1,isubdb + 1} = 0 ;
        end
        startline = startline + 1 ;
    end
end 
