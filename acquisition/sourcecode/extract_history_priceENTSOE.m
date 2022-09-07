function elsepost_array = extract_history_priceENTSOE(varargin)

defaultupdateall     = false ;     
defaultupdatemiss    = true ;

p = inputParser;

pfile = mfilename('fullpath') ;
[filepath,~,~] = fileparts(pfile) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0) && (mod(x,1)==0);
% validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
% validstring = @(x) isstring(x) || ischar(x) ;

addParameter(p,'updateall',defaultupdateall, @islogical);
addParameter(p,'updatemiss',defaultupdatemiss, @islogical);

parse(p, varargin{:});

results = p.Results ; 

if results.updateall
    startingyear = 2015 ;
elseif results.updatemiss
    data = load("elspot_prices.mat") ;
    elsepost_array = data.elsepost_array ;
    allyears = fieldnames(data.elsepost_array.AT) ;
    
    lastentry = data.elsepost_array.AT.(allyears{end}).at.pricetime(end) ;
    startingyear = lastentry.Year ;
else
    data = load("elspot_prices.mat") ;
    elsepost_array = data.elsepost_array ;
end

curtime = datetime('now','TimeZone','UTC') ;

if results.updateall || results.updatemiss
    for idate = startingyear:curtime.Year
        datestart = datetime(idate,1,1) ;
        if idate == curtime.Year
            dateend = datetime(curtime - caldays(1)) ;
        else
            dateend = datetime(idate,12,31,23,59,59) ;
        end
        Country = country2fetch ;
    
        country_code = countrycode(Country) ;
        
        
        for icountry = 1:length(Country)
            elsepost_array.(country_code.alpha2{icountry}).(['x' num2str(datestart.Year)]) = elspotENTSOEhist(country_code(icountry,:),'datestart',datestart,'dateend',dateend) ;
        end
    end

    save(strjoin({fparts{1},'input','general','elspot_prices.mat'},filesep),'elsepost_array') ;
end
priceout = conca_elspot(elsepost_array) ;
allgeo = fieldnames(priceout) ;

for igeo = 1:length(allgeo)
    geo = allgeo{igeo} ;    
    if isa(priceout.(geo),'timetable')
        data3.(geo) = timetable2table(priceout.(geo)) ;
    elseif isa(priceout.(geo),'struct')
        allgeo2 = fieldnames(priceout.(geo)) ;
        for igeo2 = 1:length(allgeo2)
            geo2 = allgeo2{igeo2} ;    
            if isa(priceout.(geo).(geo2),'timetable')
                data3.(geo).(geo2) = timetable2table(priceout.(geo).(geo2)) ;
            end
        end
    end
end

% Save the extracted data to a json file
dlmwrite(strjoin({fparts{1},'input','general','elspot_pricesTT.json'},filesep),jsonencode(data3, "PrettyPrint", true),'delimiter','');


save(strjoin({fparts{1},'input','general','elspot_pricesTT.mat'},filesep),'priceout') ;