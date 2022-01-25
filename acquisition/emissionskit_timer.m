function emissionskit_timer
    ENTSOETimer = timer('Tag', 'ENTSOETimer') ;
    set(ENTSOETimer,'executionMode','fixedRate', "Period", 180, "TimerFcn", @called_by_timer)
    
    PlotlyTimer = timer('Tag', 'PlotlyTimer') ;
    set(PlotlyTimer,'executionMode','fixedRate', "Period", 15*60, "TimerFcn", @calledplot_by_timer)
    
    start(ENTSOETimer) ;
    start(PlotlyTimer) ;
end