function TTSync = HU
warning('OFF', 'all' )
currenttime = javaObject("java.util.Date") ;
timezone    = -currenttime.getTimezoneOffset()/60 ;
d1 = datetime(now, 'ConvertFrom', 'datenum','TimeZone',['+0' num2str(timezone) ':00']);


timestart   = posixtime(datetime(now, 'ConvertFrom', 'datenum','TimeZone',['+0' num2str(timezone) ':00'])  - hours(1)) * 1000;
timeend     = posixtime(d1) * 1000 ;

code.loadcode = 7678 ;
code.Xchangecode = 5229 ;
code.solarcode = 11838 ;
code.windcode = 11840 ;
code.PPgen = 4401 ;
% code.systemdata = 10260 ;

allfields = fieldnames(code) ;
outputtable = [] ;
for icode = 1 : length(allfields)
    col = {} ;
    url_load = ['https://www.mavir.hu/rtdwweb/webuser/chart/' num2str(code.(allfields{icode})) ...
                '/export?exportType=xlsx&fromTime=' ...
                 num2str(floor(timestart)) '&toTime='...
                 num2str(floor(timeend)) '&periodType=min&period=15'] ;
    try
        websave('tempHU.xlsx',url_load) ;
        opt=detectImportOptions('tempHU.xlsx');
    catch
        opt=detectImportOptions('tempHU.xlsx');
    end
    try
        powerHR.(allfields{icode}) = readtable('tempHU.xlsx', opt) ;
    catch
        TTSync = 0 ;
        return ;
    end
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
    else
        for icol = 1:length(col)
            outputtable = addvars(outputtable, powerHR.(allfields{icode}).(col{icol}),  'NewVariableNames',colname(icol)) ;
        end
    end
    pause(2) ;
end

elecfuel = retrieveEF ;
[alldata, ~] = fuelmixEU('Hungary', false, 'absolute') ;

genlist = {'CF_R' 'C0000' 'CF_NR' 'G3000' 'O4000XBIO' 'RA110' 'RA120' 'RA130' 'RA200' 'RA500_5160' 'N9000' 'X9900'} ;

predictedfuel = fuelmixEU_lpredict(alldata.HU) ;
normalisedpredict = array2timetable(bsxfun(@rdivide, predictedfuel(:,genlist).Variables, sum(predictedfuel(:,genlist).Variables,2, 'omitnan')) * 100, "RowTimes", predictedfuel.Time, 'VariableNames', genlist) ;

genbyfuel = outputtable.generation .* normalisedpredict(end,:).Variables/100 ;

genbyfuel = array2timetable(genbyfuel, "RowTimes", outputtable.dates, "VariableNames", genlist) ;

% Get the last valid entry
nentry = 0 ;
entrynan = isnan(genbyfuel.Variables) ;
irow = size(entrynan,1) ;

while nentry == 0
    totalNAN = sum(entrynan(irow,:)) ;
    if totalNAN < length(genlist)
        genbyfuel_extract = genbyfuel(irow,:) ;
        nentry = 1;
    else
        irow = irow - 1 ;
    end
end

replacestring = cellfun(@(x) elecfuel(strcmp(elecfuel(:,1),x),2), genlist, 'UniformOutput', false) ;
genbyfuel_extract.Properties.VariableNames = cat(1, replacestring{:}) ;
genbyfuel_extract = addvars(genbyfuel_extract, outputtable.solar(3), 'NewVariableNames',{'solar'}) ;
genbyfuel_extract = addvars(genbyfuel_extract, outputtable.wind(3), 'NewVariableNames',{'wind'}) ;

TTSync.emissionskit = genbyfuel_extract ;

changefuel = {  'biomass'	'biomass'
                'coal'	'coal_chp'
                'unknown'	'unknown'
                'gas'	'gas'
                'oil'	'oil'
                'hydro_reservoir'	'hydro_reservoir'
                'hydro_runof'	'hydro_runof'
                'hydro_pumped'	'hydro_pumped'
                'geothermal'	'geothermal'
                'other_biogas'	'other_biogas'
                'nuclear_PWR'	'nuclear_PWR'
                'waste'	'waste'
                'solar'	'solar'
                'wind'	'windon' } ;

replacestring = cellfun(@(x) changefuel(strcmp(changefuel(:,1),x),2), TTSync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTSync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

TTSync.TSO = outputtable(irow,{'generation' 'load' 'solar' 'wind'}) ;
TTSync.TSO.Properties.VariableNames = {'production' 'consumption' 'solar' 'wind'} ;
% allgen = addvars(allgen, sum(allgen.Variables, 'omitnan'), 'NewVariableNames','total') ;
%% estimate the current mix by extrapolating the data
warning('ON', 'all' )

end