function Xchange = XchangeNordic(country)



data        = webread('https://www.svk.se/services/controlroom/v2/map/flow/latest') ;
timeextract = datetime(data.LastUpdated/1000,'ConvertFrom','posixtime','TimeZone','UTC') ;

alldata = [data.Data(:).value]' ;
zones = {data.Data.id}' ;

allzones = cellfun(@(x) strsplit(x,'_') , zones  , 'UniformOutput' , false) ;
allzones = cell2table(allzones) ;

L1 = contains(allzones.allzones(:,1),country) ;
L2 = contains(allzones.allzones(:,2),country) ;
L_all = logical((L1 | L2) - (L1 & L2)) ; 


% Get the country code for each
existingzones = unique(allzones.allzones) ;
zoneori = existingzones ;
ccode   = cellfun(@(x) x(length(x)>2,1:2),existingzones,'UniformOutput',false) ;
ccodeem = cell2mat(cellfun(@(x) ~isempty(x),ccode,'UniformOutput',false)) ;

existingzones(ccodeem) = join([ccode(ccodeem), existingzones(ccodeem)],'_') ;

zoneq = [zoneori existingzones] ;

dataextract = alldata(L_all) ;
zones(L_all) ;

dataextract(contains(allzones.allzones(L_all,1),country))
allzones.allzones(contains(allzones.allzones(L_all,2),country))

% sum by zone
pout = struct ;
for icol = 1:2
    if icol == 1
        tzone = allzones.allzones(L_all,2) ;
    else
        tzone = allzones.allzones(L_all,1) ;
    end

    whichzone = unique(tzone(contains(allzones.allzones(L_all,icol),country))) ;
    
    for izone = 1:length(whichzone)
        zonename = whichzone{izone} ;
        extractzone = contains(tzone,zonename) ;
        if icol == 1
            extractdata = -dataextract(extractzone) ;
        else
            extractdata = dataextract(extractzone) ;
        end
        if isfield(pout,zonename)
            pout.(zonename) = pout.(zonename) + sum(extractdata(extractzone)) ;
        else
            pout.(zonename) = sum(extractdata) ;
        end
    end
end

Xchange = table2timetable(struct2table(pout),'RowTimes',timeextract) ;