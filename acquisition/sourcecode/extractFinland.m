function Power = extractFinland

%% Load power Finland
% The load in Finland can be fetch from two sources: Fingrid and ENTSOE.
% The Fingrid API provides real-time data updated eevry 3 minutes (except
% for solar) while the ENTSOE API provides data on hourly basis. 
%%%
% The first method uses the Fingrid API. to get it work, one will need to
% generate a security token for accessing it.



%%%%% TO GET THROUGH THE FINGRID API %%%%%%%%
Power.bytech.CHP_DH     = fetchFingrid('CHP_DH')   ; % MWh/h 
Power.bytech.CHP_Ind    = fetchFingrid('CHP_Ind')   ; % MWh/h 
Power.bytech.NuclearP   = fetchFingrid('NuclearP')  ; % MWh/h 
Power.bytech.OtherProd  = fetchFingrid('OtherProd1') + fetchFingrid('OtherProd2')    ; % MWh/h 
Power.bytech.WindP      = fetchFingrid('WindP')     ; % MWh/h 
Power.bytech.SolarP     = fetchFingrid('SolarP')       ; % MWh/h 
Power.bytech.HydroP     = fetchFingrid('HydroP')    ; % MWh/h 

Power.TotalConsumption = fetchFingrid('TotalConsumption') ; % MWh/h 
Power.TotalProduction = fetchFingrid('TotalProduction')   ; % MWh/h

Power.TradeRU  = -fetchFingrid('TradeRussia')  ; % MWh/h 
Power.TradeEE = -fetchFingrid('TradeEstonia') ; % MWh/h 
Power.TradeSE  = -(fetchFingrid('TradeSweden4') + fetchFingrid('TradeSweden1'))  ; % MWh/h 
Power.TradeNO  = -fetchFingrid('TradeNorway')  ; % MWh/h 

Power.SystemState  = fetchFingrid('SystemState')  ; % MWh/h 

%%%%% TO GET THROUGH THE FINGRID API %%%%%%%%
