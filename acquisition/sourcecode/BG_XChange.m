function Xchange = BG_XChange

request = matlab.net.http.RequestMessage;
uri = matlab.net.URI('http://www.eso.bg/api/scada_live_json_pure.php');
r = send(request,uri);

p = struct('RO',0, 'RS',0,'MK',0, 'GR', 0,'TR',0) ;

eachfield = fieldnames(r.Body.Data) ;

for itech = 1:length(eachfield)
    switch eachfield{itech}
        case 'RO_data'
            p.RO = r.Body.Data.(eachfield{itech}) ;
        case 'SR_data'
            p.RS = r.Body.Data.(eachfield{itech}) ;
        case 'MK_data'
            p.MK = r.Body.Data.(eachfield{itech}) ;
        case 'GR_data'
            p.GR = r.Body.Data.(eachfield{itech}) ;
        case 'TR_data'
            p.TR = r.Body.Data.(eachfield{itech}) ;
        otherwise
            continue ;
    end
end

Xchange = table2timetable(struct2table(p),'RowTimes',datetime('now','TimeZone','UTC')) ;