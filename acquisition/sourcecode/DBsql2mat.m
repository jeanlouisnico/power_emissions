function DBsql2mat(datain)

power = [] ;

power = extract_power(datain, power) ;
save(['power_DB_old_' char(datetime('now','Format','yyyyMMddHHmm'))],'power','-mat') ;
end

function power = extract_power(x, power)
    allcountries = unique(x.country) ;
    allpower = unique(x.powersource) ;
    for icountry = 1:length(allcountries)
        countryname = allcountries{icountry} ;
        for iDB = 1:length(allpower)
            DBname = allpower{iDB} ;
            
            extract = strcmp(x.country, countryname) & strcmp(x.powersource, DBname) ;

            time = x.date_time(extract) ;
            if isempty(time)
                switch DBname
                    case 'ENTSOE'
                        classification = 'byfuel' ;
                    case 'TSO'
                        classification = 'emissionskit' ;
                end
                power.(countryname).(DBname).(classification) = [] ;
                continue ;
            end
            time2extract = unique(time) ;
            power_prod = x.power_generated(extract) ;
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
            try
                powertemp = filloutliers(sortrows(powertemp),"previous","movmean",hours(2)) ;
            catch
                x = 1 ;
            end
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