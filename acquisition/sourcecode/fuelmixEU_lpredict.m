function xtemp = fuelmixEU_lpredict(fuelMatrix, varargin)

 defaultresolution    = 'month' ;

   p = inputParser;
%    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0) && (mod(x,1)==0);
%    
%    validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
%    addRequired(p,'width',validScalarPosNum);
%    addOptional(p,'height',defaultHeight,validScalarPosNum);
   addParameter(p,'resolution',defaultresolution,@ischar);

   parse(p, varargin{:});
   
results = p.Results ; 

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
         switch results.resolution
             case 'month'
                timetarget = timeextract - calmonths(nyear) ;
                 if any((fuelin.Time.Year == (timetarget.Year) & fuelin.Time.Month == timetarget.Month) )
                     n = 1;
                     predictedstep = nyear ;
        %              findrow = (Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) ;
                 end
             case 'year'
                timetarget = timeextract - calyears(nyear) ;
                if any(fuelin.Time.Year == (timetarget.Year))
                     n = 1;
                     predictedstep = nyear ;
        %              findrow = (Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) ;
                end
             otherwise
                timetarget = timeextract - calmonths(nyear) ;
                if any((fuelin.Time.Year == (timetarget.Year) & fuelin.Time.Month == timetarget.Month) )
                     n = 1;
                     predictedstep = nyear ;
        %              findrow = (Fueluse.chp.Year == (timetarget.Year) & Fueluse.chp.Month == timetarget.Month) ;
                end
         end
         

    end
    
x = fuelin ;
    [y, ~] = lpredict(x.Variables, 14, predictedstep, 'post') ; % the rank 14 has been found to give the most accruate results
    xtemp = [x.Variables;y] ;
    
    switch results.resolution
        case 'month'
            timearray = [datetime(fuelin.Time(1).Year,fuelin.Time(1).Month,1):...
                            calmonths(1):...
                            datetime(fuelin.Time(end).Year,fuelin.Time(end).Month + predictedstep,1)]' ;
        case 'year'
            timearray = [datetime(fuelin.Time(1).Year,fuelin.Time(1).Month,1):...
                            calyears(1):...
                            datetime(fuelin.Time(end).Year + predictedstep,1,1)]' ;
        otherwise
            timearray = [datetime(fuelin.Time(1).Year,fuelin.Time(1).Month,1):...
                            calmonths(1):...
                            datetime(fuelin.Time(end).Year,fuelin.Time(end).Month + predictedstep,1)]' ;
    end

    xtemp = array2timetable(xtemp, "RowTimes",...
                timearray, ...
                'VariableNames', x.Properties.VariableNames) ;    