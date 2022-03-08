function data2 = grossprodEU

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

inputfile = [fparts{1} filesep 'input' filesep 'general' filesep 'grossprodEU.json'] ;

if isfile(inputfile)
    FileInfo = dir(inputfile) ;
    datecompare = datetime("now") ;
    datefile    = datetime(FileInfo.datenum, "ConvertFrom", "datenum") ;

    % Check monthly if the data have changed
    if ~(datecompare.Year == datefile.Year && datecompare.Month==datefile.Month)
        data2 = extractdata(fparts) ;
    else
        data2 = loadEUnrgcap ;
    end
else
    data2 = extractdata(fparts) ;
end

    function data2 = extractdata(fparts)

        toc = jsondecode(fileread([fparts{1} filesep 'input' filesep 'general' filesep 'TOC_eurostat.json']));              
        [codes, countries, source.elecfuel] = setnames ;
        
        allsource = {'elecfuel'} ;
        for isource = 1:length(allsource)
            allfuels = source.(allsource{isource}) ;
            for icountry = 1:length(countries(:,1))
                countrycode = countries{icountry, 1} ;
                for ifuel = 1:size(allfuels,1)
                    fuelcode = allfuels{ifuel, 1} ;
                    fuelname = makevalidstring(allfuels{ifuel, 2}) ;
                    d = dbEUROSTAT();
                    d.table = toc.data.envir.nrg.nrg_quant.nrg_quanta.nrg_ind.(codes{isource}) ;
                              
                    filt = struct();
                    
                    filt.plants     = 'TOTAL'; % Total
                    filt.operator   = 'TOTAL'; % Total
                    filt.nrg_bal    = 'GEP'; % Gross electricity production
                    filt.unit       = 'GWH'; 
                    filt.siec       = fuelcode; % 'C0100';'C0200';'P1100';'S2000'
                    filt.geo        = countrycode;
                    d.filter        = filt;
        
                    d.engine = 'json'; % 'json' 'BULK/SDMX'
                    try
                        obj = tsobj(d);
                        json_result.(countrycode).(fuelcode) = convert2timetable(obj) ;
                    catch
                        % No data available for this country or fuel category
                    end
                end
            end
        end
        % Transform the structure array of cells into a structure array of timetables
        allgeo = fieldnames(json_result) ;
        for igeo = 1:length(allgeo)
            geo = allgeo{igeo} ;
            allfuels = fieldnames(json_result.(geo)) ;
            
            data2.(geo) = synchronize(json_result.(geo).(allfuels{1}), json_result.(geo).(allfuels{2})) ;
            for ifuel = 3:length(allfuels)
                data2.(geo) = synchronize(data2.(geo), json_result.(geo).(allfuels{ifuel})) ;
            end
            data2.(geo).Properties.VariableNames = fieldnames(json_result.(geo)) ;
        end
        
        % convert it back to table to save the results into a table.
        % jsonencode does not handle timetables well.

        for igeo = 1:length(allgeo)
            geo = allgeo{igeo} ;    
            data3.(geo) = timetable2table(data2.(geo)) ;
        end
        
        % Save the extracted data to a json file
        dlmwrite([fparts{1} filesep 'input' filesep 'general' filesep 'grossprodEU.json'],jsonencode(data3, "PrettyPrint", true),'delimiter','');
    end

    function dataout = convert2timetable(obj)
        match = [" ",":"];
        time = cellfun(@(x) strsplit(x, 'M'), obj.range, 'UniformOutput', false) ;
        time = cell2mat(cellfun(@(x) str2double(x{:,1}), time, 'UniformOutput', false)) ;
%         array = [time{:}]';
        dataout = timetable(obj.values, 'RowTimes', datetime(time,1,1)) ;
    end

    function [codes, countries, elecfuel] = setnames
    
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
           
        elecfuel = {'C0110'	'Anthracite'
                    'C0121'	'Coking coal'
                    'C0129'	'Other bituminous coal'
                    'C0210'	'Sub-bituminous coal'
                    'C0220'	'Lignite'
                    'C0311'	'Coke oven coke'
                    'C0312'	'Gas coke'
                    'C0320'	'Patent fuel'
                    'C0330'	'Brown coal briquettes'
                    'C0340'	'Coal tar'
                    'C0350'	'Coke oven gas'
                    'C0360'	'Gas works gas'
                    'C0371'	'Blast furnace gas'
                    'C0379'	'Other recovered gases'
                    'P1100'	'Peat'
                    'P1200'	'Peat products'
                    'S2000'	'Oil shale and oil sands'
                    'G3000'	'Natural gas'
                    'O4100_TOT'	'Crude oil'
                    'O4200'	'Natural gas liquids'
                    'O4610'	'Refinery gas'
                    'O4630'	'Liquefied petroleum gases'
                    'O4640'	'Naphtha'
                    'O4661'	'Kerosene-type jet fuel'
                    'O4669'	'Other kerosene'
                    'O4671'	'Gas oil and diesel oil'
                    'O4680'	'Fuel oil'
                    'O4690'	'Other oil products'
                    'O4694'	'Petroleum coke'
                    'O4695'	'Bitumen'
                    'R5100'	'Solid biofuels'
                    'R5210P'	'Pure biogasoline'
                    'R5220P'	'Pure biodiesels'
                    'R5290'	'Other liquid biofuels'
                    'R5300'	'Biogases'
                    'W6100'	'Industrial waste (non-renewable)'
                    'W6210'	'Renewable municipal waste'
                    'W6220'	'Non-renewable municipal waste' } ;
        
        codes = {'nrg_ind_pehcf'} ; 
        % 1. Electricity production capacities by main fuel groups and
        % operator --> use the elecfuel ctageories
        
    end

end