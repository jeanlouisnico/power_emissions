function json_query = json_ini()
%
% Initial configuration data exchange using JSON
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% JSON Parameters

language = 'en'; % 'de'/'fr' also allowed...
host_URL = 'https://ec.europa.eu/eurostat/wdds/rest/data/v2.1/json/';
precision = '8';% Decimal places (max)
groupedIndicators = '1';% '1'/'0' perhaps applicable for multiple selection
unitLabel = 'label';% 'label'/'code'
shortLabel = '0';

%% Query format
% -> example: ...nama_gdp_c?precision=8&geo=CZ&geo=DE&unit=MIO_NAC&indic_na=P51&groupedIndicators=1&unitLabel=label

json_query = [host_URL language '/#table_name#?precision=' precision ...
                                              '&shortLabel=' shortLabel ...
                                              '&#userFilters#' ...
                                              '&groupedIndicators=' groupedIndicators ...
                                              '&unitLabel=' unitLabel];

end %<eof>