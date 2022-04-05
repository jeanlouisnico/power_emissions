function [Powerout, counter] = ENTSOE_exch(varargin)
%% 
% ENTSOE classifcation is well documented and can be gathered from their
% main interface 
%<https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html>

defaultcountry     = 'France' ;     
defaulttype        = 'Generation' ;
defaultprocessType = 'A16' ;
defaultin_Domain   = '10YFR-RTE------C' ;
defaultout_Domain  = '10YBE----------2' ;
defaultcounter     = 0 ;

p = inputParser;

validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0) && (mod(x,1)==0);
validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
validstring = @(x) isstring(x) || ischar(x) ;

addParameter(p,'country',defaultcountry, validstring);
addParameter(p,'documentType',defaulttype, validstring);
addParameter(p,'processType',defaultprocessType, validstring);
addParameter(p,'in_Domain',defaultin_Domain, validstring);
addParameter(p,'out_Domain',defaultout_Domain, validstring);
addParameter(p,'counter',defaultcounter, validScalarPosNum);

parse(p, varargin{:});

results = p.Results ; 

counter = results.counter ;

bid =  {'B01'	'Biomass'                             
        'B02'	'Fossil Brown coal/Lignite'
        'B03'	'Fossil Coal-derived gas'
        'B04'	'Fossil Gas'
        'B05'	'Fossil Hard coal'
        'B06'	'Fossil Oil'
        'B07'	'Fossil Oil shale'
        'B08'	'Fossil Peat'
        'B09'	'Geothermal'
        'B10'	'Hydro Pumped Storage'
        'B11'	'Hydro Run-of-river and poundage'
        'B12'	'Hydro Water Reservoir'
        'B13'	'Marine'
        'B14'	'Nuclear'
        'B15'	'Other renewable'
        'B16'	'Solar'
        'B17'	'Waste'
        'B18'	'Wind Offshore'
        'B19'	'Wind Onshore'
        'B20'	'Other'} ;

%% Country parser
% Any country could be fetched as long as one would know the domain name of
% the region that one want to extracts. For the sake of the project, only
% the 2 unknown zones were defined, Norway zone 4 Northest part of Norway,
% and Estonia.

%     documentTypeGen  = 'A11' ; % Actual generation per type
% documentTypeLoad = 'A65' ; % System total load
% processType  = 'A16' ; % Realised

code2digit = countrycode(results.country) ;

domainin = ENTSOEdomain(code2digit) ;
results.in_Domain = domainin{end,2} ;

switch code2digit.alpha2
    case 'NO'
        alldomains = domainin(:,2) ;
        for jdom = 1:length(alldomains)
            results.in_Domain = domainin(jdom,:)  ;
            if ~strcmp(results.in_Domain{1},'NO')
                [Powerouttmp.(results.in_Domain{1}), counter] = extractdata(results, code2digit, bid, counter) ;
            end
        end
        % Unload each zone and re-allocate by country
        out = aggregateENTSOEX(Powerouttmp) ;
        Powerout.NO = out ;
    case 'SE'
        alldomains = domainin(:,2) ;
        for jdom = 1:length(alldomains)
            results.in_Domain = domainin(jdom,:)  ;
            if ~strcmp(results.in_Domain{1},'SE')
                [Powerouttmp.(results.in_Domain{1}), counter] = extractdata(results, code2digit, bid, counter) ;
            end
        end
        % Unload each zone and re-allocate by country
        out = aggregateENTSOEX(Powerouttmp) ;
        Powerout.SE = out ;
    case 'DE'
        alldomains = domainin(:,2) ;
        for jdom = 1:length(alldomains)
            results.in_Domain = domainin(jdom,:)  ;
            if strcmp(results.in_Domain{1},'DE_LU')
                [Powerouttmp.(results.in_Domain{1}), counter] = extractdata(results, code2digit, bid, counter) ;
            end
        end
        % Unload each zone and re-allocate by country
        out = aggregateENTSOEX(Powerouttmp) ;
        Powerout.DE = out ;
    case 'DK'
        alldomains = domainin(:,2) ;
        for jdom = 1:length(alldomains)
            results.in_Domain = domainin(jdom,:)  ;
            if ~any(ismember(results.in_Domain{1},{'DK', 'DK-energinet'}))
                [Powerouttmp.(results.in_Domain{1}), counter] = extractdata(results, code2digit, bid, counter) ;
            end
        end
        % Unload each zone and re-allocate by country
        out = aggregateENTSOEX(Powerouttmp) ;
        Powerout.DK = out ;
    case 'IE'
        alldomains = domainin(:,2) ;
        for jdom = 1:length(alldomains)
            results.in_Domain = domainin(jdom,:)  ;
            if strcmp(results.in_Domain{1},'IE_SEM')
                [Powerouttmp.(results.in_Domain{1}), counter] = extractdata(results, code2digit, bid, counter) ;
            end
        end
        % Unload each zone and re-allocate by country
        out = aggregateENTSOEX(Powerouttmp) ;
        Powerout.IE = out ;
    case 'IT'
        alldomains = domainin(:,2) ;
        for jdom = 1:length(alldomains)
            results.in_Domain = domainin(jdom,:)  ;
            if ~strcmp(results.in_Domain{1},'IT')
                [Powerouttmp.(makevalidstring(results.in_Domain{1},'capitalise',false)), counter] = extractdata(results, code2digit, bid, counter) ;
            end
        end
        % Unload each zone and re-allocate by country
        out = aggregateENTSOEX(Powerouttmp) ;
        Powerout.IT = out ;
    case 'RU'
        alldomains = domainin(:,2) ;
        for jdom = 1:length(alldomains)
            results.in_Domain = domainin(jdom,:)  ;
            [Powerouttmp.(results.in_Domain{1}), counter] = extractdata(results, code2digit, bid, counter) ;
        end
        % Unload each zone and re-allocate by country
        out = aggregateENTSOEX(Powerouttmp) ;
        Powerout.RU = out ;
    otherwise
        results.in_Domain = domainin(1,:)  ;
        [Powerout.(results.in_Domain{1}), counter] = extractdata(results, code2digit, bid, counter) ;
        if any(ismember(Powerout.(results.in_Domain{1}).Properties.VariableNames,'initial'))
            Powerout.(results.in_Domain{1}) = removevars(Powerout.(results.in_Domain{1}),'initial') ;
        end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nested function
    function out = aggregateENTSOEX(Powerouttmp)
        eachzone = fieldnames(Powerouttmp) ;
        collectsubzone = {} ;
        for izone = 1:length(eachzone)
                collectsubzone = [collectsubzone; Powerouttmp.(eachzone{izone}).Properties.VariableNames'] ;
        end
        uniquezone = unique(collectsubzone) ;

        for iunique = 1:length(uniquezone)
            switch uniquezone{iunique}
                case {'initial' 'SE'}
                otherwise
                    out.(uniquezone{iunique}) = 0;
                    for izone = 1:length(eachzone)
                        if any(ismember(Powerouttmp.(eachzone{izone}).Properties.VariableNames,uniquezone{iunique}))
                            out.(uniquezone{iunique}) = out.(uniquezone{iunique}) + Powerouttmp.(eachzone{izone}).(uniquezone{iunique}) ;
                        end
                    end
            end
        end
        out = table2timetable(struct2table(out),'RowTimes',datetime('now','TimeZone','UTC')) ;
    end
    function [Powerout, counter] = extractdata(results, code2digit, bid, counter)
        switch results.documentType
            case 'Generation'
                param.documentType = 'A75' ;
                param.processType  = 'A16' ;
                param.in_Domain    = results.in_Domain{2} ;
                [Powerout, counter] = parsergeneration(param, code2digit, bid, counter) ;
                if isa(Powerout,'double')
                    Powerout = array2timetable(Powerout,"RowTimes",datetime('now','TimeZone','UTC'),'VariableNames',{'biomass'}) ;
                end
            case 'Load'
                param.documentType          = 'A65' ;
                param.processType           = 'A16' ;
                param.outBiddingZone_Domain = results.in_Domain{2} ;
                [Powerout, counter] = parsergeneration(param, code2digit, bid, counter) ;
                if isa(Powerout,'double')
                    Powerout = array2timetable(Powerout,"RowTimes",datetime('now','TimeZone','UTC'),'VariableNames',{'load'}) ;
                end
            case 'Exchange'
                param.documentType = 'A11' ;
                param.in_Domain    = results.in_Domain ;
                [Powerout, counter]           = parserexchange(param, code2digit, bid, counter) ;
            otherwise
                warning('Not yet setup')
                return;
        end
    end

    function [Powerout, counter] = parsergeneration(param, code2digit, bid, counter)
        zonecode = makevalidstring(code2digit.alpha2,'capitalise',false) ;
        [Powerout, counter] = getdata(param, bid, counter) ;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function [Powerout, counter] = parserexchange(param, code2digit, bid, counter)
        zonecodeini = makevalidstring(code2digit.alpha2,'capitalise',false) ;
        if strcmp(code2digit.alpha2,'EL')
            code2digit.alpha2 = 'GR' ;
        end
        matbal = Balance_Matrix('country',param.in_Domain{1}) ;
        allcountry = unique(matbal(:,1)) ;

        matbal_zone  = join(matbal,'_') ;
        matbal_zone = strip(matbal_zone,'right','_') ;
        param2pass = param ;
        param2pass.in_Domain  = param.in_Domain{2} ;
        balance.initial = 0 ;
        for ic = 1:length(allcountry)
            tolook.alpha2 = allcountry{ic} ;
            domainout     = ENTSOEdomain(tolook) ;
            if ~strcmp(code2digit.alpha2,tolook.alpha2 )
                if isempty(domainout)
                    Powerout = timetable(datetime('now','TimeZone','UTC'),0,'VariableNames',{'biomass'}) ;
                else
                    for kdoma = 1:size(domainout,1)
                        zonecode = domainout{kdoma,1} ;
                        if ~ismember(zonecode,matbal_zone)
                            continue;
                        end
                        switch zonecode
                            case 'GR'
                                zonecode = 'EL' ;
                        end
                        zone = domainout{kdoma,2} ;
                        
                        param2pass.out_Domain   = zone ;
            
                        zonecode = makevalidstring(zonecode,'capitalise',false) ;
                        [powerimport, counter] = getdata(param2pass, bid, counter) ; 
                        param2pass.out_Domain = param2pass.in_Domain ;
                        param2pass.in_Domain  = zone ;
                        [powerexport, counter] = getdata(param2pass, bid, counter) ;
                        if ~isa(powerimport,'double')
                            TT = synchronize(powerimport,powerexport,'commonrange') ;    
                            balance.(zonecode) = TT(:,'powerarray_powerimport').Variables  - TT(:,'powerarray_powerexport').Variables ;
                        else
                            balance.(zonecode) = 0 ;
                        end
                        param2pass.in_Domain  = param2pass.out_Domain ;
                    end
                end
            end
        end
        try
            TT.powertime(1) ;
        catch
            TT.powertime = datetime('now','TimeZone','UTC') ;
        end
        zonecodeini;
        balance = checkempty(balance) ;
        Powerout = table2timetable(struct2table(balance),'RowTimes',TT.powertime) ;
    end

%% 
% The variable names are taken from ENTSOE variable name and made
% compatible with MatLab valid name (replacing space, underscore,
% backslash)
    function balance = checkempty(balance)
        allF = fieldnames(balance) ;
        for iF = 1:length(allF)
            if isempty(balance.(allF{iF}))
                balance.(allF{iF}) = 0 ;
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [Powerout, counter] = getdata(param, bid, counter)
        try
            [PowerGen, counter] = parseENTSOE(param, counter) ;
            switch param.documentType
                case 'A75'
                    Powerout = parseENTSOEdata(PowerGen, bid) ;
                case 'A65'
                    Powerout = parseLoadENTSOE(PowerGen) ;
                case 'A11'
                    Powerout = parseexchange(PowerGen) ;
                otherwise
            end
            
        catch
            Powerout = 0 ;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Powerout = parseENTSOEdata(Power, bid)
        Powerout = struct ;
        for ibid=1:length(Power.GL_MarketDocument.TimeSeries)
            if isa(Power.GL_MarketDocument.TimeSeries, 'struct')
                bidvar  = Power.GL_MarketDocument.TimeSeries ;
            elseif isa(Power.GL_MarketDocument.TimeSeries, 'cell')
                bidvar  = Power.GL_MarketDocument.TimeSeries{ibid} ;
            else
                return ;
            end
            bidtech = bidvar.MktPSRType.psrType.Text ;
            bidname = bid(strcmp(bid(:,1),bidtech), 2) ; 
            nameout = makevalidstring(bidname) ;

            if isa(bidvar.Period.Point,'struct')
                if isfield(Powerout, nameout{1})
                    Powerout.(nameout{1}) = Powerout.(nameout{1}) + str2double(bidvar.Period.Point.quantity.Text) ;
                else
                    Powerout.(nameout{1}) = str2double(bidvar.Period.Point.quantity.Text) ;
                end
            elseif isa(bidvar.Period.Point,'cell')
                if isfield(Powerout, nameout{1})
                    Powerout.(nameout{1}) = Powerout.(nameout{1}) + str2double(bidvar.Period.Point{end}.quantity.Text) ;
                else
                    Powerout.(nameout{1}) = str2double(bidvar.Period.Point{end}.quantity.Text) ;
                end
            end
        end
        if isa(bidvar.Period.Point,'struct')
            Timeout =  datetime(bidvar.Period.timeInterval.end.Text,'InputFormat','uuuu-MM-dd''T''HH:mm''Z','TimeZone','UTC') ;
        elseif isa(bidvar.Period.Point,'cell')
            Timeout =  datetime(bidvar.Period.timeInterval.end.Text,'InputFormat','uuuu-MM-dd''T''HH:mm''Z','TimeZone','UTC') ;
        end
        Powerout = table2timetable(struct2table(Powerout),'RowTimes',Timeout) ;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function Load = parseLoadENTSOE(Power)
        Load = str2double(Power.GL_MarketDocument.TimeSeries.Period.Point{end}.quantity.Text) ;
        Timeout =  datetime(Power.GL_MarketDocument.TimeSeries.Period.timeInterval.end.Text,'InputFormat','uuuu-MM-dd''T''HH:mm''Z','TimeZone','UTC') ;
        Load = array2timetable(Load,'RowTimes',Timeout) ;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Powerout = parseexchange(Power)
        datain = Power.Publication_MarketDocument.TimeSeries ;
        n = 0 ;
        for idays = 1:length(datain)
            if length(datain) == 1
                day = datain.Period.timeInterval.start.Text ;
                data = datain ;
            else
                day = datain{idays}.Period.timeInterval.start.Text ;
                data = datain{idays} ;
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
                    powerarray(n,1)      = str2double(data.Period.Point{ihours}.quantity.Text) ;
                else
                    pos = str2double(data.Period.Point.position.Text) ;
                    powerarray(n,1)      = str2double(data.Period.Point.quantity.Text) ;
                end
                powertime(n,1)       = day + time * (pos) ;
                
            end 
        end
        PoweroutTT = timetable(powertime, powerarray) ;
        Powerout = PoweroutTT(end,:) ;
    end
end
