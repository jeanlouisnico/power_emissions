function cVal = Prod_vs_Cons 
starty = 2017 ;
endy = 2021 ;
for iyear = starty:endy
    Emissions = load(['Emissions_alternative1' num2str(iyear) '.mat']) ;
    Emissions = Emissions.Emissions ;
    Power = load(['Power_' num2str(iyear) '.mat']) ;
    Power = Power.Power ;
    powersource = 'TSO' ;
    country = 'Finland' ;
    DB = 'EcoInvent' ; % electricitymap_Emissions EcoInvent
    varname = {'cons', 'intens'} ;  
    timeres = {'combined','hour','minute'} ;
    %% Realised Measured
    try
        ObsTSO = synchronize(Power.(country).(powersource).allpower(:, 'TotalConsumption'), Emissions.(country).(powersource).([DB '_realised']).intensitycons) ;
    catch
        warning('The database your are trying to access does not exist.')
        return;
    end
    ObsTSO = filloutliers(ObsTSO,'linear');
    ObsTSO.Properties.VariableNames = varname ;

    datetempObsConsProd = dailyprofile(ObsTSO) ;
    
    figure;
    for ivar = 1:length(varname)
        plot(1:1:24, datetempObsConsProd.([varname{ivar} '_winter']))
        hold on
    end
    hold off
    
% get(gca,'fontname')  % shows you what you are using.
% set(gca,'fontname','times')  % Set it to times
%    
    for ivar = 1:length(varname)
        sourcecaption   = [powersource '_' varname{ivar}]; % 'TSO_Cons'
        switch varname{ivar}
            case 'cons'
                countrycaption  = ['Power_' country]; % 'Emissions_Finland'
                ylabelcaption = 'Power [MWh]' ;
                titlecaption = ['Power - ' country ' Consumption'] ;
            case 'intens'
                countrycaption  = ['Emissions_' country]; % 'Emissions_Finland'
                ylabelcaption = 'CO2 intensity [gCO2/kWh]' ;
                titlecaption = ['CO2 Emissions - ' country ' Consumption'] ;
        end
        
        for itimeres = 1:length(timeres)
            [ups.(timeres{itimeres}), downs.(timeres{itimeres})] = plotpeaks_elec(ObsTSO.(varname{ivar}), ObsTSO.Time, 'title', titlecaption,...
                                                        'ylabelin',ylabelcaption,...
                                                        'type', countrycaption,...
                                                        'yearin', num2str(iyear),...
                                                        'source',sourcecaption,...
                                                        'variable', DB,...
                                                        'res',timeres{itimeres}) ;
        end
        corr = corrcoef(ObsTSO.Variables) ;
            correlationtime.(['x' num2str(iyear)])(1,1) = corr(2,1) ;
        dataout.(['ups' varname{ivar}]).hour.(['x' num2str(iyear)]) = histcounts(ups.hour.hour,24)' ;
        dataout.(['downs' varname{ivar}]).hour.(['x' num2str(iyear)]) = histcounts(downs.hour.hour,24)' ;
        dataout.(['ups' varname{ivar}]).minute.(['x' num2str(iyear)]) = histcounts(ups.minute.minute,480)' ;
        dataout.(['downs' varname{ivar}]).minute.(['x' num2str(iyear)]) = histcounts(downs.minute.minute,480)' ;
    end
end
structout = struct2table(correlationtime) ;
writetable(structout, ['Correlation_' char(join(varname,'_')) '.csv'],'WriteRowNames',true) ;
b = flipud((0.01:256-1)'/max(256-1,1));
r = flipud(b) ./ flipud(b) ;
g = b;
c = [r g b]; 
for itimeres = 2:3
    for ivar = 1:length(varname)
         dataout.(['ups' varname{ivar}]).(timeres{itimeres}) = struct2table(dataout.(['ups' varname{ivar}]).(timeres{itimeres})) ;
                dataout.(['ups' varname{ivar}]).(timeres{itimeres}).Properties.VariableNames = ...
                    erase(dataout.(['ups' varname{ivar}]).(timeres{itimeres}).Properties.VariableNames,'x') ;
         dataout.(['downs' varname{ivar}]).(timeres{itimeres}) = struct2table(dataout.(['downs' varname{ivar}]).(timeres{itimeres})) ;
                dataout.(['downs' varname{ivar}]).(timeres{itimeres}).Properties.VariableNames = ...
                    erase(dataout.(['downs' varname{ivar}]).(timeres{itimeres}).Properties.VariableNames,'x') ;
    end
end
for itimeres = 2:3
     mC = [255 255 255];
     font = 'times new roman' ;
     ftsize = 10 ;
     tab.(['ups' varname{1}]).(timeres{itimeres}) = organiseTab(dataout.(['ups' varname{1}]).(timeres{itimeres})) ; 
     tab.(['ups' varname{2}]).(timeres{itimeres}) = organiseTab(dataout.(['ups' varname{2}]).(timeres{itimeres})) ;
     tab.(['downs' varname{1}]).(timeres{itimeres}) = organiseTab(dataout.(['downs' varname{1}]).(timeres{itimeres})) ;
     tab.(['downs' varname{2}]).(timeres{itimeres}) = organiseTab(dataout.(['downs' varname{2}]).(timeres{itimeres})) ;
     %%% Multiple plotting
     multipleplots(tab, varname, timeres, itimeres, mC, font, ftsize, c) ;
     
     %%% Individual plotting
     datain = tab.(['ups' varname{1}]).(timeres{itimeres})  ;
        str1 = [varname{1},'_ups'] ;
        individualplots(datain, timeres, itimeres, mC, font, ftsize, c, str1)
     datain = tab.(['ups' varname{2}]).(timeres{itimeres}) ;
        str1 = [varname{2},'_ups'] ;
        individualplots(datain, timeres, itimeres, mC, font, ftsize, c, str1)
     datain = tab.(['downs' varname{1}]).(timeres{itimeres}) ;
        str1 = [varname{1},'_downs'] ;
        individualplots(datain, timeres, itimeres, mC, font, ftsize, c, str1)
     datain = tab.(['downs' varname{2}]).(timeres{itimeres})  ;
        str1 = [varname{2},'_downs'] ;
        individualplots(datain, timeres, itimeres, mC, font, ftsize, c, str1)
end
allyears = dataout.(['ups' varname{1}]).(timeres{2}).Properties.VariableNames ;
% do it for each year separately 
for iyear = 1:length(allyears)
    for itimeres = 2:3
        datain = [] ;
        for ivar = 1:length(varname)
            dataplace = contains(tab.(['downs' varname{ivar}]).(timeres{itimeres}).year, allyears{iyear}) ;
            datain(:,ivar) = tab.(['downs' varname{ivar}]).(timeres{itimeres}).data(dataplace) ;
        end
        datain(isnan(datain)) = 0 ;
        figure; plotmatrix(datain)      ;
        cVal.down.(['x' allyears{iyear}]).(timeres{itimeres}) = corrcoef(datain) ;
    end

    for itimeres = 2:3
        datain = [] ;
        for ivar = 1:length(varname)
            dataplace = contains(tab.(['downs' varname{ivar}]).(timeres{itimeres}).year, allyears{iyear}) ;
            datain(:,ivar) = tab.(['ups' varname{ivar}]).(timeres{itimeres}).data(dataplace) ;
        end
        datain(isnan(datain)) = 0 ;
        figure; plotmatrix(datain)      ;
        cVal.up.(['x' allyears{iyear}]).(timeres{itimeres}) = corrcoef(datain) ;
    end
end
cat = fieldnames(cVal) ;
for icat = 1:length(cat)
    for iyear = starty:endy
        tabout.(['x' num2str(iyear)])(1,1) = cVal.(cat{icat}).(['x' num2str(iyear)]).hour(1,2) ;
        tabout.(['x' num2str(iyear)])(2,1) = cVal.(cat{icat}).(['x' num2str(iyear)]).minute(1,2) ;
    end
    structout = struct2table(tabout, 'RowNames', {'hour','minute'}) ;
    writetable(structout, ['Correlation_' cat{icat} '.csv'],'WriteRowNames',true)
end
delete(findall(0));

function datetemp = dailyprofile(datain)
    datasource = datain.Properties.VariableNames ;
    for itime = 0:23
        for isource = 1:length(datasource)
            data = retime(datain(datain.Time.Hour == itime,datasource{isource}), "yearly", "mean") ;
            if isempty(data)
                datatemp = 0;
            else
                datatemp = data.(datasource{isource}) ;
            end
            datetemp.([datasource{isource} '_winter'])(itime+1, 1) = mean(datatemp) / 1000 ; 
        end
    end 
end

    function multipleplots(tab, varname, timeres, itimeres, mC, font, ftsize, c)
        % Get underlying axis handle
        origState = warning('query', 'MATLAB:structOnObject');
        cleanup = onCleanup(@()warning(origState));
        warning('off','MATLAB:structOnObject')
        
        h = figure ;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(2,2,1);
        hm = heatmap(tab.(['ups' varname{1}]).(timeres{itimeres}),'Time','year', 'ColorVariable', 'data', ...
                                   'MissingDataColor', mC./255, ...
                                   'GridVisible', 'off', ...
                                   'Title', 'upPeak power consumption',...
                                   'FontName',font,...
                                   'FontSize' , ftsize); colormap(c) ;
        alldata = get(gca,'XData') ;
        newxaxis = repmat({''}, length(alldata), 1) ;
        binsize = floor(length(alldata) / 24) ;
        newxaxis(1:binsize:end) = alldata(1:binsize:end) ;
        set(gca,'XDisplayLabels', newxaxis) ;
        set(gca,'GridVisible','on') ;
        S = struct(hm); % Undocumented
        ax = S.Axes;    % Undocumented
        clear('cleanup')
        hm.GridVisible = 'off';
        col = 1:binsize:length(newxaxis); 
            nbryear = length(unique(tab.(['ups' varname{1}]).(timeres{itimeres}).year)) ;
        row = 1:nbryear;
        xline(ax, [col-.5, col+.5], 'k-', 'LineWidth',.1)
        yline(ax, [row-.5, row+.5], 'k-', 'LineWidth',.1)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(2,2,2);   
        hm = heatmap(tab.(['ups' varname{2}]).(timeres{itimeres}),'Time','year', 'ColorVariable', 'data', ...
                                   'MissingDataColor', mC./255, ...
                                   'GridVisible', 'off',...
                                   'Title', 'upPeak emission intensity',...
                                   'FontName',font,...
                                   'FontSize' , ftsize);colormap(c) ;
        alldata = get(gca,'XData') ;
        newxaxis = repmat({''}, length(alldata), 1) ;
        binsize = floor(length(alldata) / 24) ;
        newxaxis(1:binsize:end) = alldata(1:binsize:end) ;
        set(gca,'XDisplayLabels', newxaxis) ;
        set(gca,'GridVisible','on') ;
        S = struct(hm); % Undocumented
        ax = S.Axes;    % Undocumented
        clear('cleanup')
        hm.GridVisible = 'off';
        col = 1:binsize:length(newxaxis); 
            nbryear = length(unique(tab.(['ups' varname{1}]).(timeres{itimeres}).year)) ;
        row = 1:nbryear;
        xline(ax, [col-.5, col+.5], 'k-', 'LineWidth')
        yline(ax, [row-.5, row+.5], 'k-', 'LineWidth')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(2,2,3);
        hm = heatmap(tab.(['downs' varname{1}]).(timeres{itimeres}),'Time','year', 'ColorVariable', 'data', ...
                                   'MissingDataColor', mC./255, ...
                                   'GridVisible', 'off', ...
                                   'Title', 'downPeak power consumption' ,...
                                   'FontName',font,...
                                   'FontSize' , ftsize);colormap(c) ;
        alldata = get(gca,'XData') ;
        newxaxis = repmat({''}, length(alldata), 1) ;
        binsize = floor(length(alldata) / 24) ;
        newxaxis(1:binsize:end) = alldata(1:binsize:end) ;
        set(gca,'XDisplayLabels', newxaxis) ;
        set(gca,'GridVisible','on') ;
        S = struct(hm); % Undocumented
        ax = S.Axes;    % Undocumented
        clear('cleanup')
        hm.GridVisible = 'off';
        col = 1:binsize:length(newxaxis); 
            nbryear = length(unique(tab.(['ups' varname{1}]).(timeres{itimeres}).year)) ;
        row = 1:nbryear;
        xline(ax, [col-.5, col+.5], 'k-', 'LineWidth',.1)
        yline(ax, [row-.5, row+.5], 'k-', 'LineWidth',.1)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subplot(2,2,4);   
        hm = heatmap(tab.(['downs' varname{2}]).(timeres{itimeres}),'Time','year', 'ColorVariable', 'data', ...
                                   'MissingDataColor', mC./255, ...
                                   'GridVisible', 'off',...
                                   'Title', 'downPeak emission intensity',...
                                   'FontName',font,...
                                   'FontSize' , ftsize );colormap(c) ;
        alldata = get(gca,'XData') ;
        newxaxis = repmat({''}, length(alldata), 1) ;
        binsize = floor(length(alldata) / 24) ;
        newxaxis(1:binsize:end) = alldata(1:binsize:end) ;
        set(gca,'XDisplayLabels', newxaxis) ;
        set(gca,'GridVisible','on') ;
        S = struct(hm); % Undocumented
        ax = S.Axes;    % Undocumented
        clear('cleanup')
        hm.GridVisible = 'off';
        col = 1:binsize:length(newxaxis); 
            nbryear = length(unique(tab.(['ups' varname{1}]).(timeres{itimeres}).year)) ;
        row = 1:nbryear;
        xline(ax, [col-.5, col+.5], 'k-', 'LineWidth',.1)
        yline(ax, [row-.5, row+.5], 'k-', 'LineWidth',.1)
        
        h.Position(3:4) = [1000 400] ;
        str = strjoin(varname,'_') ;
        exportitle = ['peaks_' str '_' timeres{itimeres}] ;
        exportitle = [exportitle '.pdf'] ;
        exportgraphics(gcf,exportitle,'ContentType','vector')
    end

    function individualplots(datain, timeres, itimeres, mC, font, ftsize, c, str)
         % tab.(['ups' varname{1}]).(timeres{itimeres})
        h = figure ;
        hm = heatmap(datain,'Time','year', 'ColorVariable', 'data', ...
                                   'MissingDataColor', mC./255, ...
                                   'GridVisible', 'off', ...
                                   'Title', '',...
                                   'FontName',font,...
                                   'FontSize' , ftsize); colormap(c) ;
        
        alldata = get(gca,'XData') ;
        newxaxis = repmat({''}, length(alldata), 1) ;
        binsize = floor(length(alldata) / 24) ;
        newxaxis(1:binsize:end) = alldata(1:binsize:end) ;
        set(gca,'XDisplayLabels', newxaxis) ;
        S = struct(hm); % Undocumented
        ax = S.Axes;    % Undocumented
        clear('cleanup')
        hm.GridVisible = 'off';
        col = 1:binsize:length(newxaxis); 
            nbryear = length(unique(datain.year)) ;
        row = 1:nbryear;
        xline(ax, [col-.5, col+.5], 'k-', 'LineWidth',.1)
        yline(ax, [row-.5, row+.5], 'k-', 'LineWidth',.1)
        
        h.Position(3:4) = [500 200] ;
        exportitle = ['peaks_' str '_' timeres{itimeres}] ;
        exportitle = [exportitle '.pdf'] ;
        exportgraphics(gcf,exportitle,'ContentType','vector')
    end
end
