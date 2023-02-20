function [emissions,power] = fectchAPI(varargin)

defaultstart     = datetime(2022,9,1) ;  
defaultend       = datetime(2022,9,3) ;

p = inputParser;

% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0) && (mod(x,1)==0);
% validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
% validstring = @(x) isstring(x) || ischar(x) ;
% 
addParameter(p,'startdate',defaultstart, @isdatetime);
addParameter(p,'enddate',defaultend, @isdatetime);

parse(p, varargin{:});

results = p.Results ;

    startdate = results.startdate ;
    enddate   = results.enddate ;
    
    source = {'emissions', 'power'} ;
    
    datefecth = startdate:caldays(1):enddate ;
    opts = weboptions("Timeout",60) ;
    emissions =  [] ;
    power = [] ;
    for src = 1:length(source)
        isource = source{src} ;
        for iday = 1:length(datefecth)
            if iday < length(datefecth)
                URL = ['http://128.214.253.150/api/v1/resources/' isource '/findByDate?startdate=' ...
                       char(datetime(datefecth(iday),"Format","yyyy-MM-dd")) '%2000%3A00%3A00&enddate=' ...
                       char(datetime(datefecth(iday+1),"Format","yyyy-MM-dd")) '%2000%3A00%3A00'] ;
            else
                URL = ['http://128.214.253.150/api/v1/resources/' isource '/findByDate?startdate=' ...
                       char(datetime(datefecth(iday),"Format","yyyy-MM-dd")) '%2000%3A00%3A00&enddate=' ...
                       char(datetime(datefecth(iday) + caldays(1),"Format","yyyy-MM-dd")) '%2000%3A00%3A00'] ;
            end
        
            try
                test = webread(URL, opts) ;
            catch
                continue ;
            end
            if ~isempty(test)
                test2 = jsondecode(test) ;
                x = unloadjson(test2) ;
                
                switch isource
                    case 'emissions'
                        emissions = extract_emissions(x, emissions) ;
                    case 'power'
                        power = extract_power(x, power) ;
                end
                
            end
            
        
        end
    end
end

%%%
function x = unloadjson(in)
    x = in.results ;
    x = struct2table(x) ;
    
    mapping = {'country' 'char'
               'date_time' 'datetime'
               'em_prod'    'double'
               'em_cons'    'double'
               'emdb'   'char'
               'id'     'double'
               'powergen' 'char'
               'fuel'   'char'
               'value'  'double'
        } ;

    allvars = x.Properties.VariableNames ;

    for ivars = 1:numel(allvars)
        varname = allvars{ivars} ;
        namepos = strcmp(varname, mapping(:,1)) ;
        nametype = mapping(namepos, 2) ;
        
        switch nametype{1}
            case 'double'
                t = x.(varname) ;
                if isa(t, "cell")
                    tf = cellfun('isempty',t) ;
                    t(tf) = {0} ;
                    t = cell2mat(t) ;
                end
                x.(varname) = t ;
            case 'datetime'
                t = x.(varname) ;
                tf = datetime(t,'InputFormat','yyyy-MM-dd HH:mm:ss') ;
                x.(varname) = tf ;
            otherwise

        end
    end
end

%%% Classify emissions
function emissions = extract_emissions(x, emissions)
    allcountries = unique(x.country) ;
    allemissions = unique(x.emdb) ;
    for icountry = 1:length(allcountries)
        countryname = allcountries{icountry} ;
        for iDB = 1:length(allemissions)
            DBname = allemissions{iDB} ;
            
            extract = strcmp(x.country, countryname) & strcmp(x.emdb, DBname) ;

            time = x.date_time(extract) ;
            em_cons = x.em_cons(extract) ;
            em_prod = x.em_prod(extract) ;

            intensityprodtemp = rmoutliers(sortrows(array2timetable(em_prod,"VariableNames",{'EF'},"RowTimes",time))) ;
            intensityconstemp = rmoutliers(sortrows(array2timetable(em_cons,"VariableNames",{'EF'},"RowTimes",time))) ;
            try
                if isfield(emissions.(countryname).emissionskit.(DBname),'intensityprod')
                    emissions.(countryname).emissionskit.(DBname).intensityprod = [emissions.(countryname).emissionskit.(DBname).intensityprod;intensityprodtemp] ;
                    emissions.(countryname).emissionskit.(DBname).intensitycons = [emissions.(countryname).emissionskit.(DBname).intensitycons;intensityconstemp] ;
                else
                    emissions.(countryname).emissionskit.(DBname).intensityprod = intensityprodtemp ;
                    emissions.(countryname).emissionskit.(DBname).intensitycons = intensityconstemp ;
                end
            catch
                emissions.(countryname).emissionskit.(DBname).intensityprod = intensityprodtemp ;
                emissions.(countryname).emissionskit.(DBname).intensitycons = intensityconstemp ;
            end
            

        end
    end
end

%%% Classify power
function power = extract_power(x, power)
    allcountries = unique(x.country) ;
    allpower = unique(x.powergen) ;
    for icountry = 1:length(allcountries)
        countryname = allcountries{icountry} ;
        for iDB = 1:length(allpower)
            DBname = allpower{iDB} ;
            
            extract = strcmp(x.country, countryname) & strcmp(x.powergen, DBname) ;

            time = x.date_time(extract) ;
            time2extract = unique(time) ;
            power_prod = x.value(extract) ;
            fuel_cat = x.fuel(extract) ;
            fuellist = unique(fuel_cat) ;
            powertemp = [] ;    
            for itime = 1:length(time2extract)
                timex = time2extract(itime) ;

                extract2 = time == timex ;
                
                fuel2translate = fuel_cat(extract2) ;
                powerout       = power_prod(extract2) ;

                % Find missing fuel
                missingfuel = fuellist(~ismember(fuellist, fuel2translate)) ;

                if isempty(missingfuel)
                    convert2TT  = array2timetable(powerout', "VariableNames",fuel2translate','RowTimes',timex) ;
                else
                    poweroutfinal = [powerout; zeros(length(missingfuel),1)] ;
                    convert2TT  = array2timetable(poweroutfinal', "VariableNames",[fuel2translate;missingfuel]', 'RowTimes',timex) ;
                end
                if isempty(powertemp)
                    powertemp = convert2TT ;
                else
                    % Order according to the first input timetable
                    convert2TT = convert2TT(:,powertemp.Properties.VariableNames) ;
                    powertemp = [powertemp;convert2TT] ;
                end
            end    
                % find the missing fuels

                powertemp = rmoutliers(sortrows(powertemp)) ;
                
                switch DBname
                    case 'ENTSOE'
                        classification = 'byfuel' ;
                    case 'TSO'
                        classification = 'emissionskit' ;
                end

                try
                    if isfield(power.(countryname).(DBname),classification)
                        power.(countryname).(DBname).(classification) = [power.(countryname).(DBname).(classification);powertemp] ;
                    else
                        power.(countryname).(DBname).(classification) = powertemp ;
                    end
                catch
                    power.(countryname).(DBname).(classification) = powertemp ;
                end
            

        end
    end
end
