function dateHEX = timeURL(datein, exceptions)

datein = datestr(datein,'yyyy-mm-dd HH:MM:ss') ;
dateHEX = [] ;
for ichar = 1:length(datein)
    if isnan(str2double(datein(ichar)))
        if ~any(strcmp(datein(ichar),exceptions))
            charin = ['%' sprintf('%X', datein(ichar))] ;
        else
            charin = datein(ichar) ;
        end
    else
        charin = datein(ichar) ;
    end

    dateHEX = [dateHEX charin] ;
end

