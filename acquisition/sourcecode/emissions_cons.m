function Emissions = emissions_cons

tes = load("testing_xchangev2.mat") ;
Country = country2fetch ;
p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-2), filesep) ;
country_code = countrycode(Country) ;
Power = tes.Power ; 
Emissions = tes.Emissions ;
Xchnage = jsondecode(fileread([fparts{1} filesep 'Xchange.json']));  

Source = {'IPCC'
          'EcoInvent'} ;
FIsource = {'ENTSOE'
            'TSO'} ;
Emissionsdatabase = load_emissions      ;    
for ipower = 1:length(FIsource)
    SourceFI = FIsource{ipower} ;
    for iEFSource = 1:length(Source)
        EFSource = Source{iEFSource} ;
        %%% Loop until the standard deviation for each country is less than
        %%% X
        devtraget = 15 ;
        devcheck = true ;
        while devcheck
            for icountry = 1:length(Country)
                if icountry == 23
                    x = 1 ;
                end
                getcountry = ismember({Power.zone},country_code.alpha2{icountry}) ;
                switch SourceFI
                    case 'ENTSOE'
                        XChange_country = Xchnage.(country_code.alpha2{icountry}) ;
                        [emend, Emissions] = extractENTSOExchange(XChange_country, Emissions, country_code, SourceFI, EFSource, icountry,Emissionsdatabase.(EFSource)) ;
                        if isa(Power(getcountry).(SourceFI).bytech.(country_code.alpha2{icountry}), 'double')
                            if isa(Power(getcountry).(SourceFI).TotalConsumption.(country_code.alpha2{icountry}),'double')
                                totprod = Power(getcountry).(SourceFI).TotalConsumption.(country_code.alpha2{icountry}) ;
                            else
                                totprod = Power(getcountry).(SourceFI).TotalConsumption.(country_code.alpha2{icountry}).Variables ;
                            end
                        else
                            totprod = sum(Power(getcountry).(SourceFI).bytech.(country_code.alpha2{icountry}).Variables) ;
                        end
                        if isa(XChange_country, 'table')
                            XChange_country = removevars(XChange_country, 'Time') ;
                        else
                            XChange_country = rmfield(XChange_country, 'Time') ;
                        end
                        
                        totexch = sum(struct2array(XChange_country)) ;
                        
                        Load = totprod + totexch ;
                        if emend < 0
                            emend = 0 ;
                        end
                        if isfield(Emissions.(country_code.alpha2{icountry}).(SourceFI).(EFSource),'intensitycons')
                            dev.(country_code.alpha2{icountry}).IC_before = Emissions.(country_code.alpha2{icountry}).(SourceFI).(EFSource).intensitycons ;
                        else
                            dev.(country_code.alpha2{icountry}).IC_before = Emissions.(country_code.alpha2{icountry}).(SourceFI).(EFSource).intensityprod ;
                        end
                        if Load<0
                            Emissions.(country_code.alpha2{icountry}).(SourceFI).(EFSource).intensitycons = 0 ;
                        else
                            Emissions.(country_code.alpha2{icountry}).(SourceFI).(EFSource).intensitycons = emend/Load ;
                        end
                            
                        p  = [dev.(country_code.alpha2{icountry}).IC_before Emissions.(country_code.alpha2{icountry}).(SourceFI).(EFSource).intensitycons] ;
    
                        dev.(country_code.alpha2{icountry}).value = std(p) ;
                        if ~isempty(p)
                            devsummary(icountry) = std(p) ;
                        else
                            devsummary(icountry) = 0 ;
                        end
                    case 'TSO'
                        if isa(Power(getcountry).xCHANGE,"double")
                            % This means that there are no data from the TSO,
                            % use the data from ENTSOE
                            XChange_country = Xchnage.(country_code.alpha2{icountry}) ;
                            [emend, Emissions] = extractENTSOExchange(XChange_country, Emissions, country_code, SourceFI, EFSource, icountry,Emissionsdatabase.(EFSource)) ;
                        else
                            XChange_country = Power(getcountry).xCHANGE ;
                            [emend, Emissions] = extractENTSOExchange(XChange_country, Emissions, country_code, SourceFI, EFSource, icountry,Emissionsdatabase.(EFSource)) ;
                        end
                        
                        % Get the total power produced from within the country
                        if isa(Power(getcountry).(SourceFI),'double')
                            % This means that there is no data for EK, so must
                            % take the data from ENTSOE
                            if isa(Power(getcountry).ENTSOE.bytech.(country_code.alpha2{icountry}), 'double')
                                totprod = 0 ;
                            else
                                totprod = sum(Power(getcountry).ENTSOE.bytech.(country_code.alpha2{icountry}).Variables) ;
                            end
                        else
                            if isa(Power(getcountry).(SourceFI).emissionskit,'double')
                                totprod = sum(Power(getcountry).(SourceFI).emissionskit) ;
                            else
                                totprod = sum(Power(getcountry).(SourceFI).emissionskit.Variables) ;
                            end
                        end
                        if isa(XChange_country, 'struct')
                            XChange_country = rmfield(XChange_country, 'Time') ;
                            totexch = sum(struct2array(XChange_country)) ;
                        elseif isa(XChange_country, 'table')
                            totexch = sum(XChange_country.Variables) ;                        
                        elseif isa(XChange_country, 'timetable')
                            totexch = sum(XChange_country.Variables) ;        
                        end
    
                        Load = totprod + totexch ;
                        if emend < 0
                            emend = 0 ;
                        end
                        Emissions.(country_code.alpha2{icountry}).(SourceFI).(EFSource).intensitycons = emend/Load ;
                end
            end
            devcheck = any(devsummary>devtraget) ;
            bar(devsummary)
        end
    end
end

    function [emend, Emissions] = extractENTSOExchange(inputstruct,  Emissions, country_code, SourceFI, EFSource, icountry, Emissionsdatabase)
        if isa(inputstruct, 'struct')
            geteach = fieldnames(inputstruct) ;
        elseif isa(inputstruct, 'table')
            geteach = inputstruct.Properties.VariableNames ;
        elseif isa(inputstruct, 'timetable')
            geteach = inputstruct.Properties.VariableNames ;
        end
        switch SourceFI
            case 'TSO'
                source = 'emissionskit' ;
            otherwise
                source = SourceFI ;
        end
        
        if ~isfield(Emissions.(country_code.alpha2{icountry}), source)
            Emissions.(country_code.alpha2{icountry}).(source).EcoInvent.intensityprod = ...
                            Emissions.(country_code.alpha2{icountry}).ENTSOE.EcoInvent.intensityprod ;
            Emissions.(country_code.alpha2{icountry}).(source).EcoInvent.total = ...
                            Emissions.(country_code.alpha2{icountry}).ENTSOE.EcoInvent.total ;
            Emissions.(country_code.alpha2{icountry}).(source).IPCC.intensityprod = ...
                            Emissions.(country_code.alpha2{icountry}).ENTSOE.IPCC.intensityprod ;
            Emissions.(country_code.alpha2{icountry}).(source).IPCC.total = ...
                            Emissions.(country_code.alpha2{icountry}).ENTSOE.IPCC.total ;
        end

        emend = Emissions.(country_code.alpha2{icountry}).(source).(EFSource).total ;

        EmissionsCategory = 'GlobalWarming' ;
        for each = 1:length(geteach)
            switch geteach{each}
                case {'Time','Su'}
                otherwise
                    getcounty = split(geteach{each},'_') ;
                    ccode = getcounty{1} ;
                    ccode = ccode(1:2) ; % --> this is to make sure that only the first 2 letters are considered
                    %%% Negative is export to the country
                    if inputstruct.(geteach{each}) < 0
                        if isfield(Emissions.(country_code.alpha2{icountry}).(source).(EFSource), 'intensitycons')
                            emend = emend + (inputstruct.(geteach{each}) * Emissions.(country_code.alpha2{icountry}).(source).(EFSource).intensitycons);
                        else
                            emend = emend + (inputstruct.(geteach{each}) * Emissions.(country_code.alpha2{icountry}).(source).(EFSource).intensityprod);
                        end
                    %%% Positive is import from the country
                    elseif inputstruct.(geteach{each}) > 0
                        % Check if the country exist
                        if isfield(Emissions,ccode)
                            % Check if the DB exist
                            if isfield(Emissions.(ccode), source)
                                emend = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, ccode, source) ;
                            else
                                switch source
                                    case 'emissionskit'
                                        Emissions.(ccode).(source).EcoInvent.intensityprod = Emissions.(ccode).ENTSOE.EcoInvent.intensityprod ;
                                        Emissions.(ccode).(source).EcoInvent.total = Emissions.(ccode).ENTSOE.EcoInvent.total ;
                                        Emissions.(ccode).(source).IPCC.intensityprod = Emissions.(ccode).ENTSOE.IPCC.intensityprod ;
                                        Emissions.(ccode).(source).IPCC.total = Emissions.(ccode).ENTSOE.IPCC.total ;
                                        emend = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, ccode, source) ;
                                    case 'ENTSOE'
    
                                    otherwise
    
                                end
    
                            end
                        else
                            Emissionsextract = Emissionsdatabase.(EmissionsCategory)(strcmp(Emissionsdatabase.Technology,'mean') & strcmp(Emissionsdatabase.Country,ccode)) ;
                            if isempty(Emissionsextract)
                                switch ccode
                                    case 'AX'
                                        emend = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'FI', source) ;
                                    case {'TR' 'AL'}
                                        emend = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'EL', source) ;
                                    case {'UA' 'BY'}
                                        emend = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'RU', source) ;
                                    case 'KX'
                                        emend = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'ME', source) ;
                                    otherwise                                  
                                        
                                end
                            else
                                emend = emend + (inputstruct.(geteach{each}) * Emissionsextract) ;
                            end
                        end
                    else
    
                    end
            end
        end
        Emissions.(country_code.alpha2{icountry}).(source).(EFSource).total = emend;
    end
    %%%%%%%%%%%%%% SETUP EMISSIONKIT IF MISSING %%%%%%%%%%%%%%%%%%%%%%% 
    function setupEK
        
    end

    function emend = getemissions(inputstruct, Emissions, EFSource, emend, geteach, ccode, source)
        if isfield(Emissions.(ccode).(source).(EFSource), 'intensitycons')
            if isempty(Emissions.(ccode).(source).(EFSource).intensitycons) || isnan(Emissions.(ccode).(source).(EFSource).intensitycons)
                emmult = 0 ;
            else
                emmult = Emissions.(ccode).(source).(EFSource).intensitycons ;                
            end
            emend = emend + (inputstruct.(geteach) * emmult);
        else
            if isempty(Emissions.(ccode).(source).(EFSource).intensityprod) ||  isnan(Emissions.(ccode).(source).(EFSource).intensityprod)
                emmult = 0 ;
            else
                emmult = Emissions.(ccode).(source).(EFSource).intensityprod ;                
            end
            emend = emend + (inputstruct.(geteach) * emmult);
        end  
    end

end
