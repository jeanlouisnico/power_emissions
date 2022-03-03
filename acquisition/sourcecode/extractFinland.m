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
EmissionsCategory = 'GlobalWarming' ;
Emissionsdatabase = load_emissions ;

[IndCHP, DHCHP, Sep, Windpower, fuelratio] = extract2stat ;
             
%% Fuel Split
% Categories are extracted from the fuel classification of statistic
% Finland (above extract2stat function). The
%%%
% Split the production from CHP based on the installed capacity of each
% technology in Finland
%%
% $P_{Fuel, Tech} = P_{tech} \times \begin{bmatrix} \eta_{fuel1} \\  \vdots \\  \eta_{fueln} \end{bmatrix}$
%

fueldis = table2struct(array2table((Power.bytech.CHP_DH + Power.bytech.CHP_Ind) * struct2array(fuelratio.chp), "VariableNames", fieldnames(fuelratio.chp))) ;

CHP_DH_Fuel  = (struct2array(fueldis)) .* struct2array(DHCHP.totalload) ./ (struct2array(DHCHP.totalload) + struct2array(IndCHP.totalload)) ;
CHP_Ind_Fuel = (struct2array(fueldis)) .* struct2array(IndCHP.totalload) ./ (struct2array(DHCHP.totalload) + struct2array(IndCHP.totalload)) ;

CHP_DH_Fuel = table2struct(array2table(CHP_DH_Fuel, "VariableNames", fieldnames(fuelratio.chp))) ;     % MWh
CHP_Ind_Fuel = table2struct(array2table(CHP_Ind_Fuel, "VariableNames", fieldnames(fuelratio.chp))) ;   % MWh

Sep_Fuel = table2struct(array2table(struct2array(Sep.ratioload) * Power.bytech.OtherProd / 100 , "VariableNames", fieldnames(Sep.ratioload))) ;  % MWh
WindCat  = table2struct(array2table(struct2array(Windpower) * Power.bytech.WindP / 100 , "VariableNames", fieldnames(Windpower))) ;  % MWh

if ~isfield(Sep_Fuel, 'biomass')
    Sep_Fuel.biomass = 0 ;
end
if ~isfield(Sep_Fuel, 'others')
    Sep_Fuel.others = 0 ;
end
%% Power categories
% Calculate the power production per technology and store it in 2
% categories: The low carbon tech, and the renewable energy (RES) tech.
%%%
% $P_{low-carbon} = P_{Nuclear} + P_{biomass, CHP} + P_{Wind} + P_{Hydro}$
Power.LowCarbon.Power = Power.bytech.NuclearP + ...
                        CHP_DH_Fuel.biomass + ...
                        Power.bytech.WindP + ...
                        Power.bytech.SolarP + ...
                        Power.bytech.HydroP + ...
                        CHP_Ind_Fuel.biomass + ...
                        Sep_Fuel.biomass ;
%%%
% $P_{RES} = P_{biomass, CHP} + P_{Wind} + P_{Hydro}$
Power.RES.Power = CHP_DH_Fuel.biomass + ...
                  Power.bytech.WindP + ...
                  Power.bytech.SolarP + ...
                  Power.bytech.HydroP + ...
                  CHP_Ind_Fuel.biomass + ...
                  Sep_Fuel.biomass ;

%% Statistic retrieval
% All power related data are stored in 1 variable and calcualte the ratio
% of low carbon and RES compared to total production of electricity in the
% country.
%%%
% $\eta_{Low-carbon} = \frac{P_{Low-carbon}}{P_{Total}}$
Power.LowCarbon.Ratio = Power.LowCarbon.Power / Power.TotalProduction * 100 ;
%%%
% $\eta_{RES} = \frac{P_{RES}}{P_{Total}}$
Power.RES.Ratio = Power.RES.Power / Power.TotalProduction * 100 ;

Power.byfuel.nuclear   = Power.bytech.NuclearP ;
Power.byfuel.biomass   = Sep_Fuel.biomass + CHP_Ind_Fuel.biomass + CHP_DH_Fuel.biomass ;
Power.byfuel.wind      = Power.bytech.WindP ;
Power.byfuel.solar     = Power.bytech.SolarP ;
Power.byfuel.hydro     = Power.bytech.HydroP ;
Power.byfuel.coal      = Sep_Fuel.coal      + CHP_Ind_Fuel.coal     + CHP_DH_Fuel.coal ;
Power.byfuel.oil       = Sep_Fuel.oil       + CHP_Ind_Fuel.oil      + CHP_DH_Fuel.oil ;
Power.byfuel.peat      = Sep_Fuel.peat      + CHP_Ind_Fuel.peat 	+ CHP_DH_Fuel.peat ;
Power.byfuel.gas       = Sep_Fuel.gas       + CHP_Ind_Fuel.gas      + CHP_DH_Fuel.gas ;
Power.byfuel.others    = Sep_Fuel.others    + CHP_Ind_Fuel.others   + CHP_DH_Fuel.others ;
