function Power = extractFinland(Power)

%% Load power Finland
% The load in Finland can be fetch from two sources: Fingrid and ENTSOE.
% The Fingrid API provides real-time data updated eevry 3 minutes (except
% for solar) while the ENTSOE API provides data on hourly basis. 
%%%
% The first method uses the Fingrid API. to get it work, one will need to
% generate a security token for accessing it.



%%%%% TO GET THROUGH THE FINGRID API %%%%%%%%
Power.CHP_DH     = fetchFingrid('CHP_DH')   ; % MWh/h 
Power.CHP_Ind    = fetchFingrid('CHP_Ind')   ; % MWh/h 
Power.NuclearP   = fetchFingrid('NuclearP')  ; % MWh/h 
Power.OtherProd  = fetchFingrid('OtherProd1') + fetchFingrid('OtherProd2')    ; % MWh/h 
Power.WindP      = fetchFingrid('WindP')     ; % MWh/h 
Power.SolarP     = fetchFingrid('SolarP')       ; % MWh/h 
Power.HydroP     = fetchFingrid('HydroP')    ; % MWh/h 

Power.FI.TSO.TotalConsumption = fetchFingrid('TotalConsumption') ; % MWh/h 
Power.FI.TSO.TotalProduction = fetchFingrid('TotalProduction')   ; % MWh/h

Power.FI.TSO.TradeRU  = -fetchFingrid('TradeRussia')  ; % MWh/h 
Power.FI.TSO.TradeEE = -fetchFingrid('TradeEstonia') ; % MWh/h 
Power.FI.TSO.TradeSE  = -(fetchFingrid('TradeSweden4') + fetchFingrid('TradeSweden1'))  ; % MWh/h 
Power.FI.TSO.TradeNO  = -fetchFingrid('TradeNorway')  ; % MWh/h 

Power.FI.TSO.SystemState  = fetchFingrid('SystemState')  ; % MWh/h 

%%%%% TO GET THROUGH THE FINGRID API %%%%%%%%
