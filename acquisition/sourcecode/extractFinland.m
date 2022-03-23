function Power = extractFinland

%% Load power Finland
% The load in Finland can be fetch from two sources: Fingrid and ENTSOE.
% The Fingrid API provides real-time data updated eevry 3 minutes (except
% for solar) while the ENTSOE API provides data on hourly basis. 
%%%
% The first method uses the Fingrid API. to get it work, one will need to
% generate a security token for accessing it.

timeextract = datetime('now', 'Format','yyyy.MM.dd', 'TimeZone','Europe/Helsinki') ;

%%%%% TO GET THROUGH THE FINGRID API %%%%%%%%
TSO.CHP_DH       = fetchFingrid('CHP_DH')   ; % MWh/h 
TSO.CHP_Ind      = fetchFingrid('CHP_Ind')   ; % MWh/h 
TSO.nuclear      = fetchFingrid('NuclearP')  ; % MWh/h 
TSO.other        = fetchFingrid('OtherProd1') + fetchFingrid('OtherProd2')    ; % MWh/h 
TSO.windon       = fetchFingrid('WindP')     ; % MWh/h 
TSO.solar        = fetchFingrid('SolarP')       ; % MWh/h 
TSO.hydro        = fetchFingrid('HydroP')    ; % MWh/h 

TSO.TotalConsumption = fetchFingrid('TotalConsumption') ; % MWh/h 
TSO.TotalProduction = fetchFingrid('TotalProduction')   ; % MWh/h

TSO.TradeRU  = -fetchFingrid('TradeRussia')  ; % MWh/h 
TSO.TradeEE = -fetchFingrid('TradeEstonia') ; % MWh/h 
TSO.TradeSE  = -(fetchFingrid('TradeSweden4') + fetchFingrid('TradeSweden1'))  ; % MWh/h 
TSO.TradeNO  = -fetchFingrid('TradeNorway')  ; % MWh/h 

TSO.SystemState  = fetchFingrid('SystemState')  ; % MWh/h 

%% The emissionkit method

%%%%% TO GET THROUGH THE FINGRID API %%%%%%%%

[IndCHP, DHCHP, Sep, capacity, fuelratio] = extract2stat ;


Power.emissionskit = FI_emissionkit(TSO, capacity,timeextract) ;   
Power.emissionskit = convertTT_Time(Power.emissionskit,'UTC') ;
%% Fuel Split
% Categories are extracted from the fuel classification of statistic
% Finland (above extract2stat function). The
%%%
% Split the production from CHP based on the installed capacity of each
% technology in Finland
%%
% $P_{Fuel, Tech} = P_{tech} \times \begin{bmatrix} \eta_{fuel1} \\  \vdots \\  \eta_{fueln} \end{bmatrix}$
%
fueldis = table2struct(array2table((TSO.CHP_DH + TSO.CHP_Ind) * struct2array(fuelratio.chp), "VariableNames", fieldnames(fuelratio.chp))) ;

CHP_DH_Fuel  = (struct2array(fueldis)) .* struct2array(DHCHP.totalload) ./ (struct2array(DHCHP.totalload) + struct2array(IndCHP.totalload)) ;
CHP_Ind_Fuel = (struct2array(fueldis)) .* struct2array(IndCHP.totalload) ./ (struct2array(DHCHP.totalload) + struct2array(IndCHP.totalload)) ;

CHP_DH_Fuel = table2struct(array2table(CHP_DH_Fuel, "VariableNames", fieldnames(fuelratio.chp))) ;     % MWh
CHP_Ind_Fuel = table2struct(array2table(CHP_Ind_Fuel, "VariableNames", fieldnames(fuelratio.chp))) ;   % MWh

Sep_Fuel = table2struct(array2table(struct2array(Sep.ratioload) * TSO.other / 100 , "VariableNames", fieldnames(Sep.ratioload))) ;  % MWh
WindCat  = table2struct(array2table(struct2array(capacity.wind.ratioload) * TSO.windon / 100 , "VariableNames", fieldnames(capacity.wind.ratioload))) ;  % MWh

if ~isfield(Sep_Fuel, 'biomass')
    Sep_Fuel.biomass = 0 ;
end
if ~isfield(Sep_Fuel, 'other')
    Sep_Fuel.other = 0 ;
end
%% Power categories
% Calculate the power production per technology and store it in 2
% categories: The low carbon tech, and the renewable energy (RES) tech.
%%%
% $P_{low-carbon} = P_{Nuclear} + P_{biomass, CHP} + P_{Wind} + P_{Hydro}$
TSO.LowCarbon = TSO.nuclear + ...
                        CHP_DH_Fuel.biomass + ...
                        TSO.windon + ...
                        TSO.solar + ...
                        TSO.hydro + ...
                        CHP_Ind_Fuel.biomass + ...
                        Sep_Fuel.biomass ;
%%%
% $P_{RES} = P_{biomass, CHP} + P_{Wind} + P_{Hydro}$
TSO.RES = CHP_DH_Fuel.biomass + ...
                  TSO.windon + ...
                  TSO.solar + ...
                  TSO.hydro + ...
                  CHP_Ind_Fuel.biomass + ...
                  Sep_Fuel.biomass ;

%% Statistic retrieval
% All power related data are stored in 1 variable and calcualte the ratio
% of low carbon and RES compared to total production of electricity in the
% country.
%%%
% $\eta_{Low-carbon} = \frac{P_{Low-carbon}}{P_{Total}}$
TSO.LowCarbonRatio = TSO.LowCarbon / TSO.TotalProduction * 100 ;
%%%
% $\eta_{RES} = \frac{P_{RES}}{P_{Total}}$
TSO.RESRatio = TSO.RES / TSO.TotalProduction * 100 ;

byfuel.nuclear   = TSO.nuclear ;
byfuel.biomass   = Sep_Fuel.biomass + CHP_Ind_Fuel.biomass + CHP_DH_Fuel.biomass ;
byfuel.windon    = TSO.windon ;
byfuel.solar     = TSO.solar ;
byfuel.hydro     = TSO.hydro ;
byfuel.coal      = Sep_Fuel.coal     ;
byfuel.coal_chp  = CHP_Ind_Fuel.coal     + CHP_DH_Fuel.coal ;
byfuel.oil       = Sep_Fuel.oil  ;
byfuel.oil_chp   = CHP_Ind_Fuel.oil      + CHP_DH_Fuel.oil ;
byfuel.peat      = Sep_Fuel.peat      + CHP_Ind_Fuel.peat 	  + CHP_DH_Fuel.peat ;
byfuel.gas       = Sep_Fuel.gas    ;
byfuel.gas_chp   = CHP_Ind_Fuel.gas      + CHP_DH_Fuel.gas ;
byfuel.other     = Sep_Fuel.other    + CHP_Ind_Fuel.other   + CHP_DH_Fuel.other ;


Power.bytech = table2timetable(struct2table(TSO),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;
Power.byfuel = table2timetable(struct2table(byfuel),'RowTimes',datetime(timeextract,'Format','dd/MM/uuuu HH:mm:ss')) ;

Power.bytech = convertTT_Time(Power.bytech,'UTC') ;
Power.byfuel = convertTT_Time(Power.byfuel,'UTC') ;
