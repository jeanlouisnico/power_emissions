function xtemp = fuelmixEU_lpredict(fuelMatrix)

fuelin = fuelMatrix ;

vars = fuelin.Properties.VariableNames;
t2 = fuelin{:,vars};
t2(isnan(t2)) = 0;
fuelin{:,vars} = t2 ;

currenttime = javaObject("java.util.Date") ; 
timezone = -currenttime.getTimezoneOffset()/60 ;

timeextract = datetime(datetime(datestr(now)) - hours(timezone)) ;


    
    %%% Find ratio fuel per month
%     findrow = (Fueluse.(techn).Year == (timeextract.Year - 1) & Fueluse.(techn).Month == timeextract.Month) ;
%     fuellist = fieldnames(DHCHP.totalload) ;
    
    nyear = 0 ;
    n = 0 ;
    % Locate the last available month from the fuel data
    while n == 0
         nyear = nyear + 1 ;
         timetarget = timeextract - calmonths(nyear) ;
         if any((fuelin.Time.Year == (timetarget.Year) & fuelin.Time.Month == timetarget.Month) )
             n = 1;
             predictedstep = nyear ;
%              findrow = (Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) ;
         end
    end
    
x = fuelin ;
    [y, ~] = lpredict(x.Variables, 14, predictedstep, 'post') ; % the rank 14 has been found to give the most accruate results
    xtemp = [x.Variables;y] ;
    xtemp = array2timetable(xtemp, "RowTimes",...
                [datetime(fuelin.Time(1).Year,fuelin.Time(1).Month,1):...
                calmonths(1):...
                datetime(fuelin.Time(end).Year,fuelin.Time(end).Month + predictedstep,1)]', ...
                'VariableNames', x.Properties.VariableNames) ;    