function [Powerout, PoweroutLoad] = ENTSOE_meth(country)
%% 
% ENTSOE classifcation is well documented and can be gathered from their
% main interface 
%<https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html>

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

documentTypeGen  = 'A75' ; % Actual generation per type
documentTypeLoad = 'A65' ; % System total load
processType  = 'A16' ; % Realised

code2digit = countrycode(country) ;
idomain = ENTSOEdomain(code2digit) ;
for kdoma = 1:size(idomain,1)
    zonecode = idomain{kdoma,1} ;
    zone = idomain{kdoma,2} ;
    zonecode = makevalidstring(zonecode,'capitalise',false) ;
    [Powerout.(zonecode), PoweroutLoad.(zonecode)] = getdata(documentTypeGen, documentTypeLoad, processType, zone, bid) ;
end

% Nested function
    function Powerout = parsetech(documentType, processType, idomain)
        Powerout = parseENTSOE(documentType, processType, idomain) ;
    end
%% 
% The variable names are taken from ENTSOE variable name and made
% compatible with MatLab valid name (replacing space, underscore,
% backslash)
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
            nameout = strrep(lower(bidname),' ','_') ;
            nameout = strrep(nameout, '/', '_') ;
            nameout = strrep(nameout, '-', '_') ;
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
    end
    function [Powerout, PoweroutLoad] = getdata(documentTypeGen, documentTypeLoad, processType, idomain, bid)
        try
            PowerGen = parsetech(documentTypeGen, processType, idomain) ;
            Powerout = parseENTSOEdata(PowerGen, bid) ;
        catch
            Powerout = 0 ;
        end
        try
            PowerLoad = parsetech(documentTypeLoad, processType, idomain) ;
            PoweroutLoad = parseLoadENTSOE(PowerLoad) ;
        catch
            PoweroutLoad = 0 ;
        end
    end
    function Load = parseLoadENTSOE(Power)
        Load = str2double(Power.GL_MarketDocument.TimeSeries.Period.Point{end}.quantity.Text) ;
    end
end
