function out = unloaddata(datain, var, EmissionsCategory, EmissionsDB, cc)
    switch var
        case 'TSO'
            % May add a method for using TSO data directly
            out = 0 ;
        case 'emissionskit'
            out = emissionsEK(datain.(var), EmissionsCategory, EmissionsDB, cc) ;
        otherwise
            if isa(datain.(var),'struct')
                sublst = fieldnames(datain.(var)) ;
                for isublst = 1:length(sublst)
                    out = unloaddata(datain.(var), sublst{isublst}, EmissionsCategory, EmissionsDB, cc) ;
                end
            else
                out = 0 ;
            end
    end