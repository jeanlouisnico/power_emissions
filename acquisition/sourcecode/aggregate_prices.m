function price = aggregate_prices(elsepost_array)

countries = fieldnames(elsepost_array) ;
price = struct ;
 for icount = 1:numel(countries)
    countryalpha = countries{icount} ;
    years = fieldnames(elsepost_array.(countryalpha)) ;
    for iyears = 1:numel(years)
        try
            subregions = fieldnames(elsepost_array.(countryalpha).(years{iyears})) ;
        catch
            continue ;
        end
        for isubregion = 1:numel(subregions)
            subregionname = subregions{isubregion} ;
            switch subregionname
                case 'EL'
                    lowcountry = 'gr' ;
                otherwise
                    lowcountry = lower(subregionname) ;
            end
            if ~isfield(price,subregionname)
                price.(subregionname) = [] ;
            end
            if numel(elsepost_array.(countryalpha).(years{iyears}).(subregionname)) > 1
                price.(subregionname) = concat_TT(price.(subregionname), elsepost_array.(countryalpha).(years{iyears}).(subregionname)) ;
            end
        end
    end
 end

allzones = fieldnames(price) ;
price.pricet = [] ;
 for izone = 1:numel(allzones)
    if ~isempty(price.(allzones{izone}))
        price.(allzones{izone}).Properties.VariableNames = allzones(izone) ;
        if isempty(price.pricet)
            price.pricet = price.(allzones{izone}) ;
        else
            price.pricet = synchronize(price.pricet,price.(allzones{izone})) ;
        end
    end
 end