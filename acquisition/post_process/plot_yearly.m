function plot_yearly

%% Set up the figure

EFSourcelist = {'EcoInvent' 'ET' 'ETS' 'electricitymap_Emissions'} ;

startyear = 2013 ;
endyear = 2021 ;

for isource = 1:length(EFSourcelist)
    source                          = EFSourcelist{isource} ;
    fig.(source) = figure ;
    axs.(source) = axes(fig.(source)) ;
    if ~ishold(axs.(source))
        hold(axs.(source)) ;
    end
    xlabel(axs.(source), 'Time [Month]')
    ylabel(axs.(source), 'Variations of means and \sigma [%]')
    xlim([1 12]) ;
%     title(axs.(source), source)
    legend(axs.(source), cellstr(string(2013:2021)))
end

%% Get the data 

for iyear = startyear:endyear
    Power = load(['Power_' num2str(iyear) '.mat']) ;
    Power = Power.Power ;

    out.(['x' num2str(iyear)]) = comparemethod(Power, false) ;
    
    Emissions = load(['Emissions_alternative1' num2str(iyear) '.mat']) ;
    Emissions = Emissions.Emissions ;
    %% extract data for each year to compare with the energia teolisuus data and the EU-ETS registry
    
    for isource = 1:length(EFSourcelist)
        source                          = EFSourcelist{isource} ;
        yearextract                     = Emissions.Finland.TSO.([source '_realised']).total ;
        tempstat.(['x' num2str(iyear)]).(source).bymonth = analyse_by_month(yearextract) ;
            ETSreg                          = yearextract(:,{'gas', 'oil', 'coal', 'peat'}) ;
            ETSreg2                         = retime(ETSreg, 'hourly', @(x) mean(x, 'omitnan')) ;
            outETS.(['x' num2str(iyear)])(1,isource)	= sum(sum(ETSreg2.Variables, 2))/1000 ;
        try
            yearextract                     = Emissions.Finland.ENTSOE.(source).total ;
                ETSreg                          = yearextract(:,'Var1') ;
                ETSreg2                         = retime(ETSreg, 'hourly', @(x) mean(x, 'omitnan')) ;
                outETSENTSOE.(['x' num2str(iyear)])(1,isource)	= sum(sum(ETSreg2.Variables, 2))/1000 ;
        catch
            
        end
        yearextract                     = Emissions.Finland.TSO.([source '_allyear']).total ;
        tempstat.(['x' num2str(iyear)]).(source).byyear = analyse_by_month(yearextract) ;
            ETSreg                          = yearextract(:,{'gas', 'oil', 'coal', 'peat'}) ;
            ETSreg2                         = retime(ETSreg, 'hourly', @(x) mean(x, 'omitnan')) ;
            outETSallyear.(['x' num2str(iyear)])(1,isource)	= sum(sum(ETSreg2.Variables, 2))/1000 ;

        diff_timing.(['x' num2str(iyear)]).(source).mean = (tempstat.(['x' num2str(iyear)]).(source).byyear.mean ./ tempstat.(['x' num2str(iyear)]).(source).bymonth.mean - 1)*100 ;
        diff_timing.(['x' num2str(iyear)]).(source).sum = (tempstat.(['x' num2str(iyear)]).(source).byyear.sum ./ tempstat.(['x' num2str(iyear)]).(source).bymonth.sum - 1)*100 ;
        diff_timing.(['x' num2str(iyear)]).(source).std = (tempstat.(['x' num2str(iyear)]).(source).byyear.std ./ tempstat.(['x' num2str(iyear)]).(source).bymonth.std - 1)*100 ;
        diff_timing.(['x' num2str(iyear)]).(source) = struct2table(diff_timing.(['x' num2str(iyear)]).(source)) ;
        
        if ~ishold(axs.(source))
            hold(axs.(source)) ;
        end
        errorbar(axs.(source), diff_timing.(['x' num2str(iyear)]).(source).mean,diff_timing.(['x' num2str(iyear)]).(source).std, 'DisplayName', num2str(iyear));
    end
%      save((['Power_' num2str(datestart.Year) '.mat']), 'Power') ;
%      save((['Emissions_alternative1' num2str(iyear) '.mat']), 'Emissions') ;
end
hold off ;   

% for isource = 1:length(EFSourcelist)
%     source                          = EFSourcelist{isource} ;
% %     fig.(source) = figure ;
% %     axs.(source) = axes(fig.(source)) ;
%     set(axs.(source),'fontname','times new roman')
%     set(axs.(source),'FontSize', 12)
%     exportitle = ['Month_annual_' source '.pdf'] ;
%     exportgraphics(axs.(source),exportitle,'ContentType','vector') ;
% end

%% Get the statistical mean
isource = {'EcoInvent' 'electricitymap_Emissions'} ;
allyears = fieldnames(diff_timing) ;
for is = 1:length(isource)
    isname = isource{is} ;
    for iy = 1:length(allyears)
        iyear = allyears{iy} ;
        if iy == 1
            meantemp = diff_timing.(iyear).(isname).mean ;
            sumtemp = diff_timing.(iyear).(isname).sum ;
            stdtemp = diff_timing.(iyear).(isname).std ;
        else
            meantemp = [meantemp;diff_timing.(iyear).(isname).mean] ;
            sumtemp = [sumtemp;diff_timing.(iyear).(isname).sum] ;
            stdtemp = [stdtemp;diff_timing.(iyear).(isname).std] ;
        end
    end

    meantemp = array2timetable(meantemp, 'RowTimes', datetime(startyear,1,1):calmonths(1):datetime(endyear,12,1)) ;
    sumtemp = array2timetable(sumtemp, 'RowTimes', datetime(startyear,1,1):calmonths(1):datetime(endyear,12,1)) ;
    stdtemp = array2timetable(stdtemp, 'RowTimes', datetime(startyear,1,1):calmonths(1):datetime(endyear,12,1)) ;
    
    wintermeantemp = meantemp(or(meantemp.Time.Month <= 4,meantemp.Time.Month > 10),:) ;
    wintersumtemp = sumtemp(or(sumtemp.Time.Month <= 4,sumtemp.Time.Month > 10),:) ;
    winterstdtemp = stdtemp(or(stdtemp.Time.Month <= 4,stdtemp.Time.Month > 10),:) ;
    
    summermeantemp.(isname) = meantemp(and(meantemp.Time.Month > 4,meantemp.Time.Month <= 10),:) ;
    summersumtemp.(isname) = sumtemp(and(sumtemp.Time.Month > 4,sumtemp.Time.Month <= 10),:) ;
    summerstdtemp.(isname) = stdtemp(and(stdtemp.Time.Month > 4,stdtemp.Time.Month <= 10),:) ;
    
    wintermean.(isname) = mean(meantemp(or(meantemp.Time.Month <= 4,meantemp.Time.Month > 10),:).Variables,1,'omitnan') ;
    summermean.(isname) = mean(meantemp(and(meantemp.Time.Month > 4,meantemp.Time.Month <= 10),:).Variables,1,'omitnan') ;
    wintersum.(isname) = mean(sumtemp(or(sumtemp.Time.Month <= 4,sumtemp.Time.Month > 10),:).Variables,1,'omitnan') ;
    summersum.(isname) = mean(sumtemp(and(sumtemp.Time.Month > 4,sumtemp.Time.Month <= 10),:).Variables,1,'omitnan') ;
    winterstd.(isname) = mean(stdtemp(or(stdtemp.Time.Month <= 4,stdtemp.Time.Month > 10),:).Variables,1,'omitnan') ;
    summerstd.(isname) = mean(stdtemp(and(stdtemp.Time.Month > 4,stdtemp.Time.Month <= 10),:).Variables,1,'omitnan') ;
end
%% extract data for each month to compare with the energia teolisuus data
out = orderfields(out) ;
fuel = {'coal','biomass','gas','peat','others','oil','CHP','sep'} ;
yearsout = fieldnames(out) ;
xl = regexprep(yearsout,'x','') ;
xl = str2double(xl)' ;
for ifuel = 1:length(fuel)
    for iyears = 1:length(yearsout)
        yearname = yearsout{iyears};
        if iyears == 1
            outtot.(fuel{ifuel}) = out.(yearname).(fuel{ifuel}).Variables ;
        else
            outtot.(fuel{ifuel}) = [outtot.(fuel{ifuel});out.(yearname).(fuel{ifuel}).Variables] ;
        end
    end
end

yearsout = fieldnames(outETS) ;

for iyears = 1:length(yearsout)
    yearname = yearsout{iyears};
    if iyears == 1
        outtotETS = outETS.(yearname) ;
    else
        outtotETS = [outtotETS ;outETS.(yearname)] ;
    end
end

outtotETS = array2table(outtotETS, 'VariableNames', EFSourcelist, 'RowNames', fieldnames(outETSallyear)) ;

figure ;
legendname = {} ;
for ifield = 1:length(EFSourcelist)
    legendname{end+1} = [EFSourcelist{ifield} '-monthCoeff'] ;
    plot(xl,outtotETS.(EFSourcelist{ifield}),'DisplayName',[EFSourcelist{ifield} '-monthCoeff']) ;
    hold on
end


yearsout = fieldnames(outETSallyear) ;

for iyears = 1:length(yearsout)
    yearname = yearsout{iyears};
    if iyears == 1
        outETSallyearETS = outETSallyear.(yearname) ;
    else
        outETSallyearETS = [outETSallyearETS ;outETSallyear.(yearname)] ;
    end
end
outETSallyearETS = array2table(outETSallyearETS, 'VariableNames', EFSourcelist, 'RowNames', fieldnames(outETSallyear)) ;

for ifield = 1:length(EFSourcelist)
    legendname{end+1} = [EFSourcelist{ifield} '-yearCoeff'] ;
    plot(xl,outETSallyearETS.(EFSourcelist{ifield}),'DisplayName',[EFSourcelist{ifield} '-yearCoeff']) ;
    hold on
end
set(gca,'fontname','times new roman')
set(gca,'FontSize', 12)
xlabel('Time [year]')
ylabel('Gross CO_{2} emissions [ktCO2]')
legend(legendname)
hold off

yearsout = fieldnames(outETSENTSOE) ;

for iyears = 1:length(yearsout)
    yearname = yearsout{iyears};
    if iyears == 1
        outENSTOE = outETSENTSOE.(yearname) ;
    else
        outENSTOE = [outENSTOE ;outETSENTSOE.(yearname)] ;
    end
end
outENSTOE = array2table(outENSTOE, 'VariableNames', EFSourcelist, 'RowNames', fieldnames(outETSallyear)) ;

resultstemp = stat_CO2intens ;



end


