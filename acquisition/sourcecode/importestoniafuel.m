function [fuelEm, fuelEmnorm] = importestoniafuel

% estonia_fuel = readtable('estonia_fuel.csv') ;
fuel_coefficient_estonia = readtable('fuel_coefficient_estonia.csv') ;


Fuel_eq = {'Coal, t'	'coal'
           'Firewood, m³'	'firewood'
            'Wood chips, m³'	'Wood chips'
            'Pellets, t'	'Pellets'
            'Wood waste industrial, m³'	'Wood waste industrial'
            'Milled peat, t'	'Milled peat'
            'Sod peat, t'	'Sod peat'
            'Peat-briquette, t'	'Peat_briquette'
            'Oil shale, t'	'Oil shale'
            'Heavy fuel oil, t'	'Heavy fuel oil'
            'Light fuel oil, t'	'Light fuel oil'
            'Shale oil, t'	'Shale oil'
            'Natural gas, thousand m³'	'Natural gas'
};

%% Import data from statistic Estonia

options = weboptions('RequestMethod','post', 'MediaType','application/json');
for ifuel = 1:13
    S = struct("query", struct("code", "Kütuse liik", "selection",...
    struct("filter", "item", "values", {{num2str(ifuel)}})));
    S.query = {S.query};
    s = jsonencode(S) ;

    response = webwrite('https://andmed.stat.ee/api/v1/en/stat/KE22',s, options) ;

    data = reshape(response.value, [12], [540/12]) ;
    dataextracttemp = data(:,1:3:end) ;                    
    dataextracttemp = dataextracttemp' ;
    dataextracttemp =  array2table(dataextracttemp, "VariableNames", cellstr(datestr(datetime(1,1:12,1),'mmmm'))) ;
    fuelname = response.dimension.K_tuseLiik.category.label.(['x' num2str(ifuel)]) ;
    TypeOfFuel = {fuelname} ;
    TypeOfFuel = repmat(TypeOfFuel, 15, 1) ;
    Indicator = {'Consumption of fuels in quantity'} ;
    Indicator = repmat(Indicator, 15, 1) ;
    Year = struct2cell(response.dimension.Aasta.category.label) ;
    Year = str2double(Year) ;
    
    if ifuel == 1
        dataextract = addvars(dataextracttemp, TypeOfFuel, Indicator, Year) ;
    else
        dataextracttemp = addvars(dataextracttemp, TypeOfFuel, Indicator, Year) ;
        dataextract = [dataextract ; dataextracttemp] ;
    end
    dataextracttemp = [] ;
end

%% Re-organise the data to be readable by fuel

Allfuels = unique(dataextract.TypeOfFuel) ;

for ifuel = 1:length(Allfuels)
    fuelname = Allfuels{ifuel} ;
    fuelcat = Fuel_eq{contains(Fuel_eq(:,1), fuelname),2} ;
    
    fuelcat = strrep(lower(fuelcat),' ','_') ;
    fuelcat = strrep(fuelcat, ' ', '_') ;
    fuelcat = strrep(fuelcat, '/', '_') ;
    fuelcat = strrep(fuelcat, '-', '_') ;
    
    Monthdata           = dataextract(contains(dataextract.TypeOfFuel, fuelname),  [{'Year'}; cellstr(datestr(datetime(1,1:12,1),'mmmm'))]) ;
    Monthdata_noyear    = dataextract(contains(dataextract.TypeOfFuel, fuelname),  cellstr(datestr(datetime(1,1:12,1),'mmmm'))) ;
    Alldata.(fuelcat)   = reshape(Monthdata_noyear.Variables', length(unique(dataextract.Year)) * 12, []) ;
    
end
fuel_cons = struct2table(Alldata) ;

fuel_cons = table2timetable(fuel_cons, 'RowTimes', datetime(Monthdata.Year(1), 1, 1):calmonths(1):datetime(Monthdata.Year(end), 12, 1)) ;

%% Convert the fuel consumption in energy content
allfuelsemcat = fuel_coefficient_estonia{:,1} ;
    allfuelsemcat = strrep(lower(allfuelsemcat),' ','_') ;
    allfuelsemcat = strrep(allfuelsemcat, ' ', '_') ;
    allfuelsemcat = strrep(allfuelsemcat, '/', '_') ;
    allfuelsemcat = strrep(allfuelsemcat, '-', '_') ;
fuel_coefficient_estonia{:,1} = allfuelsemcat ;

for ifuel = 1:width(fuel_cons)
    fuelname = fuel_cons.Properties.VariableNames{ifuel} ;
    
    coeff_factor = fuel_coefficient_estonia{contains(fuel_coefficient_estonia.fuel, fuelname),2}  ;
    
    switch fuelname
        case {'firewood'}
            densityfactor = .48 ;
        case {'wood_chips'}
            densityfactor = .2 ;
        case {'wood_waste_industrial'}
            densityfactor = .3 ;
        otherwise
            densityfactor = 1 ;
    end
    fuelEm.(fuelname) = fuel_cons.(fuelname) * densityfactor * coeff_factor ;
end

fuelEm = struct2table(fuelEm) ;
fuelEm = table2timetable(fuelEm, 'RowTimes', datetime(Monthdata.Year(1), 1, 1):calmonths(1):datetime(Monthdata.Year(end), 12, 1)) ;

fuelEmnorm = fuelEm.Variables ./ sum(fuelEm.Variables, 2, 'omitnan') ;

fuelEmnorm = array2timetable(fuelEmnorm, 'RowTimes', datetime(Monthdata.Year(1), 1, 1):calmonths(1):datetime(Monthdata.Year(end), 12, 1), 'VariableNames', fuelEm.Properties.VariableNames ) ;
