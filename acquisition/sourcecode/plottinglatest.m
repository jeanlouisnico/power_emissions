function plottinglatest(src, eventdata)

%% Set the table

f1 = figure ;
f1.Position = [15,290,1128,420] ;

%% add the power by fuel

tablename_psql = 'powerbyfuel' ;
conn = connDB ;

try
    currentdate = datetime(now, "ConvertFrom", "datenum") ;

    countryshort = 'FI' ;
    countrylong = 'Finland';
    powersource = 'TSO' ;

    datestart     = datestr(currentdate - hours(24), 'yyyy-mm-dd HH:MM:SS') ;

    sqlquery = ['SELECT * FROM ' tablename_psql ' WHERE date_time>''' datestart ''''...
                                          ' AND (country=''' countryshort ''' OR country=''' countrylong ''')' ...
                                          ' AND powersource=''' powersource ''''];

    idtable = fetch(conn,sqlquery) ;
    allfuel = unique(idtable.fuel) ;

    for ifuel = 1:length(allfuel)
        data(:,ifuel)     = idtable.power_generated(idtable.fuel==allfuel{ifuel}) ;
        alltimes        = idtable.date_time(idtable.fuel==allfuel{ifuel}) ;
    end

    data = array2timetable(data, 'RowTimes', alltimes, 'VariableNames', allfuel) ;

    color = {'nuclear', 255, 104, 106
            'biomass', 143, 255, 143
            'wind', 119, 187, 255
            'solar', 255, 255, 128
            'hydro', 0, 128, 192
            'coal', 0, 0, 0
            'oil', 61, 0, 0
            'peat', 90, 216, 89
            'gas', 174, 215, 255
            'others', 217, 83, 25} ;

    fuelmeritorder = {'nuclear'
                      'wind'
                      'solar'
                      'hydro'
                      'biomass'
                      'coal'
                      'gas'
                      'oil'
                      'peat'
                      'others'
                    } ; 

    alltime = data.Time;
    % alltime.TimeZone = 'Europe/Helsinki' ;

    for icat = 1:length(allfuel)
        row = find(strcmp(fuelmeritorder{icat}, color(:,1))==1) ;
        try
            newcolors(icat, :) = [color{row,2} color{row,3} color{row,4}]/255;
        catch
            newcolors(icat, :) = [100 100 100]/255;
        end
        if icat == 1
            T2 = movevars(data,fuelmeritorder{icat},'Before',1) ;
        else
            T2 = movevars(T2,fuelmeritorder{icat},'After',fuelmeritorder{icat-1}) ;
        end
    end

    % f1.Position = [2561 617 1536 747];
    if length(data.Time) > 1
        try 
            yyaxis(f1,'left')
            area(f1, alltime,T2.Variables) ;
            legend(f1, allcat)
            title(f1, [Countrydis '-' Emissions])
            colororder(f1, newcolors) ;
            ylim(f1, [0, max(sum(T2.Variables, 2))]) ;
            ylabel(f1,'Power production by fuel type [MWh]')
            exportgraphics(f1,'Power_System_State.png') ;
        catch
    %         yyaxis 'left'
            var2plot = T2.Variables ;
    %         plot(alltime,var2plot) ;

    %         legend(fuelmeritorder, 'Location', 'best')
    %         title([Countrydis '-' Emissions])
    %         colororder(newcolors) ;
    %         h1 = legend(fuelmeritorder, 'Location', 'bestoutside') ;
    %         lbl = f1.Children(1).String ;
    %         numlbl = length(lbl) ;
    %         order = sort(1:1:numlbl,'descend') ;
    %         newlbl = lbl(order) ;
    %         h1 = legend(findobj(f1.Children(2),'Type','area'),newlbl, 'Location', 'best') ;
            xlabel('Time [3 minutes]')
        end
    end 
    close(conn)
catch
    close(conn)
end

%% Add emissions
tablename_psql = 'emissions' ;
conn = connDB ;

try
    countryshort = 'FI' ;
    countrylong = 'Finland';
    emdb = 'EcoInvent' ;

    datestart     = datestr(currentdate - hours(24), 'yyyy-mm-dd HH:MM:SS') ;

    sqlquery = ['SELECT * FROM ' tablename_psql ' WHERE date_time>''' datestart ''''...
                                          ' AND (country=''' countryshort ''' OR country=''' countrylong ''')' ...
                                          ' AND emdb=''' emdb ''''];


    idtable = fetch(conn,sqlquery) ;
    idtable = sortrows(idtable,'id','ascend') ;
    alltime = idtable.date_time;

    datestart     = datestr(currentdate - days(31), 'yyyy-mm-dd HH:MM:SS') ;

    sqlquery = ['SELECT * FROM ' tablename_psql ' WHERE date_time>''' datestart ''''...
                                          ' AND (country=''' countryshort ''' OR country=''' countrylong ''')' ...
                                          ' AND emdb=''' emdb ''''];

    idtable_meancalc = fetch(conn,sqlquery) ;
    idtable_meancalc = sortrows(idtable_meancalc,'id','ascend') ;
    movingmean = cummean(idtable_meancalc.emissionintcons,1) ;

    % alltime.TimeZone = 'Europe/Helsinki' ;
    % yyaxis 'right'
    [hAx,hLine1,hLine2] = plotyy(alltime,var2plot, alltime, [idtable.emissionintcons idtable.emissionintprod movingmean((length(movingmean)- length(alltime) + 1):end)]) ;
    hLine2(2).Color = 'blue' ;
    hLine2(1).Color = 'black' ;
    hLine2(1).LineWidth = 1 ;
    hLine2(2).LineWidth = 1 ;
    legend([hLine1;hLine2],[fuelmeritorder ; {'Emission Consumption';'Emission Production';'moving average emissions'}], 'Location', 'bestoutside');
    % plot(f1, alltime,idtable.emissionintcons, 'color','black') ; hold on
    % plot(alltime,idtable.emissionintprod, 'color','blue') ; hold off
    % try 
    %     h1.String(end-1:end) = {'Consumption' 'Production'} ;
    % catch
    %     legend({'Consumption' 'Production'}) ;
    % end
    ylabel(hAx(2), 'CO_{2} Emissions intensity [gCO2/kWh]')
    ylabel(hAx(1), 'Power generation [MWh]')

    % % xlim([min(alltime) max(alltime)]) ;
    % 
    % % ylabel('CO_{2} Emissions intensity [gCO2/kWh]')

    if exist("fig2plotly",'file')
        try
            fig = fig2plotly(f1, 'offline', false, 'filename','Emissions', 'open', false) ;
            fig = fig2plotly(f1, 'offline', true, 'filename','Emissions', 'open', false) ;
        catch
            fig = fig2plotly(f1, 'offline', true, 'filename','Emissions', 'open', false) ;
        end
    else
        warning_('plotly was not installed, go to https://github.com/plotly/plotly_matlab to get the latest version of plotly and enable online and offline plotting')
    end
    close(f1) ;
    %set(0,'DefaultFigureVisible','on');
    close(conn)
catch
    close(conn)
end
