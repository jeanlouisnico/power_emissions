function Powerout = extractEstonia

currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

%% Get the mix for the previous month to complement the data from statistic Estonia

try 
    systemdata_month = webread('https://dashboard.elering.ee/api/balance/total/latest') ;
catch
    Powerout = 0 ;
    return;
end
t = uint64(systemdata_month.data.timestamp*1000) ;
d = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS') ;

datestart = datestr(datetime(datestr(now))  - hours(6), 'yyyy-mm-ddTHH:MM:SS.FFFZ') ;
dateend = datestr(datetime(datestr(now))  + hours(6), 'yyyy-mm-ddTHH:MM:SS.FFFZ')   ;
url = ['https://dashboard.elering.ee/api/system/with-plan?start=' datestart '&end=' dateend] ;
systemdata = webread(url) ;

t = uint64(systemdata.data.real(end).timestamp*1000) ;
d = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS') + hours(timezone) ;

Powerout.production = systemdata.data.real(end).production ;
Powerout.consumption = systemdata.data.real(end).consumption ;
Powerout.production_renewable =  systemdata.data.real(end).production_renewable ;
Powerout.solar =  systemdata.data.real(end).solar_energy_production ;

if isempty(Powerout.solar)
    alldates = [systemdata.data.plan.timestamp] ;
    t = uint64(alldates*1000) ;
    alldates = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS') + hours(timezone) ;
    datecompare = datetime(now, "ConvertFrom", "datenum") ;
    Powerout.solar = systemdata.data.plan(find((alldates.Hour == d.Hour)==1)).solar_energy_forecast_operator ;
end

try
    transmission = webread('https://dashboard.elering.ee/api/transmission/cross-border/latest') ;
catch
    Powerout = 0 ;
    return;
end
Powerout.Finland = transmission.data.finland ;
Powerout.Russia = transmission.data.russia_narva + transmission.data.russia_pihkva ;
Powerout.Latvia = transmission.data.latvia ;
%% HEre is a second extract from the Latvian TSO that has more regular updates for Estonia (about every 3 minutes)

options = weboptions('Timeout',15) ;
timeextract = datestr(now, 'yyyy-mm-dd') ;
try
    estoniaprod = webread(['https://www.ast.lv/lv/ajax/charts/production?productionDate=' timeextract '&countryCode=EE'], options) ;
catch
    estoniaprod = 0 ;
end

if isa(estoniaprod, 'struct')
    try
        t = estoniaprod.data(1).data(end).x ;
        d = datetime(t,'ConvertFrom','epochtime','TicksPerSecond',1e3,'Format','dd-MMM-yyyy HH:mm:ss.SSS') + hours(timezone) ;
    
        Powerout.thermal = estoniaprod.data(1).data(end).y ;
        Powerout.unknown = estoniaprod.data(2).data(end).y ;
        Powerout.wind = estoniaprod.data(3).data(end).y ;
        Powerout.hydro = estoniaprod.data(4).data(end).y ;
        Powerout.nuclear = estoniaprod.data(5).data(end).y ;
        Powerout.productionLV = estoniaprod.data(6).data(end).y ;
        Powerout.consumptionLV = estoniaprod.data(7).data(end).y ;
        Powerout.import = estoniaprod.data(8).data(end).y ;
    catch
    end
end



% power = struct2table(power) ;
% 
% Powerout = table2timetable(power, 'RowTimes', d) ;

% If solar is empty, access the approximate values

%https://dashboard.elering.ee/api/transmission/cross-border?start=2021-09-22T21:00:00.000Z&end=2021-09-23T20:59:59.999Z

