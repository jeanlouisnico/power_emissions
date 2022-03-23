function xCHANGE = UK_Exchange
%%% Explanation for the API can be found here https://www.elexon.co.uk/documents/training-guidance/bsc-guidance-notes/bmrs-api-and-data-push-user-guide-2/

fuel = {'INTFR' 'FR'
        'INTIRL' 'IR'
        'INTNED' 'NL'
        'INTEW' 'IR'
        'INTNEM' 'BE'
        'INTELEC' 'FR'
        'INTIFA2' 'FR'
        'INTNSL' 'NO'} ;

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;
setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

securitytoken = setup.bmreports.securityToken ;

currentdate = datetime('now','Format','uuuu-MM-dd','TimeZone','Europe/London') ;
format = 'csv' ;
period = '*' ;
report = 'INTERFUELHH' ;

data = webread(['https://api.bmreports.com/BMRS/' report '/v1?APIKey=' securitytoken '&ServiceType=' format]) ;

%%% Find last entry that is not NAN

A = data(:,2:end) ;
A = A.Variables ;
B = ~isnan(A);
% indices
Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:size(A, 2));
% values
Values = arrayfun(@(x,y) A(x,y), Indices, 1:size(A, 2));

timein = datetime(datetime(num2str(data(Indices(2),2).Variables),'Format','uuuuMMdd') + hours(Values(2) * .5),'Format','dd/MM/uuuu HH:mm:ss', 'TimeZone', 'UTC') ;

zones = unique(fuel(:,2)) ;

for izones = 1:length(zones)
    Xchange.(zones{izones}) = sum(Values(ismember((fuel(:,2)),zones{izones}))) ;
end

xCHANGE = table2timetable(struct2table(Xchange),'RowTimes',timein);