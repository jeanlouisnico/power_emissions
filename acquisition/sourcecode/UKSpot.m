function price_timeseries = UKSpot(varargin)

defaultdate = 'yesterday' ;

p = inputParser;
validString = @(x) all(ischar(x)) || all(isstring(x)) ;
addParameter(p,'date',defaultdate,validString);

parse(p, varargin{:});
   
results = p.Results ; 

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;
setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

securitytoken = setup.bmreports.securityToken ;

currentdate = datetime(results.date,'Format','uuuu-MM-dd','TimeZone','Europe/London') ;
format = 'csv' ;
period = '*' ;
report = 'B1770' ;
SettlementDate = char(currentdate) ;
data = webread(['https://api.bmreports.com/BMRS/' report '/v1?APIKey=' securitytoken '&SettlementDate=' SettlementDate '&Period=' period '&ServiceType=' format]) ;


PriceCategory = 'Insufficient balance' ;
SettlementPeriod = unique(data.SettlementPeriod) ;
SettlementDate   = unique(data.SettlementDate) ;
allprices        = data.ImbalancePriceAmount ; %GBP/MWh
resolution       = unique(data.Resolution(~cellfun(@isempty, data.Resolution))) ;
priceout = [] ;
timeout  = [] ;
for idate = 1:length(SettlementDate)
    datein = SettlementDate(idate) ;
    if isnat(datein)
        continue
    end
    for iperiod = 1:length(SettlementPeriod)
        time = SettlementPeriod(iperiod) ;
        if isnan(time)
            continue
        end
        period2extract = data.SettlementPeriod == time & data.SettlementDate == datein & strcmp(data.PriceCategory, PriceCategory) ;
        if isempty(priceout)
            priceout = data.ImbalancePriceAmount(period2extract) ;
        else
            priceout = [priceout; data.ImbalancePriceAmount(period2extract)] ;
        end
        switch resolution{1}
            case 'PT30M'
                date_time = datetime(datein.Year, datein.Month, datein.Day, floor(time*30/60), mod(time*30/60,1)*60,0,'TimeZone','UTC') ;
            case 'PT60M'
                date_time = datetime(datein.year, datein.Month, datein.Day, floor(time*60/60), mod(time*60/60,1)*60,0,'TimeZone','UTC') ;
            otherwise
                date_time = datetime(datein.year, datein.Month, datein.Day, floor(time*30/60), mod(time*30/60,1)*60,0,'TimeZone','UTC') ;
        end
        if isempty(timeout)
            timeout = date_time ;
        else
            timeout = [timeout; date_time] ;
        end
    end
end


price_timeseries = array2timetable(priceout,"RowTimes",timeout) ;
