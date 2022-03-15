function [IndCHP, DHCHP, Sep, capacity, fuelratio] = extract2stat
%%% File set up
% The Energy Authority of Finland maintains a registry of all active powerplant
% in Finland and provide their rated output capacity as well as the type of
% fuel they are using. We are using this registry to make statistics out of
% it and categorise the powerplant capacity by fuel type.
%%% Define the time

timelocal = datetime('now','TimeZone','local') ;
timeextract = datetime(timelocal,'TimeZone','UTC') ;


p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

inputfile = [fparts{1} filesep 'input' filesep 'bycountry' filesep 'FI' filesep 'Energiaviraston voimalaitosrekisteri.xlsx'] ;

if isfile(inputfile)
    FileInfo = dir(inputfile) ;
    datecompare = datetime("now") ;
    datefile    = datetime(FileInfo.datenum, "ConvertFrom", "datenum") ;

    % Check monthly if the data have changed
    if ~(datecompare.Year == datefile.Year && datecompare.Month==datefile.Month)
        t1 = rekisterypostgre(true) ;
    else
        t1 = rekisterypostgre(false) ;
    end
else
    % If the file does not exist, create it, store it in the sql DB and
    % return the table
    t1 = rekisterypostgre(true) ;
end

r = strcmp(t1.type, 'Hydro power') ;
t1.mainfuel(r) = {'Water'} ;

r = strcmp(t1.type, 'Wind power') ;
t1.mainfuel(r) = {'Wind'} ;

r = strcmp(t1.type, 'Solar') ;
t1.mainfuel(r) = {'Solar'} ;

%%% Import the fuel usage statistics
% data are from https://energia.fi/uutishuone/materiaalipankki/sahkon_kuukausitilasto.html

Fueluse.chp = readtable('chp.csv') ;
Fueluse.sep = readtable('sep.csv') ;

%%% Fuel categories
% The fuels are categorised using the statistic Finland fuel categories:
% Peat, Biomass, Natural gas, Other, Oil, and Coal

predefcat = {'peat'             'Peat'
             'biomass'          'Industrial wood residues'
             'gas'              'Natural gas'
             'other'           'Other by-products and wastes used as fuel'
             'biomass'          'Forest fuelwood'
             'biomass'          'Black liquor and concentrated liquors'
             'coal'             'Hard coal and anthracite'
             'biomass'          'By-products from wood processing industry'
             'oil'              'Heavy distillates'
             'other'           'Exothermic heat from industry'
             'oil'              'Light distillates'
             'other'           'Biogas'
             'oil'              'Medium heavy distillates'
             'oil'              'Heavy distillates'
             'coal'             'Blast furnace gas'} ;

%%% Extract data for Industrial CHP
nametech = 'Industry CHP' ;
IndCHP = extractper(nametech, t1, predefcat) ;
IndCHP.totalload = orderfields(IndCHP.totalload) ;
capacity.IndCHP = IndCHP ;
%%% Extract data for District Heating CHP
nametech = 'District heating CHP' ;
DHCHP = extractper(nametech, t1, predefcat) ;
DHCHP.totalload = orderfields(DHCHP.totalload) ;
capacity.DHCHP = DHCHP ;
%%% Extract data for Separate electricity production
nametech = 'Separate electricity production' ;
Sep = extractper(nametech, t1, predefcat) ;
capacity.Sep = Sep ;
%%% Extract data for Wind power
nametech = 'Wind power' ;
capacity.wind = extractwind(nametech, t1) ;

nametech = 'Hydro power' ;
capacity.hydro = extracthydro(nametech, t1) ;

nametech = 'Solar' ;
capacity.solar = extractsolar(nametech, t1) ;

%% The energiateolisuus method
tech = {'chp' 'sep'} ;
for itech = 1:length(tech)
    techn = tech{itech} ;
    
    %%% Find ratio fuel per month
%     findrow = (Fueluse.(techn).Year == (timeextract.Year - 1) & Fueluse.(techn).Month == timeextract.Month) ;
    fuellist = fieldnames(DHCHP.totalload) ;
    
    nyear = 0 ;
    n = 0 ;
    % Locate the last available month from the fuel data
    while n == 0
         nyear = nyear + 1 ;
         timetarget = timeextract - calmonths(nyear) ;
         if any((Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) )
             n = 1;
             predictedstep = nyear ;
%              findrow = (Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) ;
         end
    end
    
    x = table2timetable(Fueluse.(techn), "RowTimes",datetime(Fueluse.(techn).Year,Fueluse.(techn).Month,1)) ;
    x = removevars(x, {'Year','Month','Day','Hour','Week'}) ;
    % lpredict(x.Variables, 'np', 14, 'npred', predictedstep, 'pos','post','limitL',0) ;
    [y, ~] = lpredict(x.Variables, 'np', 14, 'npred', predictedstep, 'pos','post','limitL',0) ; % the rank 14 has been found to give the most accruate results
    xtemp = [x.Variables;y] ;
    xtemp = array2timetable(xtemp, "RowTimes",...
                [datetime(Fueluse.(techn).Year(1),Fueluse.(techn).Month(1),1):...
                calmonths(1):...
                datetime(Fueluse.(techn).Year(end),Fueluse.(techn).Month(end) + predictedstep,1)]', ...
                'VariableNames', x.Properties.VariableNames) ;    
    fuelratioout.(techn) = xtemp(end,:) ;
    fuelratio.(techn) = array2table(fuelratioout.(techn)(1,fuellist).Variables ./ sum(fuelratioout.(techn)(1,fuellist).Variables), 'VariableNames', fuellist) ;
    fuelratio.(techn) = table2struct(fuelratio.(techn)) ;
end

%% Nested functions
%%% Thermal power plant
    function perccat = extractper(nametech, t1, predefcat)
        r1          = t1.mainfuel(strcmp(t1.type, nametech)) ;
        FuelUsed    = unique(r1) ;
        Summary     = struct    ;
        for ifuel = 1:length(FuelUsed)
            fuelname = FuelUsed{ifuel} ;
            findfuel = find(contains(predefcat(:,2),fuelname)) ;
            if isempty(findfuel)
                % Add the fuel and the category to be added in the array
            else
                cat = predefcat(findfuel,1)  ;
                cat = strrep(cat{1},' ','_') ;
            end
            r1 = strcmp(t1.mainfuel, fuelname) & strcmp(t1.type, nametech) ;
            TotalLoadCat = sum(t1.maximum_total_mw(r1)) ;
            if isfield(Summary, cat)
                Summary.(cat) = Summary.(cat) + TotalLoadCat ;
            else
                Summary.(cat) = TotalLoadCat ;
            end
        end

        perccat.totalload = table2struct(array2table(struct2array(Summary), "VariableNames", fieldnames(Summary))) ;
        perccat.ratioload = table2struct(array2table(struct2array(Summary) / sum(struct2array(Summary)) * 100, "VariableNames", fieldnames(Summary))) ;
    end
%%% Wind power plant    
    function winnd = extractwind(nametech, t1)
        r1           = t1.mainfuel(strcmp(t1.type, nametech)) ;
        FuelUsed    = unique(r1) ;
        for ifuel = 1:length(FuelUsed)
            fuelname = FuelUsed{ifuel} ;
            WP = t1.maximum_total_mw(strcmp(t1.mainfuel, fuelname)) ;
            Wtot = sum(WP) ;
            winnd.totalload.Wt1 = sum(WP(WP<=1)) ;
            winnd.totalload.Wt1_3 = sum(WP(WP>1 & WP <= 3)) ;
            winnd.totalload.Wt3 = sum(WP(WP>3)) ;

            winnd.ratioload.Wt1 = winnd.totalload.Wt1/Wtot * 100 ;
            winnd.ratioload.Wt1_3 = winnd.totalload.Wt1_3/Wtot  * 100 ;
            winnd.ratioload.Wt3 = winnd.totalload.Wt3/Wtot  * 100 ;
        end
    end
%%% Hydro power plant    
    function hydro = extracthydro(nametech, t1)
        r1           = t1.mainfuel(strcmp(t1.type, nametech)) ;
        FuelUsed    = unique(r1) ;
        for ifuel = 1:length(FuelUsed)
            fuelname = FuelUsed{ifuel} ;
            WP = t1.maximum_total_mw(strcmp(t1.mainfuel, fuelname)) ;
            Wtot = sum(WP) ;
            hydro.totalload.SHP = sum(WP(WP<=10)) ;
            hydro.totalload.LHP = sum(WP(WP>10)) ;

            hydro.ratioload.SHP = hydro.totalload.SHP/Wtot * 100 ;
            hydro.ratioload.LHP = hydro.totalload.LHP/Wtot  * 100 ;
        end
    end
%%% Solar power plant    
    function solar = extractsolar(nametech, t1)
        r1           = t1.mainfuel(strcmp(t1.type, nametech)) ;
        FuelUsed    = unique(r1) ;
        for ifuel = 1:length(FuelUsed)
            fuelname = FuelUsed{ifuel} ;
            WP = t1.maximum_total_mw(strcmp(t1.mainfuel, fuelname)) ;
            Wtot = sum(WP) ;
            solar.totalload = sum(WP(WP>0)) ;

            solar.ratioload = solar.totalload/Wtot * 100 ;
        end
    end
end
