function TTSync = HU_exchange
warning('OFF', 'all' )
currenttime = javaObject("java.util.Date") ;
timezone    = -currenttime.getTimezoneOffset()/60 ;
d1 = datetime(now, 'ConvertFrom', 'datenum','TimeZone',['+0' num2str(timezone) ':00']);


timestart   = posixtime(datetime(now, 'ConvertFrom', 'datenum','TimeZone',['+0' num2str(timezone) ':00'])  - hours(1)) * 1000;
timeend     = posixtime(d1) * 1000 ;

code.Xchangecode = 5229 ;
% code.systemdata = 10260 ;

allfields = fieldnames(code) ;
outputtable = [] ;
for icode = 1 : length(allfields)
    col = {} ;
    url_load = ['https://www.mavir.hu/rtdwweb/webuser/chart/' num2str(code.(allfields{icode})) ...
                '/export?exportType=xlsx&fromTime=' ...
                 num2str(floor(timestart)) '&toTime='...
                 num2str(floor(timeend)) '&periodType=min&period=15'] ;
    websave('tempHU.xlsx',url_load) ;
    opt=detectImportOptions('tempHU.xlsx');
    powerHR.(allfields{icode}) = readtable('tempHU.xlsx', opt) ;

    dates = datetime(powerHR.(allfields{icode}).Id_pont,'InputFormat','uuuu.MM.dd HH:mm:ss Z', 'TimeZone', 'Europe/Budapest') ;
   
    switch allfields{icode}
        case 'loadcode'
            col{1} = 'Nett_Terhel_s' ;
            colname{1} = 'load' ;
        case 'Xchangecode'
            col{1} = 'HU_SK' ;
            col{2} = 'HU_AT' ;
            col{3} = 'HU_HR' ;
            col{4} = 'HU_RO' ;
            col{5} = 'HU_RS' ;
            col{6} = 'HU_UK' ;
            colname{1} = 'HU_SK' ;
            colname{2} = 'HU_AT' ;
            colname{3} = 'HU_HR' ;
            colname{4} = 'HU_RO' ;
            colname{5} = 'HU_RS' ;
            colname{6} = 'HU_UK' ;
        case 'solarcode'
            col{1} = 'Naper_m_vekBecs_ltTermel_se_aktu_lis_' ;
            colname{1} = 'solar' ;
        case 'windcode'
            col{1} = 'Id_j_r_sf_gg_Termel_k_sz_ler_m_vek_T_ny' ;
            colname{1} = 'wind' ;
        case 'PPgen'
            col{1} = 'Brutt_T_nyEr_m_viTermel_s' ;
            colname{1} = 'generation' ;
        case 'systemdata'
            col{1} = '' ;
            colname{1} = 'system' ;
    end
    
    if isempty(outputtable)
        outputtable = timetable(dates,powerHR.(allfields{icode}).(col{1}), 'VariableNames',colname(1)) ; 
        for icol = 2:length(col)
            outputtable = addvars(outputtable, powerHR.(allfields{icode}).(col{icol}),  'NewVariableNames',colname(icol)) ;
        end
    else
        for icol = 1:length(col)
            outputtable = addvars(outputtable, powerHR.(allfields{icode}).(col{icol}),  'NewVariableNames',colname(icol)) ;
        end
    end
    if icode<length(allfields)
        pause(2) ;
    end
end

A = outputtable.Variables ;
B = ~isnan(A);
% indices
Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:size(A, 2));
% values
Values = arrayfun(@(x,y) A(x,y), Indices, 1:size(A, 2));

TTSync = array2timetable(Values,'RowTimes',outputtable.dates(Indices(1))) ;

equivalentname = {'HU_SK'	 'SK'
                  'HU_AT'	'AT' 
                  'HU_HR'	'HR'
                  'HU_RO'	'RO'
                  'HU_RS'	'RS'
                  'HU_UK'	 'UA'} ;

replacestring = cellfun(@(x) equivalentname(strcmp(equivalentname(:,1),x),2), outputtable.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.Properties.VariableNames = cat(1, replacestring{:}) ;



