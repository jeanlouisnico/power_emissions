
function Powerout = parseENTSOE(param)
%% More information
% <https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html#_areas>

%% Set up time

timeUTC= datetime('now','TimeZone','UTC') ;

%% data parser
% documentType = dtype ; % Actual generation per type
% processType  = ptype ; % Realised
% In_Domain    = idomain ;
% param.documentType = documentType ;
% switch documentType
%     case 'A75'
%         domainzone =  'In_Domain' ;
%         param.In_Domain    = idomain ;
%     case 'A65'
%         domainzone =  'outBiddingZone_Domain' ;
%         param.outBiddingZone_Domain    = idomain ;
%     case 'A11'
%         domainzone =  'outBiddingZone_Domain' ;
%         param.in_Domain    = idomain ;
%         param.out_Domain    = idomain ;
% end
%% data fetch
% Data are retrieved from the ENTSOE API. The method used here uses the
% webbrowser and uses the format where processType, In_Domain, periodStart,
% and periodEnd need to be defined. This returns all the power plant that
% are active for the current In_Domain. 

out = [] ;
fieldparam = fieldnames(param) ;
for iout = 1:length(fieldparam)
    out = [out ; fieldparam(iout) param.(fieldparam{iout})] ;
end
out = join(out,'=') ;
out = join(out','&') ;
Loopnbr = 0 ;
n = 0 ;
    while n == 0
        Loopnbr = Loopnbr + 1 ;
        hour1 = Loopnbr + 6 ;
        hour2 = Loopnbr - 1 ;
        %%% 
        % ENTSOE retrieves data hourly. Therefore, the data are taken for the
        % previous hour to the current hour.
        periodStart = char(dateshift(datetime(timeUTC - hours(hour1), 'Format','yyyyMMddHHmm'), 'start', 'hour')) ;
        periodEnd   = char(dateshift(datetime(timeUTC - hours(hour2), 'Format','yyyyMMddHHmm'), 'start', 'hour')) ;

       try
            data = retrievedata(out, periodStart, periodEnd) ;
            if isempty(data)
                Powerout = 0 ;
            else
                Powerout  = xml2struct2(data) ;
                n = 1 ;
            end
       catch ME
           ME
           %%%
           % If it fails, most likely there is no production --> try the
           % previous hour to see if there was a delay in the data and retrieve
           % older data if returns true
       end
       if Loopnbr > 3
           Powerout = 0 ;
           n = 1 ;
       end
    end
    function url = getURLentsoe(param, periodStart, periodEnd)
        p = mfilename('fullpath') ;
        [filepath,~,~] = fileparts(p) ;
        fparts = split(filepath, filesep) ;
        fparts = join(fparts(1:end-1), filesep) ;
        setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

        securityToken = setup.ENTSOE.securityToken ;
        
        url = ['https://transparency.entsoe.eu/api?securityToken=' securityToken '&' ...
               param{1} ...
               '&periodStart=' periodStart ...
               '&periodEnd=' periodEnd] ;
    end
    function data = retrievedata(param, periodStart, periodEnd)
        url = getURLentsoe(param, periodStart, periodEnd) ;
        options = weboptions('Timeout',5);
        data = webread(url,options);
    end
end
