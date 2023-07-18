function [ENTSOE, TSO, PoweroutLoad, xCHANGE] = CallCountryPower(country)
% Switch through the selected countries to know where the fetch the data
% from.
%%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
% [ENTSOE, PoweroutLoad] = ENTSOE_meth(country) ;

ENTSOE       = ENTSOE_exch('country',country,'documentType','Generation') ;
PoweroutLoad = ENTSOE_exch('country',country,'documentType','Load')       ;

try
    switch country
        %%% France
        case 'France'
            [TSO.emissionskit, xCHANGE] = extractFrance ;
        %%% Sweden
        % For Sweden, data can be extracted from the TSO website
        case 'Sweden'
            TSO = extractSweden ;
            %%%%% TO GET THROUGH THE www.svk.se API %%%%%%%%
            xCHANGE = XchangeNordic('SE') ;
        %%% Russia
        % For Russia, data can be extracted from the TSO website
        case 'Russia'
            TSO = extractRussia ;
            %%%%% TO GET THROUGH THE br.so-ups.ru API %%%%%%%%
            xCHANGE = XchangeNordic('RU') ;
        %%% Estonia
        % For Estonia, data can be extracted from ENTSOE
        case 'Estonia'
            %%%%% TO GET THROUGH THE elering API %%%%%%%%
            TSO    = extractEstonia ;
            xCHANGE = XchangeNordic('EE') ;
        %%% Norway
        % For Norway, data can be extracted from ENTSOE
        case 'Norway' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO      = extractstatnett('NO') ;
            xCHANGE = XchangeNordic('NO') ;
        %%% Germany
        % For Germany, data can be extracted from ENTSOE
        case 'Germany' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = 0 ;
            xCHANGE = 0 ;
        %%% Finland
        % For Finland, data can be extracted from ENTSOE
        case 'Finland' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = extractFinland ;
            xCHANGE = XchangeNordic('FI') ;
        case 'Bulgaria' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = BG ;
            xCHANGE = BG_XChange ;
        case 'Denmark' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = DK ;
            xCHANGE = XchangeNordic('DK') ;
        case 'Spain' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = ES ;
            xCHANGE = ESXChange ;
        case 'Czech' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = 0 ;
            xCHANGE = 0 ;
        case 'Belgium' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = BE ;
            xCHANGE = BE_Xchange ;
        case 'Romania' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = RO ;
            xCHANGE = 0 ;
        case 'Portugal' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = PT ;
            xCHANGE = PTXChange ;
        case 'Hungary' 
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = HU ;
            xCHANGE = HU_exchange ;
        case 'Latvia'
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = LV('Latvia') ;
            xCHANGE = XchangeNordic('LV') ;
        case 'Austria'
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = AT ;
            xCHANGE = AT_exchange ;
        case 'Poland'
            %%%%% TO GET THROUGH THE ENTSOE API %%%%%%%%
            TSO    = PO ;
            xCHANGE = PO_exchange ;
        case 'Lithuania'
            TSO    = LV('Lithuania') ;
            xCHANGE = XchangeNordic('LT') ;
        case 'Greece'
            TSO    = GR ;
            xCHANGE = 0 ;
        case 'United Kingdom'
            TSO    = UK ;
            xCHANGE = UK_Exchange ;
        case 'Montenegro'
            [TSO, xCHANGE] = ME ;
        otherwise
            TSO = 0 ;
            xCHANGE = 0 ;
    end
catch me
    disp(char(datetime('now')))
    disp( getReport( me, 'extended', 'hyperlinks', 'on' ) ) ;
    errorlog(getReport( me, 'extended', 'hyperlinks', 'off' )) ;
    TSO = 0 ;
    xCHANGE = 0 ;
end
