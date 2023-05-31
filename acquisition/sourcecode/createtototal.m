function priceout = createtototal(priceout)

allfields = fieldnames(priceout) ;
priceout.total = [] ;
for icc = 1:numel(allfields)
    getcc = priceout.(allfields{icc}) ;
    if isa(getcc,'timetable')
        timevar = getcc.Properties.DimensionNames{1} ;
        getcc.(timevar).TimeZone = 'UTC' ;
        try
            getcc.Properties.VariableNames = allfields(icc) ;
        catch
            x = 1 ;
        end
        if isempty(priceout.total)
            priceout.total  = getcc;
        else
            priceout.total = synchronize(priceout.total,getcc) ;
        end
    elseif isa(getcc,'struct')
        eachsubcc = fieldnames(getcc) ;
        for isubcc = 1:numel(eachsubcc)
            timevar = getcc.(eachsubcc{isubcc}).Properties.DimensionNames{1} ;
            getcc.(eachsubcc{isubcc}).(timevar).TimeZone = 'UTC' ;
            getcc.(eachsubcc{isubcc}).Properties.VariableNames = eachsubcc(isubcc) ;
            if isempty(priceout.total)
                priceout.total  = getcc.(eachsubcc{isubcc});
            else
                priceout.total = synchronize(priceout.total,getcc.(eachsubcc{isubcc})) ;
            end
        end
    end
end

priceout.total = retime(priceout.total,'regular','previous','TimeStep',minutes(15)) ;