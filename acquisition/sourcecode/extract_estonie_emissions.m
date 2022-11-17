function [energy, databyfuel] = extract_estonie_emissions(power)

% Load the fuel data once a day when a new day is coming.
% Fisrt try to locate the file for the current day
currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;
timeextract = datetime(datetime('now') - hours(timezone)) ;
isforeign = isforeign_region ;

if isfile('Estonia_data.csv')
    FileInfo = dir('Estonia_data.csv') ;
    datecompare = datetime('now') ;
    datefile    = datetime(FileInfo.datenum, "ConvertFrom", "datenum") ;

    % Check daily if the data have changed
    if ~(datecompare.Year == datefile.Year && datecompare.Month==datefile.Month && datecompare.Day==datefile.Day)
        [fuelEm, fuelEmnorm] = importestoniafuel ;
        writetimetable(fuelEmnorm, 'Estonia_data.csv') ;
    else
        fuelEmnorm = readtimetable('Estonia_data.csv') ;
    end
else
    [fuelEm, fuelEmnorm] = importestoniafuel ;
    writetimetable(fuelEmnorm, 'Estonia_data.csv') ;
end
try
    systemdata_month = webread('https://dashboard.elering.ee/api/balance/total/latest') ;
catch
end
%% Clean the emission file from nan values 
% if it is there since we do not need them and it is easier to extract the
% last valid values from the dataset
fuelEmnorm(find(isnan(fuelEmnorm.coal)),:) = [];

findrow = (fuelEmnorm.Time.Year == (timeextract.Year - 1) & fuelEmnorm.Time.Month == timeextract.Month) ;

nyear = 0 ;
n = 0 ;
% Locate the last available month from the fuel data
while n == 0
     nyear = nyear + 1 ;
     timetarget = timeextract - calmonths(nyear) ;
     if any((fuelEmnorm.Time.Year == (timetarget.Year) & fuelEmnorm.Time.Month == timetarget.Month) )
         n = 1;
         findrow = (fuelEmnorm.Time.Year == (timetarget.Year) & fuelEmnorm.Time.Month == timetarget.Month) ;
     end
end
fuelratiotemp.thermal3 = fuelEmnorm(findrow,:) ;

% Get the previous year data for the same month than today
timetarget = timeextract - calyears(1) ;
    findrow = (fuelEmnorm.Time.Year == (timetarget.Year) & fuelEmnorm.Time.Month == timetarget.Month) ;
fuelratiotemp.thermal1 = fuelEmnorm(findrow,:) ;

% Get the previous year data for the same month than the last data
% available to get a trend and extrapolate data
timetarget = timeextract - calmonths(nyear) - calyears(1) ;
    findrow = (fuelEmnorm.Time.Year == (timetarget.Year) & fuelEmnorm.Time.Month == timetarget.Month) ;
fuelratiotemp.thermal2 = fuelEmnorm(findrow,:) ;

Ratio_year_n_1  = fuelratiotemp.thermal1.Variables ./ fuelratiotemp.thermal2.Variables ;
Ratio_year_n_1(isinf(Ratio_year_n_1)|isnan(Ratio_year_n_1)) = 0 ;
fuelratioout   = array2table(Ratio_year_n_1 .* fuelratiotemp.thermal3.Variables, 'VariableNames', fuelratiotemp.thermal1.Properties.VariableNames) ;

%% Calculate the amount of energy by fuel

if isfield(power, 'thermal')
    byfuel = fuelratioout.Variables * power.thermal ;
    energy.byfuel = array2table(byfuel, 'VariableNames',  fuelratioout.Properties.VariableNames) ;
elseif isa(power,'struct')
    thermal = power.consumption - power.production_renewable - power.solar ;
    energy.byfuel = array2table(fuelratioout.Variables * thermal, 'VariableNames',  fuelratioout.Properties.VariableNames) ;
else
    thermal = 0 ;
    energy.byfuel = array2table(fuelratioout.Variables * thermal, 'VariableNames',  fuelratioout.Properties.VariableNames) ;
end
if isfield(power, 'wind')
    if isempty(power.wind)
        energy.byfuel = addvars(energy.byfuel, 0, 'NewVariableNames', 'wind') ;
    else
        energy.byfuel = addvars(energy.byfuel, power.wind, 'NewVariableNames', 'wind') ;
    end
else
    energy.byfuel = addvars(energy.byfuel, power.production_renewable, 'NewVariableNames', 'wind') ;
end

if isempty(power.solar)
    energy.byfuel = addvars(energy.byfuel, 0, 'NewVariableNames', 'solar') ;
else
    energy.byfuel = addvars(energy.byfuel, power.solar, 'NewVariableNames', 'solar') ;
end

%% Calculate power by fuel category

fuelcat = {'coal'           'coal'
           'firewood'       'biomass'
           'heavy_fuel_oil' 'oil'
           'light_fuel_oil' 'oil'
           'milled_peat'    'peat'
           'natural_gas'    'gas'
           'oil_shale'      'oil'
           'peat_briquette' 'peat'
           'pellets'        'biomass'
           'shale_oil'      'oil'
           'sod_peat'       'peat'
           'wood_chips'     'biomass'
           'wood_waste_industrial' 'waste'
           'wind'           'wind'
           'solar'          'solar'} ;

databyfuel = struct ;       
for ifuel = 1:length(fuelcat)
    fuelname = fuelcat{ifuel,2} ;
    if isfield(databyfuel, fuelname)
        databyfuel.(fuelname) = databyfuel.(fuelname) + energy.byfuel.(fuelcat{ifuel,1}) ;
    else
        databyfuel.(fuelname) = energy.byfuel.(fuelcat{ifuel,1}) ;
    end
end
