function elsepost_array = extract_history_priceENTSOE
curtime = datetime('now','TimeZone','UTC') ;

for idate = 2015:curtime.Year
    datestart = datetime(idate,1,1) ;
    if idate == curtime.Year
        dateend = datetime(curtime - caldays(1)) ;
    else
        dateend = datetime(idate,12,31,23,59,59) ;
    end
    Country = country2fetch ;

    country_code = countrycode(Country) ;
    
    
    for icountry = 1:length(Country)
        elsepost_array.(country_code.alpha2{icountry}).(['x' num2str(datestart.Year)]) = elspotENTSOEhist(country_code(icountry,:),'datestart',datestart,'dateend',dateend) ;
    end
    

end