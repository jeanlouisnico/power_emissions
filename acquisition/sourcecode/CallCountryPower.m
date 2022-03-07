function [ENTSOE, TSO, PoweroutLoad] = CallCountryPower(country)
% Switch through the selected countries to know where the fetch the data
% from.
switch country
    %%% France
    case 'France'
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        TSO.emissionskit = extractFrance ;
    %%% Sweden
    % For Sweden, data can be extracted from the TSO website
    case 'Sweden'
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE www.svk.se API %%%%%%%%
        TSO = extractSweden ;
        %%%%% TO GET THROUGH THE www.svk.se API %%%%%%%%
    %%% Russia
    % For Russia, data can be extracted from the TSO website
    case 'Russia'
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE br.so-ups.ru API %%%%%%%%
        TSO = extractRussia ;
        %%%%% TO GET THROUGH THE br.so-ups.ru API %%%%%%%%
    %%% Estonia
    % For Estonia, data can be extracted from ENTSOE
    case 'Estonia'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE elering API %%%%%%%%
        TSO    = extractEstonia ;
    %%% Norway
    % For Norway, data can be extracted from ENTSOE
    case 'Norway' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO      = extractstatnett('NO') ;
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
    case 'Bulgaria' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = BG ;
    case 'Denmark' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = DK ;
    case 'Spain' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = ES ;
    case 'Czech' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = CZ ;
    case 'Belgium' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = BE ;
    case 'Romania' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = RO ;
    case 'Portugal' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = PT ;
    case 'Hungary' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = HU ;
    case 'Latvia'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = LV ;
    case 'Austria'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = AT ;
    case 'Poland'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = PO ;
    otherwise
        
end
