function mapemissions(Emissions, track)

red = [1, 0, 0];
length = 13;
green = [0, 255, 0]/255;
colors_p = [linspace(red(1),green(1),length)', linspace(red(2),green(2),length)', linspace(red(3),green(3),length)'];
maxemission = 2000000 ; maxlinesize = 20 ; ratio =  maxemission/maxlinesize;
maxemintenc = 1000 ;
minemintenc = 20 ;
expspace = @(vmin,vmax,inc) vmin * inc.^(0:( log(vmax/vmin)/log(inc)));
inc =    1.5 ;
v = expspace(minemintenc, maxemintenc, inc) ;

countrylist = fieldnames(Emissions) ;
figure
gx = geoaxes;
for iloop = 1:50
cla(gx)
    for icountry = 1:numel(countrylist)
        switch countrylist{icountry}
            case 'GR'
                country_code = countrycode('EL') ;
            otherwise
                country_code = countrycode(countrylist{icountry}) ;
        end
    
    %     [latori, lonori] = countryloc(PostCode, 'countryname', country_code.countryname, 'Cityname', country_code.capital) ;
        latori = str2double(country_code.latitude)  ; %countryloc(PostCode, 'countryname', country_code.countryname, 'Cityname', country_code.capital) ;
        lonori = str2double(country_code.longitude) ;
        try
            countrydestination = fieldnames(Emissions.(countrylist{icountry}).emissionskit.EcoInvent.exchange);
        catch
            continue;
        end
        lonFrom = [] ; wd = [] ; LAT = [] ; latFrom = [] ; lonTo = [] ; latTo = [] ; col = [] ;
        
        for jcountry = 1:numel(countrydestination)
            try
                switch countrydestination{jcountry}
                    case 'GR'
                        country_code = countrycode('EL') ;
                    otherwise
                        country_code = countrycode(countrydestination{jcountry}) ;
                end
                
            catch
                x = 1 ;
            end
            try
                latdes = str2double(country_code.latitude)  ; %countryloc(PostCode, 'countryname', country_code.countryname, 'Cityname', country_code.capital) ;
                londes = str2double(country_code.longitude) ;
            catch
                x = 1;
            end
            lonFrom = [lonFrom lonori]          ; % Longitude From
            latFrom = [latFrom latori]          ; % Latitude From
            lonTo = [lonTo londes]              ; % Longitude To
            latTo = [latTo latdes]              ; % Latitude To
            
            maxlen = numel(Emissions.(countrylist{icountry}).emissionskit.EcoInvent.exchange.(countrydestination{jcountry})) ;
            wd  = [wd abs(Emissions.(countrylist{icountry}).emissionskit.EcoInvent.exchange.(countrydestination{jcountry})(min(iloop,maxlen))) / ratio]            ;
            
            if Emissions.(countrylist{icountry}).emissionskit.EcoInvent.exchange.(countrydestination{jcountry})(min(iloop,maxlen)) >= 0
                maxlen = numel(track.(countrylist{icountry}).emissionskit.EcoInvent) ;
                newcol = track.(countrydestination{icountry}).emissionskit.EcoInvent(min(iloop,maxlen)) ;
            else
                maxlen = numel(track.(countrydestination{jcountry}).emissionskit.EcoInvent) ;
                newcol = track.(countrydestination{jcountry}).emissionskit.EcoInvent(min(iloop,maxlen)) ;
            end
            A = repmat(v,[1 numel(newcol)]) ;
            [~,closestIndex] = min(abs(A-newcol')) ;

            col = [col;{colors_p(closestIndex,:)}] ;

        end
        LON = [lonFrom; lonTo]              ;
        LAT = [latFrom; latTo]              ;
        
    % begin_point = [begin_latitude begin_longitude]
    % end_point = [end_latitude end_longitude]
    
    %     plot_arrow_geoplot(LAT,LON,gx) ;
    
        hL = plot(gx,LAT,LON) ;
        hold on
        
        set(hL,{'LineWidth'},num2cell(wd'))
        set(hL,{'Color'},col)
    end
end