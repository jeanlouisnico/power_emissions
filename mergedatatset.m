function merged_data = mergedatatset(new, past)

gatherallcountries_past = fieldnames(past) ;
gatherallcountries_new = fieldnames(new) ;
nbrmonthrep = 4 ;
% Loop through all countries that are in the past
for icountry = 1:length(gatherallcountries_past)
% Check that the country exist in the new database
    countrypast = gatherallcountries_past{icountry} ;
    % if it does not exist then replicate the ones from the old database
    if ismember(countrypast, gatherallcountries_new)
    % if it exists then extract the last value from each table
        newDB = new.(countrypast) ;
        oldDB = past.(countrypast) ;
        oldDB.Time.TimeZone = 'UTC' ;
        newDB.Time.TimeZone = 'UTC' ;
        lastentryold = oldDB.Time(end) ;
        lastentrynew = newDB.Time(end) ;
    % Get all the substances listed in the old database
        sub_old = oldDB.Properties.VariableNames ;
        sub_new = newDB.Properties.VariableNames ;
    % Check if the substances exist in the new database
        for isubs = 1:length(sub_old)
            if ismember(sub_old{isubs}, sub_new)
                % Check that the last time is the same
                col_old = oldDB(:,sub_old{isubs}) ;
                col_new = newDB(:,sub_old{isubs}) ;

                % Replace the last 4 months of data from the new database
                % How many months are missing
                nbr_month = round(hours(lastentrynew - lastentryold)/(24*30)) ;
                for imonth = (nbr_month + nbrmonthrep):-1:1
                    if imonth <= nbr_month
                        newtime = col_new.Time(end-imonth + 1) ;
                        % Check if the row exist
                        if ~ismember(oldDB.Time, newtime)
                            % create an empty row 
                            a  = array2timetable(zeros(1,length(oldDB.Properties.VariableNames)),"RowTimes",newtime,"VariableNames", oldDB.Properties.VariableNames) ;
                            % Then add a new row
                            oldDB = [oldDB;a ] ;
                        end
                        oldDB(newtime,sub_old{isubs}) = col_new(newtime,sub_old{isubs}) ;
                    else
                        % Replace with the new values
                        oldtime = col_old.Time(end-imonth + 1) ;
                        oldDB(oldtime,sub_old{isubs}) = col_new(oldtime,sub_old{isubs}) ;
                    end
                end
                % if it is different
                % Identify the new timesadd a new timerow with NaN values to the 
            else
                % If it is not there then add it to the new table
                %newDB = synchronize(newDB,oldDB(:,sub_old{isubs})) ;
            end
        end
        past.(countrypast) = oldDB ;
    else
%         past.(countrypast) = past.(countrypast) ;
    end
end
merged_data = past ;