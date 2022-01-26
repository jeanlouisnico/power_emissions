function  called_by_timer(app, event) 
    try 
        emissionskit ;
    catch me
        disp(datestr(now))
        disp( getReport( me, 'extended', 'hyperlinks', 'on' ) ) ;
        errorlog(getReport( me, 'extended', 'hyperlinks', 'off' )) ;
    end
end