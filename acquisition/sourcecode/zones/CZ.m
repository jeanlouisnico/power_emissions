function CZ

% 
% 
% request = matlab.net.http.RequestMessage('GET');
% 
% request.Header = request.Header.addFields(...
%                                           matlab.net.http.HeaderField('Content-Encoding', 'gzip'),...
%                                           matlab.net.http.field.ContentTypeField('application/json')) ;
% matlab.net.http.field.AuthorizationField()
% uri = matlab.net.URI('/en/all-data?do=loadGraphData&method=Load&graph_id=1026&move_graph=hour&download=false&date_to=2022-02-14T15:00:00&date_from=2022-02-13T16:00:00&agregation=MI&date_type=hour&interval=true&version=RT&function=AVG');
% 
% response = send(request, uri);
% 
% 
% r = send(request,uri);
% 
% 
% url = 'https://www.ceps.cz/download-data/?format=csv';
% 
% options = weboptions('RequestMethod', 'get', 'ArrayFormat','json');
% data = webread(url, options);
% 
% 
% import matlab.net.http.*
% creds = Credentials('Username','MyName','Password','MyPassword');
% options = HTTPOptions('Credentials', creds);
% [response, request] = RequestMessage().send('http://www.ceps.cz/en/all-data?do=loadGraphData&method=Load&graph_id=1026&move_graph=hour&download=false&date_to=2022-02-14T15:00:00&date_from=2022-02-13T16:00:00&agregation=MI&date_type=hour&interval=true&version=RT&function=AVG',options);
% 
% 
% 
% request = matlab.net.http.RequestMessage;
% uri = matlab.net.URI('https://www.ceps.cz/download-data/?format=txt');
% r = send(request,uri);


websave('CZ.csv','https://www.ceps.cz/download-data/?format=csv') ;

test = readtable('CZ.csv') ;

x  =1 ;