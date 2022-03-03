function nameout = makevalidlegend(bidname)

nameout = strrep(lower(bidname),' ','-') ;
            nameout = strrep(nameout, '/', '-') ;
            nameout = strrep(nameout, '-', '-') ;
            nameout = strrep(nameout, '_', '-') ;