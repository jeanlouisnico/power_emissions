function [databyfuel] = importswedenfuel(yearstat)
Fuel_eq = {"EO1"      'oil'
           "E02"      'oil'
           "E2-3" 'oil'
           "E3-5" 'oil'
           "E4" 'oil'
           "E5" 'oil'
           "skol" 'coal'
           "torva" 'peat'
           "trädbra" 'biomass'
           "trädbrb" 'biomass'
           "fot" 'oil'
           "dies" 'oil'
           "natgas" 'gas'
           "deponi" 'biogas'
           "kok" 'gas'
           "mas" 'black_furnace'
           "svart" 'biomass'
           "prop" 'gas'
           "karn" 'nuclear'
           "sop" 'waste'
           "annat" 'other'
           "suma" ''
           "over" ''
           "sumb" ''
           "vkrprod" ''
           };
PP = {'Kraftvindkond'
          'Kraftvvarmkr'
          'Kravarmkond'
          'Kondensst'
          'Annan'} ;
%% Import data from statistic Estonia

options = weboptions('RequestMethod','post', 'MediaType','application/json');
n = 0 ;

while n == 0
    S.query{1} = struct("code", "Prodslag", "selection",...
                            struct("filter", "item", "values", {PP}));
    S.query{2} = struct("code", "Tid", "selection",...
                            struct("filter", "item", "values", {{num2str(yearstat)}})) ;
    S.response = struct("format", 'json') ;
    s = jsonencode(S);
    try
        response = webwrite('http://api.scb.se/OV0104/v1/doris/en/ssd/START/EN/EN0105/BrforelARb',s, options) ;
        n = 1 ;
    catch
        yearstat = yearstat - 1 ;
    end
end
databyfuel = struct ;
for ifuel = 1:size(response.data, 1)
    fueltype = response.data(ifuel).key{2} ;
    fuelcat  = Fuel_eq{ismember(string(Fuel_eq(:,1)),fueltype),2} ;
    fuelamount = str2double(response.data(ifuel).values) ;
    if ~isempty(fuelcat) && ~isnan(fuelamount)  && isa(fuelamount, 'double')
        if isfield(databyfuel, fuelcat)
            databyfuel.(fuelcat) = databyfuel.(fuelcat) + fuelamount ;
        else
            databyfuel.(fuelcat) = fuelamount ;
        end
    end
end
