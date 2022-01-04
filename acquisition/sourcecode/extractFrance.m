function power = extractFrance

currenttime = javaObject("java.util.Date") ;
timezone = -currenttime.getTimezoneOffset()/60 ;
timeextract = datetime(datetime(datestr(now)) - hours(timezone)) - hours(2) ;

startingdate = [sprintf('%02d',timeextract.Year) '-' ...
                sprintf('%02d',timeextract.Month) '-' ...
                sprintf('%02d',timeextract.Day) 'T' ...
                sprintf('%02d',timeextract.Hour) '%3A' ...
                sprintf('%02d',timeextract.Minute) '%3A' ...
                sprintf('%02d',timeextract.Second) 'Z'] ;
            
timeextract = datetime(datetime(datestr(now)) - hours(timezone)) ;

endingdate = [sprintf('%02d',timeextract.Year) '-' ...
                sprintf('%02d',timeextract.Month) '-' ...
                sprintf('%02d',timeextract.Day) 'T' ...
                sprintf('%02d',timeextract.Hour) '%3A' ...
                sprintf('%02d',timeextract.Minute) '%3A' ...
                sprintf('%02d',timeextract.Second) 'Z'] ;

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

while n == 0
    if isfield(data.records(loopstart).fields, 'nucleaire')
        powerdata = data.records(loopstart).fields ;
        n = 1 ;
    else
        loopstart = loopstart - 1 ;
        if loopstart <= 0
            warning('did not find data') ;
            powerdata = 0 ;
            n = 1 ;
        end
    end
end
if isa(powerdata, 'struct')
    powerdata = struct2table(powerdata) ;
    fueldata = {'hydraulique_step_turbinage' 'hydropumped'
                'hydraulique_lacs' 'hydrodam'
                'eolien' 'wind'
                'hydraulique' 'hydro'
                'solaire' 'solar'
                'fioul_autres' 'oil'
                'nucleaire' 'nuclear'
                'gaz_tac'  'gas'
                'fioul'    'oil'
                'pompage' 'hydropumped'
                'gaz' 'gas'
                'gaz_cogen' 'gas_chp'
                'fioul_cogen' 'oil_chp'
                'bioenergies_biomasse' 'biomass'
                'bioenergies_dechets'  'waste'
                'gaz_autres' 'gas'
                'hydraulique_fil_eau_eclusee' 'hydro'
                'bioenergies_biogaz' 'biogas'
                'bioenergies' 'biomass'
                'gaz_ccg'  'gas'
                'charbon' 'coal'
                'fioul_tac' 'oil'
                'consommation' 'consumption'
                'ech_comm_angleterre' 'TradeEngland'
                'ech_comm_italie' 'TradeItaly'
                'ech_comm_suisse' 'TradeSwiss'
                'ech_comm_allemagne_belgique' 'TradeBelgGerm'
                'ech_comm_espagne' 'TradeSpain'
                } ;
    
    AllVar = unique(fueldata(:,2)) ;        
            
    for ivar = 1:length(AllVar)
        getdata = AllVar{ivar} ;
        try
            power.(getdata) = sum(powerdata(1,fueldata(contains(fueldata(:,2), getdata),1)').Variables) ;
        catch
            continue;
        end
    end
else
    power = 0 ;
end
