function  called_by_timer(app, event) 
    try 
        msgin = 'Data gathering triggered' ;
        looplog(msgin) ;

        emissionskit ;

        msgin = 'Data gathering finished' ;
        looplog(msgin) ;

    catch me
        disp(datestr(now))
        disp( getReport( me, 'extended', 'hyperlinks', 'on' ) ) ;
        errorlog(getReport( me, 'extended', 'hyperlinks', 'off' )) ;
    end
end