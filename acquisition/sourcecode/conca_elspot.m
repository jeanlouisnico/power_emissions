function priceout = conca_elspot(spot)

allcountries = fieldnames(spot) ;

for icountry = 1:numel(allcountries)
    cc = allcountries{icountry} ;
    price = [] ;
    pricetemp = [] ;
    if strcmp(cc,'ES')
        x = 1 ;
    end
    switch cc
        case 'DE'
            allyears = fieldnames(spot.(cc)) ;
            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                years = str2double(yeartxt(2:end)) ;
                if years < 2018
                    pricetemp = spot.(cc).(yeartxt).de_at_lu ;
                elseif years >= 2019
                    pricetemp = spot.(cc).(yeartxt).de_lu ;
                else 
                    price1 = spot.(cc).(yeartxt).de_at_lu ;
                    price2 = spot.(cc).(yeartxt).de_lu ;
                    range1 = timerange(datetime(2018,1,1,'TimeZone','UTC'),datetime(2018,10,1,'TimeZone','UTC'),"open") ;
                    range2 = timerange(datetime(2018,10,1,'TimeZone','UTC'),datetime(2018,12,31,'TimeZone','UTC'),"closed") ;
                    price1 = price1(range1,:) ;
                    price2 = price2(range2,:) ;
                    pricetemp  = concat_TT(price1, price2) ;
                end
                if isempty(price)
                    price = pricetemp ;
                else
                    price = concat_TT(price, pricetemp) ;
                end
            end
        case 'DK'
            allyears = fieldnames(spot.(cc)) ;
            price.dk_dk1 = [] ;
            price.dk_dk2 = [] ;
            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                zones = fieldnames(spot.(cc).(yeartxt)) ;
                for izone = 1:numel(zones)
                    switch zones{izone}
                        case {'dk_dk1','dk_dk2'}
                            pricetemp.(zones{izone}) = spot.(cc).(yeartxt).(zones{izone}) ;
                            if isempty(price.(zones{izone}))
                                price.(zones{izone}) = pricetemp.(zones{izone}) ;
                            else
                                price.(zones{izone}) = concat_TT(price.(zones{izone}), pricetemp.(zones{izone})) ;
                            end
                    end
                end
            end
        case 'EL'
            allyears = fieldnames(spot.(cc)) ;
            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                pricetemp = spot.(cc).(yeartxt).('gr') ;
                if isempty(price)
                    price = pricetemp ;
                else
                    price = concat_TT(price, pricetemp) ;
                end
            end
        case 'IE'
            allyears = fieldnames(spot.(cc)) ;
            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                pricetemp = spot.(cc).(yeartxt).('ie_sem') ;
                if isempty(price)
                    price = pricetemp ;
                else
                    price = concat_TT(price, pricetemp) ;
                end
            end
        case 'IT'
            allyears = fieldnames(spot.(cc)) ;
            price.it_saco_ac = [] ;
            price.it_saco_dc = [] ;
            price.it_br = [] ;
            price.it_cno = [] ;
            price.it_cso = [] ;
            price.it_fo = [] ;
            price.it_gr = [] ;
            price.it_no = [] ;
            price.it_no_at = [] ;
            price.it_no_ch = [] ;
            price.it_no_fr = [] ;
            price.it_no_si = [] ;
            price.it_pr = [] ;
            price.it_ro = [] ;
            price.it_sar = [] ;
            price.it_sic = [] ;
            price.it_so = [] ;

            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                zones = fieldnames(spot.(cc).(yeartxt)) ;
                for izone = 1:numel(zones)
                    switch zones{izone}
                        case {'it_saco_ac' 'it_saco_dc' 'it_br'	'it_cno' 'it_cso' 'it_fo' 'it_gr' 'it_no' 'it_no_at' 'it_no_ch' 'it_no_fr' 'it_no_si' 'it_pr' 'it_ro' 'it_sar' 'it_sic' 'it_so'}
                            pricetemp.(zones{izone}) = spot.(cc).(yeartxt).(zones{izone}) ;
                            if isempty(price.(zones{izone}))
                                price.(zones{izone}) = pricetemp.(zones{izone}) ;
                            else
                                price.(zones{izone}) = concat_TT(price.(zones{izone}), pricetemp.(zones{izone})) ;
                            end
                    end
                end
            end
        case 'NO'
            allyears = fieldnames(spot.(cc)) ;
            price.no_no1 = [] ;
            price.no_no2 = [] ;
            price.no_no3 = [] ;
            price.no_no4 = [] ; 
            price.no_no5 = [] ;
            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                zones = fieldnames(spot.(cc).(yeartxt)) ;
                for izone = 1:numel(zones)
                    switch zones{izone}
                        case {'no_no1' 'no_no2' 'no_no3' 'no_no4' 'no_no5'}
                            pricetemp.(zones{izone}) = spot.(cc).(yeartxt).(zones{izone}) ;
                            if isempty(price.(zones{izone}))
                                price.(zones{izone}) = pricetemp.(zones{izone}) ;
                            else
                                price.(zones{izone}) = concat_TT(price.(zones{izone}), pricetemp.(zones{izone})) ;
                            end
                    end
                end
            end
        case 'RS'

        case 'SE'
            allyears = fieldnames(spot.(cc)) ;
            price.se_se1 = [] ;
            price.se_se2 = [] ;
            price.se_se3 = [] ;
            price.se_se4 = [] ;

            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear};
                zones = fieldnames(spot.(cc).(yeartxt)) ;
                for izone = 1:numel(zones)
                    switch zones{izone}
                        case {'se_se1' 'se_se2' 'se_se3' 'se_se4'}
                            pricetemp.(zones{izone}) = spot.(cc).(yeartxt).(zones{izone}) ;
                            if isempty(price.(zones{izone}))
                                price.(zones{izone}) = pricetemp.(zones{izone}) ;
                            else
                                price.(zones{izone}) = concat_TT(price.(zones{izone}), pricetemp.(zones{izone})) ;
                            end
                    end
                end
            end
        case 'RU'
            allyears = fieldnames(spot.(cc)) ;
            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                pricetemp = spot.(cc).(yeartxt).('ru_kgd') ;
                if isempty(price)
                    price = pricetemp ;
                else
                    price = concat_TT(price, pricetemp) ;
                end
            end
        otherwise
            allyears = fieldnames(spot.(cc)) ;
            for iyear = 1:numel(allyears)
                yeartxt = allyears{iyear} ;
                pricetemp = spot.(cc).(yeartxt).(lower(cc)) ;
                if isempty(price)
                    price = pricetemp ;
                else
                    price = concat_TT(price, pricetemp) ;
                end
            end
    end
    priceout.(cc) = price ;
end

priceout = createtototal(priceout) ;
