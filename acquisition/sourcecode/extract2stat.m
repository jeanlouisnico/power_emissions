function [IndCHP, DHCHP, Sep, Windpower, fuelratio] = extract2stat
%%% File set up
% The Energy Authority of Finland maintains a registry of all active powerplant
% in Finland and provide their rated output capacity as well as the type of
% fuel they are using. We are using this registry to make statistics out of
% it and categorise the powerplant capacity by fuel type.
%%% Define the time
currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

timeextract = datetime(datetime(datestr(now)) - hours(timezone)) ;

t1 = rekisterypostgre(false) ;

% filename = 'Energiaviraston voimalaitosrekisteri.xlsx' ;
% %%%
% % Determine where demo folder is.
% folder = fileparts(which(filename)) ;
% fullFileName = fullfile(folder, filename);
% [~, sheetNames] = xlsfinfo(fullFileName) ;
% 
% numSheets = length(sheetNames) ;
% n = 0 ;
% i = 0 ;
% while n == 0
%     i = i + 1 ;
%     if i > numSheets
%         errordlg('Missing file name in English');
%         return ;
%     elseif strcmp(sheetNames{i}, 'English')
%         warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
%         t1 = readtable(fullFileName, 'Sheet', i) ;
%         n = 1 ;
%         warning('ON', 'MATLAB:table:ModifiedAndSavedVarnames')
%     end
% end

r = strcmp(t1.type, 'Hydro power') ;
t1.MainFuel(r) = {'Water'} ;

r = strcmp(t1.type, 'Wind power') ;
t1.MainFuel(r) = {'Wind'} ;

r = strcmp(t1.type, 'Solar') ;
t1.MainFuel(r) = {'Solar'} ;

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
             'others'           'Other by-products and wastes used as fuel'
             'biomass'          'Forest fuelwood'
             'biomass'          'Black liquor and concentrated liquors'
             'coal'             'Hard coal and anthracite'
             'biomass'          'By-products from wood processing industry'
             'oil'              'Heavy distillates'
             'others'           'Exothermic heat from industry'
             'oil'              'Light distillates'
             'others'           'Biogas'
             'oil'              'Medium heavy distillates'
             'oil'              'Heavy distillates'
             'coal'             'Blast furnace gas'} ;

%%% Extract data for Industrial CHP
nametech = 'Industry CHP' ;
IndCHP = extractper(nametech, t1, predefcat) ;
IndCHP.totalload = orderfields(IndCHP.totalload) ;

%%% Extract data for District Heating CHP
nametech = 'District heating CHP' ;
DHCHP = extractper(nametech, t1, predefcat) ;
DHCHP.totalload = orderfields(DHCHP.totalload) ;

%%% Extract data for Separate electricity production
nametech = 'Separate electricity production' ;
Sep = extractper(nametech, t1, predefcat) ;

%%% Extract data for Wind power
nametech = 'Wind power' ;
Windpower = extractwind(nametech, t1) ;

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
    [y, ~] = lpredict(x.Variables, 14, predictedstep, 'post') ; % the rank 14 has been found to give the most accruate results
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

% fuelratiotemp.chp.thermal3 = Fueluse.chp(findrow,:) ;
% fuelratiotemp.sep.thermal3 = Fueluse.sep(findrow,:) ;
% 
% % Get the previous year data for the same month than today
% timetarget = timeextract - calyears(1) ;
%     findrow = (Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) ;
% fuelratiotemp.chp.thermal1 = Fueluse.chp(findrow,:) ;
% fuelratiotemp.sep.thermal1 = Fueluse.sep(findrow,:) ;
% 
% % Get the previous year data for the same month than the last data
% % available to get a trend and extrapolate data
% timetarget = timeextract - calmonths(nyear) - calyears(1) ;
%     findrow = (Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) ;
% fuelratiotemp.chp.thermal2 = Fueluse.chp(findrow,:) ;
% fuelratiotemp.sep.thermal2 = Fueluse.sep(findrow,:) ;
% 
% Ratio_year_n_1.chp  = fuelratiotemp.chp.thermal1.Variables ./ fuelratiotemp.chp.thermal2.Variables ;
% Ratio_year_n_1.sep  = fuelratiotemp.sep.thermal1.Variables ./ fuelratiotemp.sep.thermal2.Variables ;
% 
% Ratio_year_n_1.chp(isinf(Ratio_year_n_1.chp)|isnan(Ratio_year_n_1.chp)) = 0 ;
% Ratio_year_n_1.sep(isinf(Ratio_year_n_1.sep)|isnan(Ratio_year_n_1.sep)) = 0 ;
% 
% fuelratioout.chp   = array2table(Ratio_year_n_1.chp .* fuelratiotemp.chp.thermal3.Variables, 'VariableNames', fuelratiotemp.chp.thermal1.Properties.VariableNames) ;
% fuelratioout.sep   = array2table(Ratio_year_n_1.sep .* fuelratiotemp.sep.thermal3.Variables, 'VariableNames', fuelratiotemp.sep.thermal1.Properties.VariableNames) ;
% 
% fuelratio.chp = array2table(fuelratioout.chp(1,fuellist).Variables ./ fuelratioout.chp.total, 'VariableNames', fuellist) ;
% fuelratio.sep = array2table(fuelratioout.sep(1,fuellist).Variables ./ fuelratioout.sep.total, 'VariableNames', fuellist) ;
% 
% fuelratio.chp = table2struct(fuelratio.chp) ;
% fuelratio.sep = table2struct(fuelratio.sep) ;
% findrow = (Fueluse.chp.Year == (timeextract.Year - 1) & Fueluse.chp.Month == timeextract.Month) ;
% total = Fueluse.chp.total(findrow) ;
% fuellist = fieldnames(DHCHP.totalload) ;
% for jfuel = 1:length(fuellist)
%     fuelnamej = fuellist{jfuel} ;
%     fuelratio.chp.(fuelnamej) = Fueluse.chp.(fuelnamej)(findrow) / total ;
% end
% 
% findrow = (Fueluse.sep.Year == (timeextract.Year - 1) & Fueluse.sep.Month == timeextract.Month) ;
% total = Fueluse.sep.total(findrow) ;
% for jfuel = 1:length(fuellist)
%     fuelnamej = fuellist{jfuel} ;
%     fuelratio.sep.(fuelnamej) = Fueluse.sep.(fuelnamej)(findrow) / total ;
% end

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
    function perccat = extractwind(nametech, t1)
        r1           = t1.mainfuel(strcmp(t1.type, nametech)) ;
        FuelUsed    = unique(r1) ;
        for ifuel = 1:length(FuelUsed)
            fuelname = FuelUsed{ifuel} ;
            WP = t1.maximum_total_mw(strcmp(t1.mainfuel, fuelname)) ;
            Wtot = sum(WP) ;
            Wt1 = sum(WP(WP<=1)) ;
            Wt1_3 = sum(WP(WP>1 & WP <= 3)) ;
            Wt3 = sum(WP(WP>3)) ;
            
            perccat.Wt1 = Wt1/Wtot * 100 ;
            perccat.Wt1_3 = Wt1_3/Wtot  * 100 ;
            perccat.Wt3 = Wt3/Wtot  * 100 ;
        end
    end
end
