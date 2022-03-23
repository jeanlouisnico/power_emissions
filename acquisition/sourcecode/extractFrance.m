function [power, PXchange] = extractFrance

% currenttime = javaObject("java.util.Date") ;
% timezone = -currenttime.getTimezoneOffset()/60 ;
fueldata = {'hydraulique_step_turbinage' 'hydro_pumped'
                'hydraulique_lacs' 'hydro_reservoir'
                'eolien' 'windon'
                'hydraulique' 'hydro'
                'solaire' 'solar'
                'fioul_autres' 'oil'
                'nucleaire' 'nuclear'
                'gaz_tac'  'gas'
                'fioul'    'oil'
                'pompage' 'hydro_pumped'
                'gaz' 'gas'
                'gaz_cogen' 'gas_chp'
                'fioul_cogen' 'oil_chp'
                'bioenergies_biomasse' 'biomass'
                'bioenergies_dechets'  'waste'
                'gaz_autres' 'gas'
                'hydraulique_fil_eau_eclusee' 'hydro_runof'
                'bioenergies_biogaz' 'other_biogas'
                'bioenergies' 'biomass'
                'gaz_ccg'  'gas_chp'
                'charbon' 'coal'
                'fioul_tac' 'oil'
                'consommation' 'consumption'
                'ech_comm_angleterre' 'GB'
                'ech_comm_italie' 'IT'
                'ech_comm_suisse' 'CH'
                'ech_comm_allemagne_belgique' 'DE'
                'ech_comm_espagne' 'ES'
                } ;


currenttime = datetime('now', 'TimeZone','local') ;
timeextract = datetime(currenttime,'TimeZone','UTC') - hours(2);
% timeextract = datetime(datetime(datestr(now)) - hours(timezone)) - hours(2) ;

startingdate = [sprintf('%02d',timeextract.Year) '-' ...
                sprintf('%02d',timeextract.Month) '-' ...
                sprintf('%02d',timeextract.Day) 'T' ...
                sprintf('%02d',timeextract.Hour) '%3A' ...
                sprintf('%02d',timeextract.Minute) '%3A' ...
                sprintf('%02d',round(timeextract.Second,0)) 'Z'] ;
            
timeextract = datetime(currenttime,'TimeZone','UTC');

endingdate = [sprintf('%02d',timeextract.Year) '-' ...
                sprintf('%02d',timeextract.Month) '-' ...
                sprintf('%02d',timeextract.Day) 'T' ...
                sprintf('%02d',timeextract.Hour) '%3A' ...
                sprintf('%02d',timeextract.Minute) '%3A' ...
                sprintf('%02d',round(timeextract.Second,0)) 'Z'] ;

url = ['https://opendata.reseaux-energies.fr/api/records/1.0/search/?dataset=eco2mix-national-tr&q=date_heure%3A%5B' ...
        startingdate '+TO+' ...
        endingdate ...
        '%5D&rows=500&sort=-date_heure&facet=nature&facet=date_heure'] ;
try
    data = webread(url) ;
catch
    power = 0 ;
    return;
end
n = 0 ;
loopstart = size(data.records, 1) ;
powerdata = [] ;
powerXchange = [] ;
while n == 0
    if isfield(data.records(loopstart).fields, 'nucleaire')  && isempty(powerdata)
        powerdata = data.records(loopstart).fields ;
        if ~isempty(powerXchange)
            n = 1 ;
        else
            loopstart = loopstart - 1 ;    
        end
    elseif isfield(data.records(loopstart).fields, 'ech_comm_espagne') && isempty(powerXchange)
        powerXchange = data.records(loopstart).fields ;
        if ~isempty(powerdata)
            n = 1 ;
        else
            loopstart = loopstart - 1 ;
        end
    else
        loopstart = loopstart - 1 ;
        if loopstart <= 0
            warning('did not find data') 
            if isempty(powerdata)
                powerdata = 0 ;
            end
            if isempty(powerXchange)
                powerXchange = 0 ;
            end
            n = 1 ;
        end
    end
end
if isa(powerdata, 'struct')
    powerdata = struct2table(powerdata) ;
    AllVar = unique(fueldata(:,2)) ;          
    for ivar = 1:length(AllVar)
        getdata = AllVar{ivar} ;
        try
            power.(getdata) = sum(powerdata(1,fueldata(contains(fueldata(:,2), getdata),1)').Variables) ;
        catch
            continue;
        end
    end
    powetemp = struct2table(power) ;
    power = table2timetable(powetemp,'RowTimes',datetime(currenttime,'TimeZone','UTC')) ;
else
    power = 0 ;
end

if isa(powerXchange, 'struct')
    powerXchange = struct2table(powerXchange) ;
    AllVar = unique(fueldata(:,2)) ;          
    for ivar = 1:length(AllVar)
        getdata = AllVar{ivar} ;
        try
            PXchange.(getdata) = sum(powerXchange(1,fueldata(contains(fueldata(:,2), getdata),1)').Variables) ;
        catch
            continue;
        end
    end
    powetemp = struct2table(PXchange) ;
    PXchange = table2timetable(powetemp,'RowTimes',datetime(currenttime,'TimeZone','UTC')) ;
else
    PXchange = 0 ;
end

