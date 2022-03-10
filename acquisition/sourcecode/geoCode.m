function [c] = geoCode(address, service, varargin)
%GEOCODE look up the latitude and longitude of a an address
%
%   COORDS = GEOCODE( ADDRESS ) returns the geocoded latitude and longitude 
%   of the input address. 
%
%   COORDS = GEOCODE( ADDRESS, SERVICE) performs the look up using the
%   specified SERVICE. Valid services are
%       google  - Google Maps  (default service)
%       osm     - OpenStreetMap
%       yahoo   - Yahoo! Place Finder 
%
%   COORDS = GEOCODE( ..., SERVICE, APIKEY) allows the specifcation of an AppId
%   API key if needed.
% Copyright(c) 2012, Stuart P. Layton <stuart.layton@gmail.com>
% http://stuartlayton.com
%
% Revision History
%   2012/08/20 - Initial Release
%   2012/08/20 - Simplified XML parsing code
% Validate the input arguments
% Check to see if address is a valid string


defaultKey = []     ;
defaultCity = ''    ;
defaultCountry = ''    ;
defaultPostCode = struct() ;

p = inputParser;

addParameter(p,'city',defaultCity);
addParameter(p,'country',defaultCountry);
addParameter(p,'key',defaultKey,@isstring);
addParameter(p,'PostCode',defaultPostCode,@isstruct);

parse(p, varargin{:});
results = p.Results ; 

FP = mfilename('fullpath') ;
FP = strsplit(FP,filesep)   ;
FP = FP(1:end-1)            ;
fullpath = strjoin(FP,filesep) ;

if isempty(address) || ~ischar(address) || ~isvector(address)
    error('Invalid address provided, must be a string');
end
% if no service is specified or an empty service is specified use google
if nargin<2 || isempty(service) 
    service = 'google';
end
% if no key is specified then set it to empty, also check to see if char array
% if nargin<3 
%     key = [];
% end
key = results.key ;

%replace white spaces in the address with '+'
address = regexprep(address, ' ', '+');

% Load all the csv files and postcode from EU
if isempty(results.PostCode)
    NUTPath = [fullpath filesep 'pc2020_NUTS-2021_v4.0'] ;
    listing = dir(NUTPath) ;
    for icsv = 1:length(listing)
        switch listing(icsv).name
            case {'.','..','.MATLABDriveTag'}
                continue ;
            otherwise
                Countrycode = strsplit(listing(icsv).name,'_') ;
                Countrycode = Countrycode{2} ;
                PostCode.(['NUT' Countrycode]) = readtable([NUTPath filesep listing(icsv).name],'Delimiter',';');
        end
    end
else
    PostCode = results.PostCode ;
end
countrylist = CList ;
% Switch on the specified service, construct the Query URL, and specify the
% function that will be used to parse the resulting XML 
switch lower(service)
    case('google')
        SERVER_URL = 'http://maps.google.com';
        queryUrl = sprintf('%s/maps/place/%s',SERVER_URL, address);
        parseFcn = @parseGoogleMapsXML;
    case('yahoo')
      
        SERVER_URL = 'http://where.yahooapis.com/geocode';
        queryUrl = sprintf('%s?location=%s',SERVER_URL, address);
       
% The Yahoo docs say that an AppID is required although
% it appears that responses are given without a valid appid 
% If an AppId is provided include it in the URL
        if ~isempty(key)
            queryUrl = sprintf('%s&appid=%s', queryUrl, key);
        end
        
        parseFcn = @parseYahooLocalXML;
        
    
    case {'osm', 'openstreetmaps', 'open street maps'}
        
        SERVER_URL = 'http://nominatim.openstreetmap.org/search';
        queryUrl = sprintf('%s?format=xml&q=%s', SERVER_URL, address);
        parseFcn = @parseOpenStreetMapXML;
    otherwise
        error('Invalid geocoding service specified:%s', service);
end
    try
        docNodeText = webread(queryUrl,weboptions('ContentType','text')); 
        docNode = webread(queryUrl,weboptions('ContentType','xmldom')); 
    catch  %#ok<CTCH>
        error('Error, could not reach %s, is it a valid URL?', SERVER_URL);
    end
   
    c = parseFcn(docNode, countrylist, results, PostCode, address);
end
% Function to parse the XML response from Google Maps
function [c] = parseGoogleMapsXML(docNode)
    
    %check the response code to see if we got a valid response
    codeEl = docNode.getElementsByTagName('code');
    errCode = str2double( char( codeEl.item(0).getTextContent ) );
    % code 200 is associated with a valid geocode xml file
    if errCode~=200
        fprintf('No data received from server! Received code:%d\n', errCode)
        c = nan(2,1);
        return;
    end
    %get the 'coordinates' element from the document
    cordEl = docNode.getElementsByTagName('coordinates');
    
    %make sure the xml actually included a coordinates tag
    if cordEl.length<1
        c = nan(2,1);
        warning('No coordinates returned for the specified address');
        return;
    end
        
    % get the coordinates from the first node, convert them to numbers
    coords = cellfun(@str2double, regexp( char( cordEl.item(0).getTextContent), ',', 'split'));
    
    c = coords([2, 1]); % return the latitude and longitude
end
% Function to parse the XML response from Yahoo Local
function [c] = parseYahooLocalXML(docNode)
    
    %check the response code to see if we got a valid response
    codeEl = docNode.getElementsByTagName('Error');
    errCode = str2double( char( codeEl.item(0).getTextContent ) );
    
    % code 0 is associated with a valid geocode xml file
    if errCode~=0
        fprintf('No data received from server! Received code:%d\n', errCode)
        c = nan(2,1);
        return;
    end
    
    %check to see if a location was actually found
    foundEl = docNode.getElementsByTagName('Found');
    found = str2double( char( foundEl.item(0).getTextContent) );
    % 
    if found<1
        disp('A location with that address was not found!');
        c = nan(2,1);
        return;
    end
    
    
    latEl = docNode.getElementsByTagName('latitude');
    lonEl = docNode.getElementsByTagName('longitude');
    
    %make sure the xml actually included latitude and longitude tags
    if latEl.length==0 || lonEl.length==0
        c = nan(2,1);
        disp('No coordinates were found for that address');   
        return;
    end
    
    c(1) = str2double( char( latEl.item(0).getTextContent) );
    c(2) = str2double( char( lonEl.item(0).getTextContent) );
    
end
% Function to parse the XML response from OpenStreetMap
function [c] = parseOpenStreetMapXML(docNode, countrylist, results, PostCodeList, address)
    
    serverResponse = docNode.getElementsByTagName('searchresults').item(0);
    
    n = 0 ;
    i = 0 ;
    placeTagcheck = serverResponse.getElementsByTagName('place').item(0);
    while n == 0
        try
            placeTag = serverResponse.getElementsByTagName('place').item(i);
            
            c{i+1,1} = str2double( char( placeTag.getAttribute('lat') ) );
            c{i+1,2} = str2double( char( placeTag.getAttribute('lon') ) );
            c{i+1,3} = char(placeTag.getAttribute('display_name')) ;
            
            PostCode = strsplit(c{i+1,3},',') ;
            PostCode = PostCode(end - 1) ;
            PostCode = PostCode{1}   ;
            PostCode = PostCode(2:end) ;
            
            if isempty(results.city)
                PostCode = erase(PostCode, address) ;
            else
                PostCode = erase(PostCode, results.city) ;
            end
            
            c{i+1,4} = PostCode ;
            
            if isempty(results.country)
                NUTs3 = '' ;
                ClusterNB = '' ;
            else
                countrycode = countrylist(find(strcmp(countrylist(:,1),results.country)==1),2) ;

                if isa(PostCodeList.(['NUT' countrycode{1}]).CODE,'double')
                    if isa(PostCode, 'char')
                        PostCode = str2double(PostCode) ;
                    end
                    NUTS3Loc = find(PostCodeList.(['NUT' countrycode{1}]).CODE==PostCode) ;
                elseif isa(PostCodeList.(['NUT' countrycode{1}]).CODE,'cell') 
                    NUTS3Loc = find(strcmp(PostCodeList.(['NUT' countrycode{1}]).CODE, PostCode) == 1) ;
                end

                if isempty(NUTS3Loc)
                    NUTs3 = 'Postcode invalid' ;
                    ClusterNB = '' ;
                else
                    NUTs3 = PostCodeList.(['NUT' countrycode{1}]).NUTS3{NUTS3Loc} ;
                    ClusterNB = PostCodeList.(['NUT' countrycode{1}]).Cluster{NUTS3Loc} ;
                end
            end
            
            c{i+1,5} = NUTs3 ;
            c{i+1,6} = ClusterNB ;
            
            i = i+1 ;
        catch
            % No more results to display
            n = 1 ;
        end
    end
    if isempty(placeTagcheck)
        disp('OpenStreeMap returned no data for that address');%#ok
        c = nan(2,1);
        return;
    end
    
%     c{1} = str2double( char( placeTag.getAttribute('lat') ) );
%     c{2} = str2double( char( placeTag.getAttribute('lon') ) );
%     c{3} = char(placeTag.getAttribute('display_name')) ;
end
function elementText = GetElementText(resultNode,elementName)
% GETELEMENTTEXT given a result node and an element name
% returns the text within that node as a Matlab CHAR array
elementText = ...
    char( resultNode.getElementsByTagName(elementName).item(0).getTextContent );
end
function countrylist = CList()
    countrylist = {'Austria'	'AT'
                    'Belgium'	'BE'
                    'Bulgaria'	'BG'
                    'Switzerland'	'CH'
                    'Cyprus'	'CY'
                    'Czech Republic'	'CZ'
                    'Germany'	'DE'
                    'Denmark'	'DK'
                    'Estonia'	'EE'
                    'Greece'	'EL'
                    'Spain'	'ES'
                    'Finland'	'FI'
                    'France'	'FR'
                    'Croatia'	'HR'
                    'Hungary'	'HU'
                    'Ireland'	'IE'
                    'Iceland'	'IS'
                    'Italy'	'IT'
                    'Liechtenstein'	'LI'
                    'Lithuania'	'LT'
                    'Luxembourg'	'LU'
                    'Latvia'	'LV'
                    'North Macedonia'	'MK'
                    'Malta'	'MT'
                    'Netherlands'	'NL'
                    'Norway'	'NO'
                    'Poland'	'PL'
                    'Portugal'	'PT'
                    'Romania'	'RO'
                    'Serbia'	'RS'
                    'Sweden'	'SE'
                    'Slovenia'	'SI'
                    'Slovekia'	'SK'
                    'Turkey'	'TR'
                    'United Kingdom'	'UK' } ;
end