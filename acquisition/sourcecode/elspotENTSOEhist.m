function elsepost_array = elspotENTSOEhist(countrycode, varargin)


curtime = datetime('now','TimeZone','UTC') ;

defaulttax     = 0 ;     
periodStart = dateshift(datetime(curtime - hours(11), 'Format','yyyyMMddHHmm'), 'start', 'hour') ;
periodEnd   = dateshift(datetime(curtime + hours(36), 'Format','yyyyMMddHHmm'), 'start', 'hour') ;

p = inputParser;

validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0) && (mod(x,1)==0);

validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
validstring = @(x) isstring(x) || ischar(x) ;

addParameter(p,'tax',defaulttax, @(x) isnumeric(x));
addParameter(p,'datestart',periodStart, @(x) isdatetime(x));
addParameter(p,'dateend',periodEnd, @(x) isdatetime(x));

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

for idom = 1:size(domain,1)
    
    processType  = 'A01' ; % day ahead
    documentType = 'A44' ;
    domainname   = makevalidstring(domain{idom,1}) ;
    idomain      = domain{idom,2} ;
    out_Domain   = domain{idom,2} ;
    
    periodStart = dateshift(datetime(results.datestart, 'Format','yyyyMMddHHmm'), 'start', 'hour') ;
    periodEnd   = dateshift(datetime(results.dateend, 'Format','yyyyMMddHHmm'), 'start', 'hour') ;
    
    url = ['https://transparency.entsoe.eu/api?securityToken=' securityToken ...
               '&documentType=' documentType ...
               '&in_Domain=' idomain ...
               '&out_Domain=' out_Domain ...
               '&periodStart=' char(periodStart) ...
               '&periodEnd=' char(periodEnd)] ;
    
    options = weboptions('Timeout',30);
    try
        data = webread(url,options);
    catch
        elsepost_array.(domainname) = timetable(periodStart, 0,'VariableNames',{'pricearray'}) ;
        continue ;
    end
    price  = xml2struct2(data) ;
    
    % extractdata
    n = 0 ;
    if isfield(price,'Publication_MarketDocument')
        for idays = 1:length(price.Publication_MarketDocument.TimeSeries)
            if length(price.Publication_MarketDocument.TimeSeries) == 1
                day = price.Publication_MarketDocument.TimeSeries.Period.timeInterval.start.Text ;
                data = price.Publication_MarketDocument.TimeSeries ;
            else
                day = price.Publication_MarketDocument.TimeSeries{idays}.Period.timeInterval.start.Text ;
                data = price.Publication_MarketDocument.TimeSeries{idays} ;
            end
            day = datetime(day, 'InputFormat', 'uuuu-MM-dd''T''HH:mm''Z', 'TimeZone', 'UTC') ;
        
            res = data.Period.resolution.Text ;
        
            switch res
                case 'PT15M'
                    time = minutes(15) ;
                case 'PT30M'
                    time = minutes(30) ;
                case 'PT60M'
                    time = minutes(60) ;
            end
            
            nbrofpoints = size(data.Period.Point,2) ;
        
            for ihours = 1:nbrofpoints
                n = n + 1 ;
                if iscell(data.Period.Point)
                    pos = str2double(data.Period.Point{ihours}.position.Text) ;
                    pricearray(n,1)      = str2double(data.Period.Point{ihours}.price_dot_amount.Text) ;
                else
                    pos = str2double(data.Period.Point.position.Text) ;
                    pricearray(n,1)      = str2double(data.Period.Point.price_dot_amount.Text) ;
                end
                pricetime(n,1)       = day + time * (pos-1) ;
                
            end 
        end
        
        elsepost_array.(domainname)  = timetable(pricetime, pricearray*(1+results.tax/100)/10) ;
    else
        elsepost_array.(domainname) = timetable(periodStart, 0,'VariableNames',{'pricearray'}) ;
    end
end
