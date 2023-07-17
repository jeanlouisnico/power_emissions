function data2 = fuelconsmonth_europe

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

inputfile = [fparts{1} filesep 'input' filesep 'general' filesep 'json_result_merged.json'] ;

if isfile(inputfile)
    FileInfo = dir(inputfile) ;
    datecompare = datetime("now") ;
    datefile    = datetime(FileInfo.datenum, "ConvertFrom", "datenum") ;

    % Check daily if the data have changed
    if ~(datecompare.Year == datefile.Year && datecompare.Month==datefile.Month && week(datecompare)==week(datefile))
        data2 = extractdata(fparts) ;
    else
        data2 = loadEUfuelmonth ;
    end
else
    data2 = extractdata(fparts) ;
end

    function data2 = extractdata(fparts)
        json_result = struct ;
        toc = jsondecode(fileread([fparts{1} filesep 'input' filesep 'general' filesep 'TOC_eurostat.json']));              
        [codes, countries, source.liquidfuel, source.solidfuel, source.gasfuel, source.elecfuel] = setnames ;
        
        allsource = fieldnames(source) ;
        for isource = 1:length(allsource)
            allfuels = source.(allsource{isource}) ;
            for icountry = 1:length(countries(:,1))
                countrycode = countries{icountry, 1} ;
                for ifuel = 1:size(allfuels,1)
                    fuelcode = allfuels{ifuel, 1} ;
                    fuelname = makevalidstring(allfuels{ifuel, 2}) ;
%                     d = dbEUROSTAT();
                    d.baseURL = 'https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/' ;
                    d.table = toc.data.envir.nrg.nrg_quant.nrg_quantm.nrg_cb_m.(codes{isource}) ;
        
                    filt = struct();
                    
                    
                    filt.siec = fuelcode; % 'C0100';'C0200';'P1100';'S2000'
                    filt.geo = countrycode;
                    filt.freq = '' ;
                    d.filter = filt;
                    
                    d.engine = 'json';

                    %%% Build up the URL
                    switch codes{isource}
                        case 'nrg_cb_pem'
                            filt.unit = 'GWH'; % Gigawatt-hour
                            query = [d.baseURL codes{isource} '/' filt.freq '.' fuelcode '.' filt.unit '.' countrycode '?format=' d.engine] ;
                        case {'nrg_cb_oilm','nrg_cb_sffm','nrg_cb_gasm'}
                            filt.nrg_bal = 'TI_EHG_MAP'; % Transformation input - electricity and heat generation - main activity producers
                            filt.unit = 'THS_T'; % Thousand tonnes
                            query = [d.baseURL codes{isource} '/' filt.freq '.' filt.nrg_bal '.' fuelcode '.' filt.unit '.' countrycode '?format=' d.engine] ;
                        otherwise
                            filt.nrg_bal = 'TI_EHG_MAP'; % Transformation input - electricity and heat generation - main activity producers
                            filt.unit = 'THS_T'; % Thousand tonnes
                            query = [d.baseURL codes{isource} '/' filt.freq '.' filt.nrg_bal '.' fuelcode '.' filt.unit '.' countrycode '?format=' d.engine] ;
                    end
                    try
                        dataout = urlread(query) ;
                    catch
                        continue;
                    end
                    fprintf([filt.freq '.' fuelcode '.' filt.unit '.' countrycode '>>> download OK!\n']);
                    data = jsondecode(dataout) ;
                    timechar = struct2table(data.dimension.time.category.label) ;
                    timestring = [timechar.Properties.VariableNames] ; 
                    time = cellfun(@(x) datetime(erase(x,'x'),"InputFormat",'yyyy_MM','TimeZone','UTC'),timestring)';

                    if isempty(fieldnames(data.value))
                         % create an array of zero values of the size of
                         % the time array
                         emptyarray = zeros(length(time),1) ;
                         TT = array2timetable(emptyarray,"RowTimes",time,"VariableNames",{fuelcode}) ;
                    else
                         % Access the data by value and extract its index
                         allfields = fieldnames(data.value) ;
                         timefields = fieldnames(data.dimension.time.category.index) ;
                         value = zeros(length(allfields),1) ;
                         timetemp = NaT(length(allfields),1,'TimeZone','UTC') ;
                         for i = 1:length(allfields)
                             fieldin = allfields{i} ;
                             index = erase(fieldin,'x') ;
                             value(i) = data.value.(fieldin) ;
                             timetemp(i) = time(str2double(index) + 1) ;
                         end
                         TT = array2timetable(value,"RowTimes",timetemp,"VariableNames",{fuelcode}) ;
                    end
                    if isfield(json_result,countrycode)
                        json_result.(countrycode) = synchronize(json_result.(countrycode),TT) ;
                    else
                        json_result.(countrycode) = TT ;
                    end
%                     try
%                         obj = tsobj(d);
%                         json_result.(countrycode).(fuelcode) = convert2timetable(obj) ;
%                     catch
%                         % No data available for this country or fuel category
%                     end
                end
            end
        end
        % Transform the structure array of cells into a structure array of timetables
        allgeo = fieldnames(json_result) ;
        data2 = json_result ;
%         for igeo = 1:length(allgeo)
%             geo = allgeo{igeo} ;
%             allfuels = fieldnames(json_result.(geo)) ;
%             
%             data2.(geo) = synchronize(json_result.(geo).(allfuels{1}), json_result.(geo).(allfuels{2})) ;
%             for ifuel = 3:length(allfuels)
%                 data2.(geo) = synchronize(data2.(geo), json_result.(geo).(allfuels{ifuel})) ;
%             end
%             data2.(geo).Properties.VariableNames = fieldnames(json_result.(geo)) ;
%         end
        
        % convert it back to table to save the results into a table.
        % jsonencode does not handle timetables well.

        for igeo = 1:length(allgeo)
            geo = allgeo{igeo} ;    
            data3.(geo) = timetable2table(data2.(geo)) ;
        end
        
        % load the previous data
        data2_past = loadEUfuelmonth ; 

        % Merge the previous data with the new data
        data2write = mergedatatset(data2, data2_past) ;
        % Save the extracted data to a json file
        dlmwrite([fparts{1} filesep 'input' filesep 'general' filesep 'json_result_merged.json'],jsonencode(data3, "PrettyPrint", true),'delimiter','');
                
%         toplot = {'CF_R', 'CF_NR', 'C0000', 'G3000', 'O4000XBIO'} ;
%         geo2plot = 'FI' ; 
%         bar(data3.(geo2plot).Time,bsxfun(@rdivide, data3.(geo2plot)(:,toplot).Variables, sum(data3.(geo2plot)(:,toplot).Variables,2)) * 100,'stacked', 'BarWidth', 1) ;
%         
%         for ileg = 1:length(toplot)
%             legfull(ileg) = source.elecfuel(strcmp(toplot{ileg}, source.elecfuel(:,1)), 2) ;
%         end
% 
%         xlim([datetime(2016,12,1) datetime(now, 'ConvertFrom', "datenum")])
%         ls = xlim ;
%         xticks([ls(1):calmonths(1):ls(2)])
%         ylim([0 119])
%         xtickformat('MM/yy')
%         xtickangle(270)
%         legend(makevalidlegend(legfull), "Location","best")
%         
%         % p = mfilename('fullpath') ;
%         % m = pwd ;
%         % match = [" ",":"];
%         country = 'FI' ;
%         
%         ToExtract = {'C0100' 'S2000' 'C0200' 'P1100'} ;
%         
%         % fuelcon = readtable([m filesep 'hardfuel_europe' filesep 'nrg_cb_sffm_1_Data.csv'], 'Format','%q%q%q%q%q%q%q') ;
%         % fuelcon.Value = cellfun(@(x) str2double(erase(x, match)), fuelcon.Value, 'UniformOutput', false) ;
%         % time = cellfun(@(x) strsplit(x, 'M'), fuelcon.TIME, 'UniformOutput', false) ;
%         % time = cellfun(@(x) datetime(str2double(x{:,1}), str2double(x{:,2}),1), time, 'UniformOutput', false) ;
%         % array = [time{:}]';
%         % 
%         % fuelcon = timetable(array, fuelcon.GEO, fuelcon.NRG_BAL, fuelcon.SIEC, fuelcon.UNIT, fuelcon.Value, fuelcon.FlagAndFootnotes, 'VariableNames', ...
%         %                             {'GEO' 'NRG_BAL' 'SIEC' 'UNIT' 'Value' 'FlagAndFootnotes'}) ;
%         % 
%         % fuelbygeo = fuelcon(strcmp(fuelcon.GEO, country), :) ;
%         % 
%         % allfuels = unique(fuelbygeo.SIEC) ;
%         % 
%         % for ifuel = 1:length(allfuels)
%         %     nameout = makevalidstring(allfuels{ifuel}) ;
%         %     datatemp = fuelbygeo(strcmp(allfuels{ifuel}, fuelbygeo.SIEC), 'Value') ;
%         %     datatemp.Value = [datatemp.Value{:}]' ;
%         %     data.(nameout) = datatemp ;
%         % end
%         % allfuels = fieldnames(data) ;
%         % data2 = synchronize(data.(allfuels{1}), data.(allfuels{2})) ;
%         % for ifuel = 3:length(allfuels)
%         %     data2 = synchronize(data2, data.(allfuels{ifuel})) ;
%         % end
%         % data2.Properties.VariableNames = allfuels ;
%         data4 = data3.(country)(:,ToExtract) ;
%         
%         plot(data4.Time, data4.Variables) ;
%         legend(makevalidlegend(allfuels), "Location","bestoutside")
%         title(['hard fuel consumption - ' country])
    end

    function dataout = convert2timetable(obj)
        match = [" ",":"];
        time = cellfun(@(x) strsplit(x, 'M'), obj.range, 'UniformOutput', false) ;
        time = cellfun(@(x) datetime(str2double(x{:,1}), str2double(x{:,2}),1), time, 'UniformOutput', false) ;
        array = [time{:}]';
        dataout = timetable(obj.values, 'RowTimes', array) ;
    end

    function [codes, countries, liquidfuel, solidfuel, gasfuel, elecfuel] = setnames
        liquidfuel = {'O4100_TOT_4200-4500'	'Crude oil, NGL, refinery feedstocks, additives and oxygenates and other hydrocarbons'
        'O4100_TOT'	'Crude oil'
        'O4200'	'Natural gas liquids'
        'O4300'	'Refinery feedstocks'
        'O4400'	'Additives and oxygenates'
        'O4410'	'Biofuels for blending'
        'O4500'	'Other hydrocarbons'
        'O4600'	'Oil products'
        'O4610'	'Refinery gas'
        'O4620'	'Ethane'
        'O4630'	'Liquefied petroleum gases'
        'O4640'	'Naphtha'
        'O4651'	'Aviation gasoline'
        'O4652'	'Motor gasoline'
        'O4652XR5210B'	'Motor gasoline (excluding biofuel portion)'
        'O4653'	'Gasoline-type jet fuel'
        'O4661'	'Kerosene-type jet fuel'
        'O4661XR5230B'	'Kerosene-type jet fuel (excluding biofuel portion)'
        'O4669'	'Other kerosene'
        'O4671'	'Gas oil and diesel oil'
        'O4671XR5220B'	'Gas oil and diesel oil (excluding biofuel portion)'
        'O46711'	'Road diesel'
        'O46712'	'Heating and other gasoil'
        'O4680'	'Fuel oil'
        'O4681'	'Fuel oil (low sulphur <1%)'
        'O4682'	'Fuel oil (high sulphur >=1%)'
        'O4690XO4694'	'Other oil products (excluding petroleum coke portion)'
        'O4694'	'Petroleum coke'
        'O4699'	'Other oil products n.e.c.'
        'R5210B'	'Blended biogasoline'
        'R5220B'	'Blended biodiesels'
        'R5230'	'Bio jet kerosene'
        'R5230B'	'Blended bio jet kerosene'};
    
        countries = {'EU27_2020'	'European Union - 27 countries (from 2020)'
            'EA19'	'Euro area - 19 countries (from 2015)'
            'BE'	'Belgium'
            'BG'	'Bulgaria'
            'CZ'	'Czechia'
            'CH'    'Switzerland'
            'DK'	'Denmark'
            'DE'	'Germany (until 1990 former territory of the FRG)'
            'EE'	'Estonia'
            'IE'	'Ireland'
            'EL'	'Greece'
            'ES'	'Spain'
            'FR'	'France'
            'HR'	'Croatia'
            'IT'	'Italy'
            'CY'	'Cyprus'
            'LV'	'Latvia'
            'LT'	'Lithuania'
            'LU'	'Luxembourg'
            'HU'	'Hungary'
            'MT'	'Malta'
            'NL'	'Netherlands'
            'AT'	'Austria'
            'PL'	'Poland'
            'PT'	'Portugal'
            'RO'	'Romania'
            'SI'	'Slovenia'
            'SK'	'Slovakia'
            'FI'	'Finland'
            'SE'	'Sweden'
            'NO'	'Norway'
            'UK'	'United Kingdom'
            'ME'	'Montenegro'
            'MK'	'North Macedonia'
            'RS'	'Serbia'
            'TR'	'Turkey'
            'BA'	'Bosnia and Herzegovina'
            'MD'	'Moldova'
            'UA'	'Ukraine'
            'GE'	'Georgia'} ;

        solidfuel = {'C0100' 'Hard coal'
            'C0311'	'Coke oven coke'
            'C0200' 'Brown coal'
            'P1100' 'Peat'
            'S2000' 'Oil shale and oil sands'} ;
        
        gasfuel = {'G3000'	'Natural gas'} ;
        
        elecfuel = {'CF'	'Combustible fuels'
                    'CF_R'	'Combustible fuels - renewable'
                    'CF_NR'	'Combustible fuels - non-renewable'
                    'C0000'	'Coal and manufactured gases'
                    'G3000'	'Natural gas'
                    'O4000XBIO'	'Oil and petroleum products (excluding biofuel portion)'
                    'RA100'	'Hydro'
                    'RA110'	'Pure hydro power'
                    'RA120'	'Mixed hydro power'
                    'RA130'	'Pumped hydro power'
                    'RA200'	'Geothermal'
                    'RA300'	'Wind'
                    'RA310'	'Wind on shore'
                    'RA320'	'Wind off shore'
                    'RA400'	'Solar'
                    'RA410'	'Solar thermal'
                    'RA420'	'Solar photovoltaic'
                    'RA500_5160'	'Other renewable energies'
                    'N9000'	'Nuclear fuels and other fuels n.e.c.'
                    'X9900'	'Other fuels n.e.c.' } ;
        
        codes = {'nrg_cb_oilm' 'nrg_cb_sffm' 'nrg_cb_gasm' 'nrg_cb_pem'} ;
        
    end

end
