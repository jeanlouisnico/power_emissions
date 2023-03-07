function DBsql2mat_Xchange(datain)

power = [] ;

power = extract_power(datain, power) ;
save(['Xchange_DB_' char(datetime('now','Format','yyyyMMddHHmm'))],'power','-mat') ;
end

function power = extract_power(x, power)
    allcountries = unique(x.fromcountry) ;
    allpower = unique(x.source) ;
    for icountry = 1:length(allcountries)
        countryname = allcountries{icountry} ;
        for iDB = 1:length(allpower)
            DBname = allpower{iDB} ;
            
            extract = strcmp(x.fromcountry, countryname) & strcmp(x.source, DBname) ;

            time = x.date_time(extract) ;
            if isempty(time)
%                 switch DBname
%                     case 'ENTSOE'
%                         classification = 'byfuel' ;
%                     case 'TSO'
%                         classification = 'emissionskit' ;
%                 end
                power.(countryname).(DBname) = [] ;
                continue ;
            end
            time2extract = unique(time) ;
            power_Xch = x.powerexch(extract) ;
            tocountry = x.tocountry(extract) ;
            fuellist = unique(tocountry) ;
            powertemp = [] ;    
            for itime = 1:length(time2extract)
                timex = time2extract(itime) ;

                extract2 = time == timex ;
                
                tocountrytranslate = tocountry(extract2) ;
                powerout       = power_Xch(extract2) ;

                % Find duplicate entries if any
                [D,~,X] = unique(tocountrytranslate) ;
                Y = histc(X,unique(X));
                if any(Y>1)
                    Ploc = [] ;
                    % This means at least 1 entry is a duplicate
                    % find all duplicates:
                    duplicatecountry = D(Y>1) ;
                    single_entry = D(Y==1) ;
                    tocountrytranslate2 = tocountrytranslate ;
                    tocountrytranslate = [] ;
                    for i = 1:length(duplicatecountry)
                        duplx = duplicatecountry{i} ;
                        loc = strcmp(tocountrytranslate2,duplx) ; 
                        Ploc(i,1) = mean(powerout(loc)) ;
                        tocountrytranslate{i,1} = duplx ;
                    end
                    if ~isempty(single_entry)
                        indexi = numel(Ploc) ;
                        for i = 1:length(single_entry)
                            duplx = single_entry{i} ;
                            loc = strcmp(tocountrytranslate2,duplx) ; 
                            Ploc(indexi + i,1) = mean(powerout(loc)) ;
                            tocountrytranslate{indexi + i,1} = duplx ;
                        end
                    end
                    powerout = Ploc ;
                end

                % Find missing fuel
                missingfuel = fuellist(~ismember(fuellist, tocountrytranslate)) ;
                try

                if isempty(missingfuel)
                    convert2TT  = array2timetable(powerout', "VariableNames",tocountrytranslate','RowTimes',timex) ;
                else
                    poweroutfinal = [powerout; zeros(length(missingfuel),1)] ;
                    convert2TT  = array2timetable(poweroutfinal', "VariableNames",[tocountrytranslate;missingfuel]', 'RowTimes',timex) ;
                end
                catch
                    x = 1 ;
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
%                 switch DBname
%                     case 'ENTSOE'
%                         classification = 'byfuel' ;
%                     case 'TSO'
%                         classification = 'emissionskit' ;
%                 end
                if isempty(power)
                    power.(countryname).(DBname) = powertemp ;
                else
                    try
                        power.(countryname).(DBname) = [power.(countryname).(DBname);powertemp] ;
                    catch
                        power.(countryname).(DBname) = powertemp ;
                    end
                end
        end
    end
end