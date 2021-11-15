function [ENTSOE, TSO, PoweroutLoad] = CallCountryPower(country)
% Switch through the selected countries to know where the fetch the data
% from.
switch country
    %%% France
    case 'France'
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        TSO.bytech = extractFrance ;
    %%% Sweden
    % For Sweden, data can be extracted from the TSO website
    case 'Sweden'
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE www.svk.se API %%%%%%%%
        TSO.bytech = extractSweden ;
        %%%%% TO GET THROUGH THE www.svk.se API %%%%%%%%
    %%% Russia
    % For Russia, data can be extracted from the TSO website
    case 'Russia'
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE br.so-ups.ru API %%%%%%%%
        TSO.bytech = extractRussia ;
        %%%%% TO GET THROUGH THE br.so-ups.ru API %%%%%%%%
    %%% Estonia
    % For Estonia, data can be extracted from ENTSOE
    case 'Estonia'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE elering API %%%%%%%%
        TSO.bytech    = extractEstonia ;
    %%% Norway
    % For Norway, data can be extracted from ENTSOE
    case 'Norway' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO.bytech    = extractstatnett('NO') ;
    %%% Germany
    % For Germany, data can be extracted from ENTSOE
    case 'Germany' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO.bytech    = 0 ;
    %%% Finland
    % For Finland, data can be extracted from ENTSOE
    case 'Finland' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = extractFinland ;
    otherwise
        
end
