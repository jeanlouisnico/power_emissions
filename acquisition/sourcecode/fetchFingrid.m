function Retrieveresult = fetchFingrid(tech)
%% Set up the ID per technology
codelist = {'TotalConsumption'	'193'
'TotalProduction'	'192'
'NuclearP'	'188'
'CHP_Ind'	'202'
'CHP_DH'	'201'
'OtherProd1'	'189'
'OtherProd2'	'205'
'WindP'	'181'
'SolarP'	'248'
'HydroP'	'191'
'TradeEstonia'	'180'
'TradeRussia'	'195'
'TradeNorway'	'187'
'TradeSweden4'	'89'
'TradeSweden1'	'87'
'SystemState'	'209'
} ;

codeID = codelist(find(strcmp(tech, codelist)==1), 2) ;

%% Set up the time
currenttime = javaObject("java.util.Date") ;
timezone    = -currenttime.getTimezoneOffset()/60 ;
switch tech
    %%%
    % The solar production from Fingrid is not live and is updated every
    % hours based on forecast information, therefore the routine for the
    % data has to be re-written to reflect this feature, specifically for
    % solar power
    case 'SolarP'
        periodStart = dateshift(datetime(datetime(datestr(now)) - hours(timezone), 'Format','yyyy-MM-ddHH:mm:ss'), 'start', 'hour') ;
            periodStartchar = [num2str(periodStart.Year) '-' ...
                               sprintf('%02d',periodStart.Month) '-' ...
                               sprintf('%02d',periodStart.Day) 'T' ...
                               sprintf('%02d',periodStart.Hour) '%3A' ...
                               sprintf('%02d',periodStart.Minute) '%3A00Z'] ;

        periodEnd = dateshift(datetime(datetime(datestr(now)) - hours(timezone) + hours(1), 'Format','yyyy-MM-ddHH:mm:ss'), 'start', 'hour') ;
            periodEndchar = [num2str(periodEnd.Year) '-' ...
                               sprintf('%02d',periodEnd.Month) '-' ...
                               sprintf('%02d',periodEnd.Day) 'T' ...
                               sprintf('%02d',periodEnd.Hour) '%3A' ...
                               sprintf('%02d',periodEnd.Minute) '%3A00Z'] ;
    %%%
    % For other technologies, we fetch the data from 6 to 3 minutes before
    % the current data. Mind that all date time are in UTC format and
    % therefore the timezone from which the code is ran need to be included
    % to reflect the correct time
    otherwise 
        periodStart = dateshift(datetime(datetime(datestr(now)) - hours(timezone) - minutes(6), 'Format','yyyy-MM-ddHH:mm:ss'), 'start', 'minute') ;
            periodStartchar = [num2str(periodStart.Year) '-' ...
                               sprintf('%02d',periodStart.Month) '-' ...
                               sprintf('%02d',periodStart.Day) 'T' ...
                               sprintf('%02d',periodStart.Hour) '%3A' ...
                               sprintf('%02d',periodStart.Minute) '%3A00Z'] ;

        periodEnd = dateshift(datetime(datetime(datestr(now)) - hours(timezone) - minutes(3), 'Format','yyyy-MM-ddHH:mm:ss'), 'start', 'minute') ;
            periodEndchar = [num2str(periodEnd.Year) '-' ...
                               sprintf('%02d',periodEnd.Month) '-' ...
                               sprintf('%02d',periodEnd.Day) 'T' ...
                               sprintf('%02d',periodEnd.Hour) '%3A' ...
                               sprintf('%02d',periodEnd.Minute) '%3A00Z'] ;
end

%% API instance
% For Fingrid data, the easiest way is to invoke the curl system to
% retrieve data. In the example below, we are retrieving the .json file and
% read it to retrieve the last instance.

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;
setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

securitytoken = setup.Fingrid.securityToken ;

if isempty(securitytoken)
    Retrieveresult = 0 ;
else
    curlcall = ['curl -X GET --header "Accept: application/json" --header "x-api-key: ' ...
                securitytoken '" "https://api.fingrid.fi/v1/variable/' ...
                 num2str(codeID{1}) '/events/json?start_time=' ...
                 periodStartchar '&end_time=' ...
                 periodEndchar '"'] ;

    [~, p] = system(curlcall) ;
    jsonout = findstr('[', p) ;
    Powerout = jsondecode(p(jsonout:end)) ;
    if isempty(Powerout)
        Retrieveresult = 0 ;
    else
        Retrieveresult = Powerout.value ;
    end
end

