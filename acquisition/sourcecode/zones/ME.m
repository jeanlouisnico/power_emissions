function [TTsync, Xchange] = ME

dT = datetime("now", "TimeZone",'UTC') ;

options=weboptions;
options.CertificateFilename=('');
code = webread('https://webndc.cges.me/',options);
tree = htmlTree(code);

selector = "input";
subtrees = findElement(tree,selector);

attr = "value";
str = getAttribute(subtrees,attr) ;

attr = "id";
str_id = getAttribute(subtrees,attr) ;

for istr = 1:length(str_id)
    switch str_id(istr)
        case 'ContentPlaceHolder1_TxtEMS' %Serbia
            Xchange.RS = -str2double(str(istr)) ;
        case 'ContentPlaceHolder1_TxtNOS' % Bosnia
            Xchange.BA = -str2double(str(istr)) ;
        case 'ContentPlaceHolder1_txtKOST' % Kosovo
            Xchange.KX = -str2double(str(istr)) ;
        case 'ContentPlaceHolder1_txtKonzum' % Consumption
            consumption = str2double(str(istr)) ;
        case 'ContentPlaceHolder1_TxtOST' % Albania
            Xchange.AL = -str2double(str(istr)) ;
        case 'ContentPlaceHolder1_TxtTerna' % Italy
            Xchange.IT = -str2double(str(istr)) ;

    end
end

exchangebalance = sum(struct2array(Xchange),'omitnan') ;

production = consumption - exchangebalance ;

% The EK method cannot be applied since the last update for this country
% was in 2019. In this case, we take the energy mix as declared in ENTSOE
% and apply it to the TSO data.

ENTSOE       = ENTSOE_exch('country','Montenegro','documentType','Generation') ;
databyfuel   = ENTSOEbyfuel(ENTSOE.ME) ;

perc = struct2array(databyfuel)/sum( struct2array(databyfuel)) ;

TTsync.emissionskit = array2timetable(production * perc,'RowTimes',dT,'VariableNames',fieldnames(databyfuel)') ;

changefuel = {  'coal' 'coal_chp'
                'hydro' 'hydro_reservoir'
                'others' 'unknown'
                'wind' 'windon'} ;

replacestring = cellfun(@(x) changefuel(strcmp(changefuel(:,1),x),2), TTsync.emissionskit.Properties.VariableNames, 'UniformOutput', false) ;
TTsync.emissionskit.Properties.VariableNames = cat(1, replacestring{:}) ;

Xchange = table2timetable(struct2table(Xchange),'RowTimes',dT) ;