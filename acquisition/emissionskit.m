function emissionskit(src, eventdata)
% This is the main routine for running the emission code from MatLab
 dbstop if error
%% Locate the file
p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;
 
%% Exchange of Power
% For the other countries, it is necessary to loop through each connected
% country. Country can be added or removed by editing the cell array.
% Country = {'Russia', 'Sweden', 'Estonia', 'Norway', 'Finland', 'France'} ;

Country = country2fetch ;

country_code = countrycode(Country) ;
Power = struct ;


if isfile('Xchange.json')
    FileInfo = dir('Xchange.json') ;
    datecompare = datetime('now') ;
    datefile    = datetime(FileInfo.datenum, "ConvertFrom", "datenum") ;

    % Check daily if the data have changed
    if minutes(datecompare-datefile) >= 20
        msgin = 'Update exchange data from ENTSOE' ;
        looplog(msgin) ;
        tic;
        counter = 0 ;
        for icountry = 1:length(Country)
            [Power(icountry).ENTSOE.exchange]   = ENTSOE_exch('country',Country{icountry},'documentType','Exchange')       ;
        end
        for icountry = 1:length(Country)
            ccode = fieldnames(Power(icountry).ENTSOE.exchange) ;
            p_out.(ccode{1}) = timetable2table(Power(icountry).ENTSOE.exchange.(ccode{1})) ;
        end
        Xchange = p_out ;
        dlmwrite([fparts{1} filesep 'Xchange.json'],jsonencode(p_out,'PrettyPrint',true),'delimiter','');
        msgin = 'Update completed, json created' ;
        looplog(msgin) ;
        toc
    else
        msgin = 'Exchange data loaded from json file' ;
        looplog(msgin) ;
        Xchange = jsondecode(fileread([fparts{1} filesep 'Xchange.json']));  
    end
else
    counter = 0 ;
    msgin = 'Exchange data file does not exist' ;
    looplog(msgin) ;
    for icountry = 1:length(Country)
        [Power(icountry).ENTSOE.exchange, counter]   = ENTSOE_exch('country',Country{icountry},'documentType','Exchange', 'counter', counter)       ;
    end
    for icountry = 1:length(Country)
        ccode = fieldnames(Power(icountry).ENTSOE.exchange) ;
        p_out.(ccode{1}) = timetable2table(Power(icountry).ENTSOE.exchange.(ccode{1})) ;
    end
    Xchange = p_out ;
    dlmwrite([fparts{1} filesep 'Xchange.json'],jsonencode(p_out,'PrettyPrint',true),'delimiter','');
    msgin = 'Exchange data file created and json created' ;
    looplog(msgin) ;
end


tic;
parfor icountry = 1:length(Country)
    [ENTSOE, TSO, PoweroutLoad, xCHANGE] = CallCountryPower(Country{icountry}) ;
    Power(icountry).ENTSOE.bytech = ENTSOE ;
    Power(icountry).ENTSOE.byfuel = ENTSOEbyfuel(ENTSOE) ;
    Power(icountry).ENTSOE.TotalConsumption = PoweroutLoad ;
    Power(icountry).TSO = TSO ;
    Power(icountry).xCHANGE = xCHANGE ;
    switch country_code.alpha2{icountry}
        case 'EL'
            ccout = 'GR' ;
        otherwise
            ccout = country_code.alpha2{icountry} ;
    end
    Power(icountry).zone = ccout ; 
    msgin = ['Update ' Country{icountry} ' completed'] ;
    looplog(msgin) ;
end
EntsoeTSO = toc;

%% Load Emissions data
% Emissions from EcoInvent are gathered and stored in a .csv file
% associated to this file Emissions_Summary.csv. The data are gathered from
% EcoInvent 3.6 and characterised with the ReCiPe 2016 method. All
% categories are reported therefore, it is possible to choose from any of
% the 18 categories
EmissionsCategory = 'GlobalWarming'     ;
Emissionsdatabase = load_emissions      ;    
tic;
%% Emissions ENTSOE
% Re-allocate the emissions per type of technology
EFSourcelist = {'EcoInvent' 'IPCC'} ;
for iEFSource = 1:length(EFSourcelist)
    EFSource = EFSourcelist{iEFSource} ;
    for icountry = 1:length(Country)
        cc = country_code.alpha2{icountry} ;
        if strcmp(cc,'FR')
            x=1;
        end
        sublst = fieldnames(Power(icountry).ENTSOE.bytech) ;
        for isublst = 1:length(sublst)
            EmissionTotal = ENTSOEEmissions(Power(icountry).ENTSOE.bytech.(sublst{isublst}) , Emissionsdatabase.newem.emissionFactors.(EFSource), cc, EmissionsCategory, EFSource) ;
            if isa(EmissionTotal, 'struct')
                Emissions.(sublst{isublst}).ENTSOE.(EFSource).total            = sum(struct2array(EmissionTotal)) ;
                Emissions.(sublst{isublst}).ENTSOE.(EFSource).intensityprod    = Emissions.(sublst{isublst}).ENTSOE.(EFSource).total / sum(Power(icountry).ENTSOE.bytech.(sublst{isublst}).Variables) ;
                if isnan(Emissions.(sublst{isublst}).ENTSOE.(EFSource).intensityprod)
                   Emissions.(sublst{isublst}).ENTSOE.(EFSource).intensityprod = extractdata('mean', cc, EmissionsCategory, Emissionsdatabase.EcoInvent) ;
                end
            else
                Emissions.(sublst{isublst}).ENTSOE.(EFSource).total = 0 ;
                Emissions.(sublst{isublst}).ENTSOE.(EFSource).intensityprod    = extractdata('mean', cc, EmissionsCategory, Emissionsdatabase.EcoInvent) ;
            end
        end
    end
end

tic
for icountry = 1:length(Country)
    cc = country_code.alpha2{icountry} ;
    switch cc
        case 'EL'
            cc2 = 'GR' ;
        otherwise
            cc2 = cc ;
    end
    if strcmp(cc,'LT')
        x=1;
    end
    if ~isa(Power(icountry).TSO,'double')
        sublst = fieldnames(Power(icountry).TSO) ;
        for isublst = 1:length(sublst)
            
            em = unloaddata(Power(icountry).TSO, sublst{isublst}, EmissionsCategory, Emissionsdatabase, cc) ;
            if isa(em,'double')
                continue;
            end
            if isa(em, 'struct')
                switch sublst{isublst}
                    case {'emissionskit' 'TSO'}
                        Emissions.(cc2).emissionskit = em.(cc).(sublst{isublst}) ;    
                    otherwise
                        Emissions.(sublst{isublst}) = em.(cc) ;
                end
            end
        end
    end
end
emissionroutine = toc;
msgin = 'Emissions calculation completed' ;
looplog(msgin) ;

%% Check the values between the different methods and see if they differs significanlty, 
% if yes there might be a problem somewhere

allcount = fieldnames(Emissions) ;
outT = table ;
for icountry = 1:length(allcount)
    countryname = allcount{icountry} ;
    s.name = countryname ;
    if isfield(Emissions.(countryname),'ENTSOE')
        s.ENTSOE_EcoInvent = Emissions.(countryname).ENTSOE.EcoInvent.intensityprod ;
        s.ENTSOE_IPCC      = Emissions.(countryname).ENTSOE.IPCC.intensityprod ;
        if isempty(s.ENTSOE_EcoInvent)
            s.ENTSOE_EcoInvent = 0 ;
        end
        if isempty(s.ENTSOE_IPCC)
            s.ENTSOE_IPCC = 0 ;
        end
    else
        s.ENTSOE_EcoInvent = 0 ;
        s.ENTSOE_IPCC      = 0 ;
    end
    if isfield(Emissions.(countryname),'emissionskit')
        s.emissionskit_EcoInvent = Emissions.(countryname).emissionskit.EcoInvent.intensityprod ;
        s.emissionskit_IPCC      = Emissions.(countryname).emissionskit.IPCC.intensityprod ;
    else
        s.emissionskit_EcoInvent = 0 ;
        s.emissionskit_IPCC      = 0 ;
    end

    st = struct2table(s) ;
    outT = [outT;st] ;

end

%% Emissions balanced


[Emissions, track] = emissions_cons('power', Power, 'emissions', Emissions) ;
msgin = 'Balanced Emissions calculation completed' ;
looplog(msgin) ;
% Source = {'IPCC'
%           'EcoInvent'} ;
% FIsource = {'ENTSOE'
%             'TSO'} ;
% for ipower = 1:length(FIsource)
%     SourceFI = FIsource{ipower} ;
%     for iEFSource = 1:length(Source)
%         EFSource = EFSourcelist{iEFSource} ;
%         if Power.FI.TSO.TradeRU > 0 
%             %%%
%             % Import from RU. Add the emissions to the Finnish energy
%             % mix
%             EmissionTrade.RU = Power.FI.TSO.TradeRU * Emissions.RU.TSO.(EFSource).intensityprod ;
%         else
%             %%%
%             % Export to RU. educe the emissions from the Finnish energy
%             % mix
%             EmissionTrade.RU = Power.FI.TSO.TradeRU * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
%         end
%         if Power.FI.TSO.TradeNO > 0 
%             %%%
%             % Import from NO
%             EmissionTrade.NO = Power.FI.TSO.TradeNO * Emissions.NO.ENTSOE.(EFSource).intensityprod ;
%         else
%             %%%
%             % Export to NO
%             EmissionTrade.NO = Power.FI.TSO.TradeNO * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
%         end
%         if Power.FI.TSO.TradeEE > 0 
%             %%%
%             % Import from EE
%             EmissionTrade.EE = Power.FI.TSO.TradeEE * Emissions.EE.(SourceFI).(EFSource).intensityprod ;
%         else
%             %%%
%             % Export to EE
%             EmissionTrade.EE = Power.FI.TSO.TradeEE * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
%         end
%         if Power.FI.TSO.TradeSE > 0 
%             %%%
%             % Import from SE
%             EmissionTrade.SE = Power.FI.TSO.TradeSE * Emissions.SE.(SourceFI).(EFSource).intensityprod ;
%         else
%             %%%
%             % Export to SE
%             EmissionTrade.SE = Power.FI.TSO.TradeSE * Emissions.FI.(SourceFI).(EFSource).intensityprod ;
%         end
%         Balance = Emissions.FI.(SourceFI).(EFSource).total + sum(struct2array(EmissionTrade)) ;
%         %%%
%         % Recalculate the emission intensity based on the consumption of
%         % electricity in FI and including the traded electricity and their
%         % emission impact.
%         Emissions.FI.(SourceFI).(EFSource).intensitycons = Balance / Power.FI.(SourceFI).TotalConsumption ;
%     end
% end
%% Save all values in XML files

currenttime = datetime('now','TimeZone','UTC') ;

%% Send the data to the server

try 
    % Test the connection, if it is valid then continue saving in the sql
    % database. If it is not valid, save using the xml format
    conn = connDB ;
    msgin = 'connection to local DB sql successful' ;
    looplog(msgin) ;
    close(conn);
    send2sqlcomplete(currenttime, Emissions) ;
    msgin = 'Emissions data sent successfully to the local server' ;
    looplog(msgin) ;
    send2sqlpowerbyfuel(currenttime, Power) ;
    msgin = 'Emissions data sent successfully to the local server' ;
    looplog(msgin) ;

    str = which('move2SCSC.m') ;
    if ~isempty(str)
        move2SCSC;
        msgin = 'Emissions data sent successfully to the remote server' ;
        looplog(msgin) ;
    end
    str = which('move2SCSC_powerbyfuel.m') ;
    if ~isempty(str)
        move2SCSC_powerbyfuel;
        msgin = 'Power consumption by fuel data sent successfully to the remote server' ;
        looplog(msgin) ;
    end
catch
    % All variables are stored in xml format saved at the same location than
    % this function as XMLEmissions.xml. We are not storing data
    % therefore only the latest data are provided.
    p = mfilename('fullpath') ;
    [filepath,~,~] = fileparts(p) ;
    fparts = split(filepath, filesep) ;
    fparts = join(fparts(1:end-1), filesep) ;
    
    archivepath = [fparts{1} filesep 'output'] ;

    Filename = [sprintf('%02d',currenttime.Year) sprintf('%02d',currenttime.Month) sprintf('%02d',currenttime.Day) sprintf('%02d',currenttime.Hour) '_Emissions.xml'] ;

    if isfile(Filename)
        archive = false ;
        s = xml2struct2(Filename) ;
        nbrexistingdata = length(s.EmissionsFinland.Data) ;
        if nbrexistingdata == 1
            s.EmissionsFinland.Data(nbrexistingdata+1).Date = datestr(currenttime, 'dd-mm-yyyy HH:MM:SS') ;
            s.EmissionsFinland.Data(nbrexistingdata+1).Power = Power ;
            s.EmissionsFinland.Data(nbrexistingdata+1).Emissions = Emissions ;
        else
            s.EmissionsFinland.Data{nbrexistingdata+1}.Date = datestr(currenttime, 'dd-mm-yyyy HH:MM:SS') ;
            s.EmissionsFinland.Data{nbrexistingdata+1}.Power = Power ;
            s.EmissionsFinland.Data{nbrexistingdata+1}.Emissions = Emissions ;
        end
    else  
        archive = true ;
        s.EmissionsFinland.Data(1).Date = datestr(currenttime, 'dd-mm-yyyy HH:MM:SS') ;
        s.EmissionsFinland.Data(1).Power = Power ;
        s.EmissionsFinland.Data(1).Emissions = Emissions ;
    end
    
    struct2xml(s, [archivepath filesep Filename]);
%     extract4Tableau(archivepath) ;
    
    %%% Archive the data
    if archive
        %%% Archive old files
        currenttimetemp = datetime(now, "ConvertFrom", "datenum")- hours(1) ;
        Filenameold = [sprintf('%02d',currenttimetemp.Year) ...
                       sprintf('%02d',currenttimetemp.Month) ...
                       sprintf('%02d',currenttimetemp.Day) ...
                       sprintf('%02d',currenttimetemp.Hour) '_Emissions.xml'] ;


        archivepath = [archivepath filesep 'archive' filesep 'xml'] ;

        if ~exist(archivepath, 'dir')
           mkdir(archivepath)
        end
        try
            archivepathtemp = 'C:\TEMP\archive\xml' ;
            if ~exist(archivepathtemp, 'dir')
               mkdir(archivepathtemp)
            end
            copyfile(Filenameold, archivepathtemp) ;
            disp('file copied')
        catch
            % Error might happen if data were missing
        end
        try 
            movefile(Filenameold, archivepath)
            disp('file moved')
        catch
            % Error might happen if data were missing
        end
        %%% Archive old files
    end 
end
S = struct("emissions", struct("time", datestr(currenttime, 'dd-mm-yyyy HH:MM:SS'), "emissionintensity", num2str(Emissions.FI.emissionskit.EcoInvent.intensitycons))) ;
s = jsonencode(S) ;
JSONFILE_name= sprintf('%s.json','emissions') ;
fid=fopen(JSONFILE_name,'w');
fprintf(fid, s);
fclose('all');
if isfolder([getenv('USERPROFILE') filesep 'OneDrive - Oulun yliopisto'])
    movefile('emissions.json',[getenv('USERPROFILE') filesep 'OneDrive - Oulun yliopisto' filesep 'CSC']);
end
%% Function extract from table
    function Emissionsextract = extractdata(Tech, Country, EmissionsCategory, Emissions)
        if isa(Emissions, 'table')
            % This is the original table extract
            Emissionsextract = Emissions.(EmissionsCategory)(strcmp(Emissions.Technology,Tech) & strcmp(Emissions.Country,Country)) ;
        elseif isa(Emissions, 'struct')
            % This is from the json data
            Emissionsextract = Emissions.emissionFactors.EcoInvent.zoneOverrides.(Country).(Tech).(EmissionsCategory).value ;
        end
            
    end

%% function 


end
