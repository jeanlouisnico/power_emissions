function [lat, lon] = countryloc(PostCode, varargin)

defaultcountryname = 'Finland'    ;
defaultCityname = 'Helsinki'    ;
defaultservice = 'osm'    ;

p = inputParser;

addParameter(p,'countryname',defaultcountryname);
addParameter(p,'Cityname',defaultCityname);
addParameter(p,'service',defaultservice);

parse(p, varargin{:});
results = p.Results ; 

address     = [results.Cityname ', ' results.countryname]     ;

[c] = geoCode(address, results.service, 'city', results.Cityname, 'country', results.countryname, 'PostCode', PostCode) ;

lat = c{1,1} ;
lon = c{1,2} ;