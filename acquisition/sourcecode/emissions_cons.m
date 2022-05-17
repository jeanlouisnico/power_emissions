function [Emissions, track] = emissions_cons(varargin)

if nargin > 1
    defaultPower     = struct ;     
    defaultEmissions = struct ;
    
    p = inputParser;
    
    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0) && (mod(x,1)==0);
    validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
    validstring = @(x) isstring(x) || ischar(x) ;
    
    addParameter(p,'power',defaultPower, @isstruct);
    addParameter(p,'emissions',defaultEmissions, @isstruct);
    
    parse(p, varargin{:});
    
    results = p.Results ;

    Power = results.power ; 
    Emissions = results.emissions ;
else
    tes = load("testing_xchangev2.mat") ;
    Power = tes.Power ; 
    Emissions = tes.Emissions ;
end
% Country = country2fetch ;
p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-2), filesep) ;
% country_code = countrycode(Country) ;

Xchnage = jsondecode(fileread([fparts{1} filesep 'Xchange.json']));  

country_codein = {Power(:).zone}';

Source = {'IPCC'
          'EcoInvent'} ;
FIsource = {'ENTSOE'
            'TSO'} ;
Emissionsdatabase = load_emissions      ;    
devsummary = ones(1,length(country_codein)) * 100 ;
for ipower = 1:length(FIsource)
    SourceFI = FIsource{ipower} ;
    for iEFSource = 1:length(Source)
        EFSource = Source{iEFSource} ;
        %%% Loop until the standard deviation for each country is less than
        %%% X
        devtraget = 5 ;
        devcheck = true ;
        loopcount = 0  ;
        while devcheck && loopcount<100
            loopcount = loopcount + 1 ;
            for icountry = 1:length(country_codein)
                country_code = country_codein{icountry} ;
%                 if devsummary(icountry) < devtraget
%                     continue;
%                 end
                if icountry == 21
                    x = 1 ;
                end
                getcountry = ismember({Power.zone},country_code) ;
                switch FIsource{ipower}
                    case 'ENTSOE'
                        XChange_country = Xchnage.(country_code) ;
                        [emend, Emissions] = extractENTSOExchange(XChange_country, Emissions, country_code, SourceFI, EFSource, Emissionsdatabase, loopcount) ;
                        if isa(Power(getcountry).(SourceFI).bytech.(country_code), 'double')
                            if isa(Power(getcountry).(SourceFI).TotalConsumption.(country_code),'double')
                                totprod = Power(getcountry).(SourceFI).TotalConsumption.(country_code) ;
                            else
                                totprod = Power(getcountry).(SourceFI).TotalConsumption.(country_code).Variables ;
                            end
                        else
                            totprod = sum(Power(getcountry).(SourceFI).bytech.(country_code).Variables) ;
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
                        if isfield(Emissions.(country_code).(SourceFI).(EFSource),'intensitycons')
                            dev.(country_code).previous = Emissions.(country_code).(SourceFI).(EFSource).currentloopintensitycons ;
                        else
                            dev.(country_code).previous = Emissions.(country_code).(SourceFI).(EFSource).intensityprod ;
                        end
                        if Load < 0 || totprod == 0
                            Emissions.(country_code).(SourceFI).(EFSource).intensitycons = extractdata('mean', country_code, 'GlobalWarming', Emissionsdatabase.EcoInvent) ;
                        else
                            Emissions.(country_code).(SourceFI).(EFSource).intensitycons = emend/Load ;
                            Emissions.(country_code).(SourceFI).(EFSource).total = emend/Load * totprod;
                        end
                        
                        track.(country_code).(SourceFI).(EFSource)(loopcount) = Emissions.(country_code).(SourceFI).(EFSource).intensitycons ;

                        p  = [dev.(country_code).previous Emissions.(country_code).(SourceFI).(EFSource).intensitycons] ;
    
                        dev.(country_code).value = std(p) ;
                        if ~isempty(p)
                            devsummary(icountry) = std(p) ;
                        else
                            devsummary(icountry) = 0 ;
                        end
                    case 'TSO'
                        SourceFIP = FIsource{ipower} ;
                        SourceFI  = 'emissionskit' ;
                        if isa(Power(getcountry).xCHANGE,"double")
                            % This means that there are no data from the TSO,
                            % use the data from ENTSOE
                            XChange_country = Xchnage.(country_code) ;
                            [emend, Emissions] = extractENTSOExchange(XChange_country, Emissions, country_code, SourceFIP, EFSource, Emissionsdatabase, loopcount) ;
                        else
                            XChange_country = Power(getcountry).xCHANGE ;
                            [emend, Emissions] = extractENTSOExchange(XChange_country, Emissions, country_code, SourceFIP, EFSource, Emissionsdatabase, loopcount) ;
                        end
                        
                        % Get the total power produced from within the country
                        if isa(Power(getcountry).(SourceFIP),'double')
                            % This means that there is no data for EK, so must
                            % take the data from ENTSOE
                            if isa(Power(getcountry).ENTSOE.bytech.(country_code), 'double')
                                if isa(Power(getcountry).ENTSOE.TotalConsumption.(country_code),'double')
                                    totprod = Power(getcountry).ENTSOE.TotalConsumption.(country_code) ;
                                else
                                    totprod = Power(getcountry).ENTSOE.TotalConsumption.(country_code).Variables ;
                                end
                            else
                                totprod = sum(Power(getcountry).ENTSOE.bytech.(country_code).Variables) ;
                            end
                        else
                            if isa(Power(getcountry).(SourceFIP).emissionskit,'double')
                                totprod = sum(Power(getcountry).(SourceFIP).emissionskit) ;
                            else
                                totprod = sum(Power(getcountry).(SourceFIP).emissionskit.Variables) ;
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

                        if isfield(Emissions.(country_code).(SourceFI).(EFSource),'intensitycons')
                            dev.(country_code).previous = Emissions.(country_code).(SourceFI).(EFSource).currentloopintensitycons ;
                        else
                            dev.(country_code).previous = Emissions.(country_code).(SourceFI).(EFSource).intensityprod ;
                        end
                        if Load < 0 || totprod == 0
                            Emissions.(country_code).(SourceFI).(EFSource).intensitycons = extractdata('mean', country_code, 'GlobalWarming', Emissionsdatabase.EcoInvent) ;
                        else
                            Emissions.(country_code).(SourceFI).(EFSource).intensitycons = emend/Load ;
                            Emissions.(country_code).(SourceFI).(EFSource).total = emend/Load * totprod;
                        end

                        track.(country_code).(SourceFI).(EFSource)(loopcount) = Emissions.(country_code).(SourceFI).(EFSource).intensitycons ;

                        p  = [dev.(country_code).previous Emissions.(country_code).(SourceFI).(EFSource).intensitycons] ;
    
                        dev.(country_code).value = std(p) ;
                        if ~isempty(p)
                            devsummary(icountry) = std(p) ;
                        else
                            devsummary(icountry) = 0 ;
                        end
                end
            end
            % Once all the countries have been gatherd, we can re-allocate
            % the new emission intensity to the new slot to consider them
            % in the next iteration.

            for icountry = 1:length(country_codein)
                country_code = country_codein{icountry} ;
                Emissions.(country_code).(SourceFI).(EFSource).currentloopintensitycons = Emissions.(country_code).(SourceFI).(EFSource).intensitycons ;
            end

            devcheck = any(devsummary>devtraget) ;
%             bar(devsummary)
        end
    end
end

    function [emend, Emissions] = extractENTSOExchange(inputstruct,  Emissions, country_code, SourceFI, EFSource, Emissionsdatabase, loopcount)
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
        
        if ~isfield(Emissions.(country_code), source)
            Emissions.(country_code).(source).EcoInvent.intensityprod = ...
                            Emissions.(country_code).ENTSOE.EcoInvent.intensityprod ;
            Emissions.(country_code).(source).EcoInvent.total = ...
                            Emissions.(country_code).ENTSOE.EcoInvent.total ;
            Emissions.(country_code).(source).IPCC.intensityprod = ...
                            Emissions.(country_code).ENTSOE.IPCC.intensityprod ;
            Emissions.(country_code).(source).IPCC.total = ...
                            Emissions.(country_code).ENTSOE.IPCC.total ;
        end

        emend = Emissions.(country_code).(source).(EFSource).total ;

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
                        if isfield(Emissions.(country_code).(source).(EFSource), 'intensitycons') && loopcount > 1
                            emend = emend + (inputstruct.(geteach{each}) * Emissions.(country_code).(source).(EFSource).currentloopintensitycons);
                            Emissions.(country_code).(source).(EFSource).exchange.(ccode) = (inputstruct.(geteach{each}) * Emissions.(country_code).(source).(EFSource).currentloopintensitycons) ;
                        else
                            emend = emend + (inputstruct.(geteach{each}) * Emissions.(country_code).(source).(EFSource).intensityprod);
                            Emissions.(country_code).(source).(EFSource).exchange.(ccode) = (inputstruct.(geteach{each}) * Emissions.(country_code).(source).(EFSource).intensityprod) ;
                        end
                    %%% Positive is import from the country
                    elseif inputstruct.(geteach{each}) > 0
                        % Check if the country exist
                        if isfield(Emissions,ccode)
                            % Check if the DB exist
                            if isfield(Emissions.(ccode), source)
                                [Emissions, emend] = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, ccode, source, loopcount, Emissionsdatabase, country_code) ;
                            else
                                switch source
                                    case 'emissionskit'
                                        Emissions.(ccode).(source).EcoInvent.intensityprod = Emissions.(ccode).ENTSOE.EcoInvent.intensityprod ;
                                        Emissions.(ccode).(source).EcoInvent.total = Emissions.(ccode).ENTSOE.EcoInvent.total ;
                                        Emissions.(ccode).(source).IPCC.intensityprod = Emissions.(ccode).ENTSOE.IPCC.intensityprod ;
                                        Emissions.(ccode).(source).IPCC.total = Emissions.(ccode).ENTSOE.IPCC.total ;
                                        [Emissions, emend] = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, ccode, source, loopcount, Emissionsdatabase, country_code) ;
                                    case 'ENTSOE'
    
                                    otherwise
    
                                end
    
                            end
                        else
                            Emissionsextract = Emissionsdatabase.(EFSource).(EmissionsCategory)(strcmp(Emissionsdatabase.(EFSource).Technology,'mean') & strcmp(Emissionsdatabase.(EFSource).Country,ccode)) ;
                            if isempty(Emissionsextract)
                                switch ccode
                                    case 'AX'
                                        [Emissions, emend] = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'FI', source, loopcount, Emissionsdatabase, country_code) ;
                                    case {'TR' 'AL'}
                                        [Emissions, emend] = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'GR', source, loopcount, Emissionsdatabase, country_code) ;
                                    case {'UA' 'BY'}
                                        [Emissions, emend] = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'RU', source, loopcount, Emissionsdatabase, country_code) ;
                                    case 'KX'
                                        [Emissions, emend] = getemissions(inputstruct, Emissions, EFSource, emend, geteach{each}, 'ME', source, loopcount, Emissionsdatabase, country_code) ;
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
    end
    %%%%%%%%%%%%%% SETUP EMISSIONKIT IF MISSING %%%%%%%%%%%%%%%%%%%%%%% 
    function setupEK
        
    end

    function [Emissions, emend] = getemissions(inputstruct, Emissions, EFSource, emend, geteach, ccode, source, loopcount, Emissionsdatabase, country_code)
        if isfield(Emissions.(ccode).(source).(EFSource), 'intensitycons') && loopcount > 1
            if isempty(Emissions.(ccode).(source).(EFSource).currentloopintensitycons) || isnan(Emissions.(ccode).(source).(EFSource).currentloopintensitycons)
                emmult = extractdata('mean', ccode, 'GlobalWarming', Emissionsdatabase.EcoInvent) ;
            else
                emmult = Emissions.(ccode).(source).(EFSource).currentloopintensitycons ;                
            end
        else
            if isempty(Emissions.(ccode).(source).(EFSource).intensityprod) ||  isnan(Emissions.(ccode).(source).(EFSource).intensityprod)
                emmult = extractdata('mean', ccode, 'GlobalWarming', Emissionsdatabase.EcoInvent) ;
            else
                emmult = Emissions.(ccode).(source).(EFSource).intensityprod ;                
            end
        end
        emend = emend + (inputstruct.(geteach) * emmult);
        Emissions.(country_code).(source).(EFSource).exchange.(ccode) = inputstruct.(geteach) * emmult ;
    end
    
end
