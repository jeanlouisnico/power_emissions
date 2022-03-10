function solarCF = getSolardata(countryname)

timein = datetime('now','TimeZone','UTC') ;
timearray = datetime(timein.Year, timein.Month,timein.Day,'TimeZone','UTC'):minutes(10):datetime(timein.Year, timein.Month,timein.Day, 23, 59, 59,'TimeZone','UTC') ;

Time = datenum(timearray) ;
Time = pvl_maketimestruct(Time,0) ;

countrydetails = countrycode(countryname) ;

Cityname    = countrydetails.capital ;
address     = [Cityname ', ' countryname]     ;
service     = 'osm' ;
% PostCode = getNUTS ;
[c] = geoCode(address, service, 'city', Cityname, 'country', countryname) ;

Location.latitude  = c{1};
Location.longitude = c{2}; 

% Create 1-min time series for Jan 1, 2012
[SunAz, SunEl, ApparentSunEl, SolarTime]=pvl_ephemeris(Time, Location);
ApparentZenith = 90-ApparentSunEl;
ClearSkyGHI = pvl_clearsky_haurwitz(ApparentZenith);
dHr = Time.hour+Time.minute./60+Time.second./3600; % Calculate decimal hours for plotting
outCF = timetable(ClearSkyGHI/1000, 'RowTimes', timearray) ;
[~,ind1] = min(abs(datenum(outCF.Time)-datenum(timein)));
solarCF = outCF(ind1,:) ;

% figure
% plot(dHr,ClearSkyGHI)
% title('Clear Sky Irradiance on June 1, 2012 in Albuquerque, NM','FontSize',14)
% xlabel('Hour of the Day (hr)')
% ylabel('GHI (W/m^2)')

end