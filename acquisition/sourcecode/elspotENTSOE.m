function elsepost_array = elspotENTSOE(countrycode, varargin)

defaulttax     = 0 ;     

p = inputParser;

validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0) && (mod(x,1)==0);

validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
validstring = @(x) isstring(x) || ischar(x) ;

addParameter(p,'tax',defaulttax, @(x) isnumeric(x));

parse(p, varargin{:});

results = p.Results ; 

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;
setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

securityToken = setup.ENTSOE.securityToken ;

domain = ENTSOEdomain(countrycode) ;

if isempty(domain)
    elsepost_array = [] ;
    return;
end

curtime = datetime('now','TimeZone','UTC') ;

processType  = 'A01' ; % day ahead
documentType = 'A44' ;
idomain      = domain{2} ;
out_Domain   = domain{2} ;

periodStart = dateshift(datetime(curtime - hours(11), 'Format','yyyyMMddHHmm'), 'start', 'hour') ;
periodEnd   = dateshift(datetime(curtime + hours(36), 'Format','yyyyMMddHHmm'), 'start', 'hour') ;

url = ['https://transparency.entsoe.eu/api?securityToken=' securityToken ...
           '&documentType=' documentType ...
           '&in_Domain=' idomain ...
           '&out_Domain=' out_Domain ...
           '&periodStart=' char(periodStart) ...
           '&periodEnd=' char(periodEnd)] ;

options = weboptions('Timeout',5);
data = webread(url,options);

price  = xml2struct2(data) ;

% extractdata
n = 0 ;
for idays = 1:length(price.Publication_MarketDocument.TimeSeries)
    if length(price.Publication_MarketDocument.TimeSeries) == 1
        day = price.Publication_MarketDocument.TimeSeries.Period.timeInterval.start.Text ;
    else
        day = price.Publication_MarketDocument.TimeSeries{idays}.Period.timeInterval.start.Text ;
    end
    day = datetime(day, 'InputFormat', 'uuuu-MM-dd''T''HH:mm''Z') ;
    for ihours = 1:24
        n = n + 1 ;
        pricetime(n,1)       = day + hours(ihours) ;
        if length(price.Publication_MarketDocument.TimeSeries) == 1
            pricearray(n,1)      = str2double(price.Publication_MarketDocument.TimeSeries.Period.Point{ihours}.price_dot_amount.Text) ;
        else
            pricearray(n,1)      = str2double(price.Publication_MarketDocument.TimeSeries{idays}.Period.Point{ihours}.price_dot_amount.Text) ;
        end
    end 
end

elsepost_array = timetable(pricetime, pricearray*(1+results.tax/100)/10) ;
