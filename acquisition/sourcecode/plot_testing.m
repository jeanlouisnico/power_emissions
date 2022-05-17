function plot_testing
% Get the emissions for the last 24 hours

currentdate = datetime(now, "ConvertFrom", "datenum") ;
currentdatestart = datetime(now, "ConvertFrom", "datenum") - hours(24*7) ;

datemovingaverage = datetime(now, "ConvertFrom", "datenum") - days(7) ;

datestart = timeURL(currentdatestart,{'-'}) ;
dateend   = timeURL(currentdate,{'-'}) ;

country = 'FI';

url = ['http://128.214.253.150/api/v1/resources/emissions/findByDate?startdate=' datestart '&enddate=' dateend '&EmDB=EcoInvent&country=' country] ;
p = webread(url) ;
datain = jsondecode(p) ;
% timearray = cellfun(@(x) datetime(x), {datain.results(:).date_time}) ;
emissions.cons = [datain.results(:).em_cons]' ;
emissions.prod = [datain.results(:).em_prod]' ;

idx = cellfun('isempty',{datain.results(:).em_cons});
timearray = cellfun(@(x) datetime(x, 'TimeZone','UTC'), {datain.results(~idx).date_time}) ;

emissionT = table2timetable(struct2table(emissions),'RowTimes', timearray') ;
emissionT = sortrows(emissionT) ;

datestart   = timeURL(datemovingaverage,{'-'}) ;
url = ['http://128.214.253.150/api/v1/resources/emissions/findByDate?startdate=' datestart '&enddate=' dateend '&EmDB=EcoInvent&country=' country] ;
p = webread(url) ;
datain = jsondecode(p) ;

idx = cellfun('isempty',{datain.results(:).em_cons});
timearray = cellfun(@(x) datetime(x, 'TimeZone','UTC'), {datain.results(~idx).date_time}) ;

movingaverage = [datain.results(:).em_cons] ;
longemissions = timetable(timearray',movingaverage') ;
longemissions = sortrows(longemissions) ;

movingmean = cummean(longemissions.Var1,1) ;
movingmeanT = timetable(timearray',movingmean) ;

emiT = synchronize(emissionT,movingmeanT,'Intersection') ;

%% Get power by fuel
datestart = timeURL(currentdatestart,{'-'}) ;
dateend   = timeURL(currentdate,{'-'}) ;
opts = weboptions("Timeout", 30) ;
url = ['http://128.214.253.150/api/v1/resources/power/findByDate?startdate=' datestart '&enddate=' dateend '&country=' country '&powersource=TSO'] ;
p = webread(url, opts) ;
datain = jsondecode(p) ;

idx = cellfun('isempty',{datain.results(:).value});
timearray = cellfun(@(x) datetime(x, 'TimeZone','UTC'), {datain.results(~idx).date_time}) ;

powergen = {datain.results(:).fuel}';
allfuels = unique(powergen) ;


for ifuel = 1:length(allfuels)
    idxfuel  = strcmp(powergen,allfuels{ifuel}) ;
    fuelout = {datain.results(idxfuel).value}';
    timein = timearray(idxfuel') ;
    fuel.(allfuels{ifuel}) = array2timetable([fuelout{:}]','RowTimes', timein) ;
    fuel.(allfuels{ifuel}) = sortrows(fuel.(allfuels{ifuel})) ;
end

fuel2 = struct2cell(fuel) ;
fuel2 = synchronize(fuel2{:,:}) ;
fuel2.Properties.VariableNames = fieldnames(fuel) ;
var2plot = fuel2.Variables ;

    color = {'nuclear', 255, 104, 106
            'nuclear_PWR', 255, 104, 106
            'biomass', 143, 255, 143
            'waste', 143, 255, 143
            'wind', 119, 187, 255
            'windoff', 119, 187, 255
            'windon', 119, 187, 255
            'solar', 255, 255, 128
            'hydro', 0, 128, 192
            'hydro_pumped' , 0, 128, 192
            'hydro_reservoir', 0, 128, 192
            'hydro_runof', 0, 128, 192
            'coal', 0, 0, 0
            'coal_chp', 0, 0, 0
            'unknown', 0, 0, 0
            'oil', 61, 0, 0
            'peat', 90, 216, 89
            'gas', 174, 215, 255
            'others', 217, 83, 25} ;

f1 = figure ;
f1.Position = [15,290,1128,420] ;

[hAx,hLine1,hLine2] = plotyy(fuel2.Time, fuel2.Variables,emiT.Time,emiT.Variables) ;

legend([hLine1;hLine2],[fuel2.Properties.VariableNames' ; {'Emission Consumption';'Emission Production';'moving average emissions'}], 'Location', 'bestoutside');
hLine2(2).Color = 'blue' ;
hLine2(1).Color = 'black' ;
hLine2(1).LineWidth = 1 ;
hLine2(2).LineWidth = 1 ;

for ibgfsdLine = 1:length(hLine1)
    source =  strcmp(color(:,1),hLine1(ibgfsdLine).DisplayName) ;
    hLine1(ibgfsdLine).Color = [color{source,2} color{source,3} color{source,4}]/255 ; 
end

ylabel(hAx(2), 'CO_{2} Emissions intensity [gCO2/kWh]')
ylabel(hAx(1), 'Power generation [MWh]')
exportgraphics(f1,'Power_System_State.png')
% % xlim([min(alltime) max(alltime)]) ;
% 
% % ylabel('CO_{2} Emissions intensity [gCO2/kWh]')

if exist("fig2plotly",'file')
    try
%         fig = fig2plotly(f1, 'offline', false, 'filename','Emissions', 'open', false) ;
        fig = fig2plotly(f1, 'offline', true, 'filename','Emissions', 'open', false) ;
    catch
        fig = fig2plotly(f1, 'offline', true, 'filename','Emissions', 'open', false) ;
    end
%     clockplot1time_donut ;
    close(f1) ;
else
    warning('plotly was not installed, go to https://github.com/plotly/plotly_matlab to get the latest version of plotly and enable online and offline plotting')
end







