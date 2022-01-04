function isforeign = isforeign_region
    allmonth_local = getmonthnamesmx('shortloc') ;
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
    isforeign = ~isempty(setdiff(allmonth_local,allmonth_EN)) ;