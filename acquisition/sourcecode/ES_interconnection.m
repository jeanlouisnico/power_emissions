function TTSync = ES_interconnection

dtLCL = datetime('now', 'TimeZone','local')       ;  
timeSpain = datetime(dtLCL, 'TimeZone', 'Europe/Madrid') ;

timearr = timeSpain ; 
outtable = struct ;
for iyear = 1:length(timearr)
    currentdate = timearr(iyear) ;
    filename = 'sunspots_annual.txt';
    websave(filename,...
            ['https://demanda.ree.es/WSvisionaMovilesPeninsulaRest/resources/demandaGeneracionPeninsula?callback=angular.callbacks._3&curva=NACIONAL&fecha=' ...
            sprintf('%02d',currentdate.Year) '-' ...
            sprintf('%02d',currentdate.Month) '-' ...
            sprintf('%02d',currentdate.Day)]) ;
    data = fileread('sunspots_annual.txt') ;
    data = erase(data,'angular.callbacks._3({"valoresHorariosGeneracion":[');
    data = split(data,'{') ;
    for itime = 1:length(data)
        datab1 = data{itime} ;
        if ~isempty(datab1)
            datab1 = erase(datab1,'}') ;
            datab2 = split(datab1,',') ;
            for itech = 1:length(datab2)
                datab3 = split(datab2{itech},':') ;
                if strcmp(datab3{1},'"ts"')
                    timevar = [datab3{2} ':' datab3{3}] ;
                    timevar = erase(timevar,'"') ;
                    try 
                        timevar = datetime(timevar,'InputFormat','yyyy-MM-dd HH:mm') ;
                    catch
                        timevar = outtable.Time(end) +  minutes(10) ;
                    end
                    if isfield(outtable, 'Time')
                        outtable.Time(end + 1,1) = timevar ;
                    else
                        outtable.Time = timevar ;
                    end
                elseif ~isempty(datab3{1})
                    varname = datab3{1} ;
                        varname = erase(varname,'"') ;
                    varvalue = str2double(datab3{2}) ;
                    if strcmp(varname,'cogenResto')
                        x = 1 ;
                    end
                    if isfield(outtable, varname)
                        outtable.(varname)(end + 1,1) = varvalue ;
                    else
                        if isfield(outtable, 'Time')
                            index = length(outtable.Time) ;
                        else
                            index = 1 ;
                        end
                        outtable.(varname)(index,1) = varvalue ;
                    end
                    
                end
            end
        end
    end
end

generation = struct2table(outtable) ;
spainTT = table2timetable(generation, 'RowTimes', generation.Time) ;
spainTT.Time = datetime(spainTT.Time, 'TimeZone', 'Europe/Madrid') ;
% writetable(generation,'2021_Spain.csv') ;
% disp('--- extraction done ---') ;

% spaindata = { 'dem'	'demand'
%                 'eol'	'wind'
%                 'nuc'	'nuclear'
%                 'gf'	'gas'
%                 'car'	'coal'
%                 'cc'	'gas_chp'
%                 'hid'	'hydro'
%                 'aut'	''
%                 'inter'	''
%                 'icb'	''
%                 'sol'	'solar'
%                 'solFot'	'solar_PV'
%                 'solTer'	'solar_ther'
%                 'termRenov'	'biomass'
%                 'cogenResto'	'waste'} ;

extractdata = {'inter'} ;

TTSync = spainTT(end, extractdata) ;

TTSync.Properties.DimensionNames{1} = 'Time' ;
TTSync.Time.TimeZone = 'Europe/Madrid' ;
TTSync.Time.TimeZone = 'UTC' ;