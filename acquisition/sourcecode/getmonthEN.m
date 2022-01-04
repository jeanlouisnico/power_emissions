function monthEN = getmonthEN(date)
    allmonth_local = getmonthnamesmx('shortloc') ;
    datesplit = strsplit(date,'-') ;

    monthlocal = datesplit{2} ;

    
    allmonth_EN    = {'Jan.'
                      'Feb.'
                      'Mar.'
                      'Apr.'
                      'May.'
                      'Jun.'
                      'Jul.'
                      'Aug.'
                      'Sep.'
                      'Oct.'
                      'Nov.'
                      'Dec.' } ;
    monthEN = allmonth_EN(find(strcmp(monthlocal, allmonth_local))==1) ;