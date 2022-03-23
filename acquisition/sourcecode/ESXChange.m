function xCHANGE = ESXChange

%% Portugal
toPT = PTXChange ;
toPT.Properties.VariableNames = {'PT'} ;
toPT.PT = toPT.PT * -1 ;

%% France
[~, PXchange] = extractFrance ;
toFR = PXchange(:,'ES') ;
toFR.Properties.VariableNames = {'FR'} ;
toFR.FR = toFR.FR * -1 ;

%% Total import export
Total_Exchange = ES_interconnection ;

toMorocco = Total_Exchange.inter - (toFR.FR + toPT.PT(end)) ;

xCHANGE.FR = toFR.FR ;
xCHANGE.PT = toPT.PT(end) ;
xCHANGE.MA = toMorocco ;


xCHANGE = table2timetable(struct2table(xCHANGE),'RowTimes',Total_Exchange.Time) ;