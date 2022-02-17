function [alldata, seasonal] = fuelmixEU(country, plotbin, type)

[codes, countries, source.liquidfuel, source.solidfuel, source.gasfuel, source.elecfuel] = setnames ;

for icountry = 1:length(country)
    if isa(country,'char') || isa(country,'string')
        if length(country) > 2
            geo2plot = countrycode(country) ;
        else
            
            %%% Special cases like greece
            switch country
                case 'GR'
                    geo2plot = 'EL' ;
                otherwise
                    geo2plot = country ;
            end
        end
    elseif isa(country,'cell')
        if length(country{icountry}) > 2
            geo2plot = countrycode(country{icountry}) ;
        else
            %%% Special cases like greece
            switch country{icountry}
                case 'GR'
                    geo2plot = 'EL' ;
                otherwise
                    geo2plot = country{icountry} ;
            end
        end
    end
    json_result_merged = load('json_result_merged.mat') ;
    data2 = json_result_merged.data2 ;

    % Only combustible fuels
    toplot = {'CF_R', 'CF_NR', 'C0000', 'G3000', 'O4000XBIO'} ;
    if plotbin
        plotfuelmix(data2, geo2plot, toplot, source, geo2plot, 'month')
    end

    % All fuels

    toplot = {'CF_R' 'CF_NR' 'C0000' 'G3000' 'O4000XBIO'	'RA110' 'RA120' 'RA130' 'RA200' 'RA310'	 'RA320' 'RA410' 'RA420' 'RA500_5160' 'N9000' 'X9900'} ;
    if plotbin
        plotfuelmix(data2, geo2plot, toplot, source, geo2plot, 'year')
    end

    dataall.(geo2plot)      = data2.(geo2plot)(:,toplot) ;

    dataallperc.(geo2plot)  = array2timetable(bsxfun(@rdivide, dataall.(geo2plot)(:,toplot).Variables, sum(dataall.(geo2plot)(:,toplot).Variables,2, 'omitnan')) * 100, "RowTimes", dataall.(geo2plot).Time, 'VariableNames', toplot) ;

    %%% Fuel by season, summer or winter
    % Get all years from the dataset
    allyears = unique(dataall.(geo2plot).Time.Year) ;

    for iyears = 1:length(allyears)
        datawinter1 = zeros(3, length(toplot)) ;
        datawinter2 = zeros(3, length(toplot)) ;
        datasummer  = zeros(3, length(toplot)) ;

        curr_year = allyears(iyears) ; 
        winter1 = timerange(datetime(curr_year,1,1) , datetime(curr_year,3,31)) ;
        winter2 = timerange(datetime(curr_year,10,1) , datetime(curr_year,12,31)) ;

        summer = timerange(datetime(curr_year,4,1) , datetime(curr_year,9,30)) ;

        datawinter1 = dataall.(geo2plot)(winter1,toplot).Variables ;
        if isempty(datawinter1)
            datawinter1 = zeros(1,length(toplot)) ;
        end

        datawinter2 = dataall.(geo2plot)(winter2,toplot).Variables ;
        if isempty(datawinter2)
            datawinter2 = zeros(1,length(toplot)) ;
        end

        datasummer = dataall.(geo2plot)(summer,toplot).Variables ;
        if isempty(datasummer)
            datasummer = zeros(1,length(toplot)) ;
        end

        if iyears == 1
            ener_mix = sum(datawinter1,'omitnan') + sum(datawinter2,'omitnan')     ;
            ener_mix = [ener_mix ; sum(datasummer,'omitnan')] ;
        else
            ener_mix = [ener_mix ; sum(datawinter1,'omitnan') + sum(datawinter2,'omitnan')]     ;
            ener_mix = [ener_mix ; sum(datasummer,'omitnan')] ;
        end
    end
    seasonal_enermix.(geo2plot)     = array2timetable(ener_mix, "RowTimes", datetime(allyears(1),1,1):calmonths(6):datetime(allyears(end),12,1), 'VariableNames', toplot) ;
    seasonal_enermixperc.(geo2plot) = array2timetable(bsxfun(@rdivide, seasonal_enermix.(geo2plot)(:,toplot).Variables, sum(seasonal_enermix.(geo2plot)(:,toplot).Variables,2, 'omitnan')) * 100, "RowTimes", datetime(allyears(1),1,1):calmonths(6):datetime(allyears(end),12,1), 'VariableNames', toplot) ;

    if plotbin
        plotfuelmix(seasonal_enermix, geo2plot, toplot, source, geo2plot, 'season')
    end
end
%% Output the correct formatted data

switch type
    case 'absolute'
        alldata  = dataall ;
        seasonal = seasonal_enermix ;
    case 'normal'
        alldata  = dataallperc ;
        seasonal = seasonal_enermixperc ;
    otherwise
        alldata = dataall ;    
        seasonal = seasonal_enermix ;
end


%% Nested functions


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



    function plotfuelmix(data2, geo2plot, toplot, source, country, timescale)
        figure ; % Only combustibale
        bar(data2.(geo2plot).Time,bsxfun(@rdivide, data2.(geo2plot)(:,toplot).Variables, sum(data2.(geo2plot)(:,toplot).Variables,2, 'omitnan')) * 100,'stacked', 'BarWidth', 1) ;


        for ileg = 1:length(toplot)
            legfull(ileg) = source.elecfuel(strcmp(toplot{ileg}, source.elecfuel(:,1)), 2) ;
        end

        xlim([datetime(2016,12,1) datetime(now, 'ConvertFrom', "datenum")])
        ls = xlim ;
        switch timescale
            case 'month'
                tscale = 1 ;
            case 'year'
                tscale = 12 ;
            case 'season'
                tscale = 6 ;
            otherwise
                tscale = 1 ;
                
        end
        xticks([ls(1):calmonths(tscale):ls(2)])
        ylim([0 119])
        xtickformat('MM/yy')
        xtickangle(270)
        legend(makevalidlegend(legfull), "Location","bestoutside")
        title([country ' - Fuel mix 100%']) ;
    end
end
