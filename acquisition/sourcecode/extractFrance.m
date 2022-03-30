function [power, PXchange] = extractFrance

% currenttime = javaObject("java.util.Date") ;
% timezone = -currenttime.getTimezoneOffset()/60 ;
fueldata = {'hydraulique_step_turbinage' 'hydro_pumped' 1 0
            'hydraulique_lacs' 'hydro_reservoir' 1 0
            'eolien' 'windon' 1 0
            'hydraulique' 'hydro' 0 0
            'solaire' 'solar' 1 0
            'fioul_autres' 'oil' 1 0
            'nucleaire' 'nuclear' 1 0
            'gaz_tac'  'gas' 1 0
            'fioul'    'oil' 0 0
            'pompage' 'hydro_pumped' 1 0
            'gaz' 'gas' 0 0
            'gaz_cogen' 'gas_chp' 1 0
            'fioul_cogen' 'oil_chp' 1 0
            'bioenergies_biomasse' 'biomass' 1 0
            'bioenergies_dechets'  'waste' 1 0
            'gaz_autres' 'gas' 1 0
            'hydraulique_fil_eau_eclusee' 'hydro_runof' 1 0
            'bioenergies_biogaz' 'other_biogas' 1 0
            'bioenergies' 'biomass' 0 0
            'gaz_ccg'  'gas_chp' 1 0
            'charbon' 'coal' 1 0
            'fioul_tac' 'oil' 1 0
            'consommation' 'consumption' 0 0
            'ech_comm_angleterre' 'GB' 0 1
            'ech_comm_italie' 'IT' 0 1
            'ech_comm_suisse' 'CH' 0 1
            'ech_comm_allemagne_belgique' 'DE' 0  1
            'ech_comm_espagne' 'ES' 0 1
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
    if data.nhits == 0
        power = 0;
        PXchange = 0 ;
        return ;
    end
catch
    power = 0 ;
    PXchange = 0 ;
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
            if any(contains(fueldata(:,2), getdata) & ([fueldata{:,3}] == 1)')
                power.(getdata) = sum(powerdata(1,fueldata(ismember(fueldata(:,2), getdata) & ([fueldata{:,3}] == 1)',1)').Variables) ;
            end
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
            if any(contains(fueldata(:,2), getdata) & ([fueldata{:,4}] == 1)')
                PXchange.(getdata) = sum(powerXchange(1,fueldata(contains(fueldata(:,2), getdata)& ([fueldata{:,4}] == 1)',1)').Variables) ;
            end
        catch
            continue;
        end
    end
    powetemp = struct2table(PXchange) ;
    PXchange = table2timetable(powetemp,'RowTimes',datetime(currenttime,'TimeZone','UTC')) ;
else
    PXchange = 0 ;
end

