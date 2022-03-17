function [ENTSOE, TSO, PoweroutLoad, ENTSOEexch] = CallCountryPower(country)
% Switch through the selected countries to know where the fetch the data
% from.
%%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
% [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;

ENTSOE       = ENTSOE_exch('country',country,'documentType','Generation') ;
PoweroutLoad = ENTSOE_exch('country',country,'documentType','Load')       ;
ENTSOEexch   = ENTSOE_exch('country',country,'documentType','Exchange')       ;

switch country
    %%% France
    case 'France'
        TSO.emissionskit = extractFrance ;
    %%% Sweden
    % For Sweden, data can be extracted from the TSO website
    case 'Sweden'
        TSO = extractSweden ;
        %%%%% TO GET THROUGH THE www.svk.se API %%%%%%%%
    %%% Russia
    % For Russia, data can be extracted from the TSO website
    case 'Russia'
        TSO = extractRussia ;
        %%%%% TO GET THROUGH THE br.so-ups.ru API %%%%%%%%
    %%% Estonia
    % For Estonia, data can be extracted from ENTSOE
    case 'Estonia'
        %%%%% TO GET THROUGH THE elering API %%%%%%%%
        TSO    = extractEstonia ;
    %%% Norway
    % For Norway, data can be extracted from ENTSOE
    case 'Norway' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO      = extractstatnett('NO') ;
    %%% Germany
    % For Germany, data can be extracted from ENTSOE
    case 'Germany' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = 0 ;
    %%% Finland
    % For Finland, data can be extracted from ENTSOE
    case 'Finland' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = extractFinland ;
    case 'Bulgaria' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = BG ;
    case 'Denmark' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = DK ;
    case 'Spain' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = ES ;
    case 'Czech' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = 0 ;
    case 'Belgium' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = BE ;
    case 'Romania' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = RO ;
    case 'Portugal' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = PT ;
    case 'Hungary' 
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = HU ;
    case 'Latvia'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = LV('Latvia') ;
    case 'Austria'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = AT ;
    case 'Poland'
        %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
        TSO    = PO ;
    case 'Lithuania'
        TSO    = LV('Lithuania') ;
    case 'Greece'
        TSO    = GR ;
    case 'UK'
        TSO    = UK ;
    otherwise
        TSO = 0 ;
end
