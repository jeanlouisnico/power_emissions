function  calledplot_by_timer(app, event) 
    try 
        testing_refresh_byfuel ;
    catch me
        disp(datestr(now))
        disp( getReport( me, 'extended', 'hyperlinks', 'on' ) )
        errorlog(getReport( me, 'extended', 'hyperlinks', 'off' )) ;
    end
end