function PostCode = getNUTS
    FP = mfilename('fullpath') ;
    FP = strsplit(FP,filesep)   ;
    FP = FP(1:end-2)            ;
    fullpath = strjoin([FP {'input'} {'general'}],filesep) ;
    
    % Load all the csv files and postcode from EU
    NUTPath = [fullpath filesep 'pc2020_NUTS-2021_v4.0'] ;
    listing = dir(NUTPath) ;
    for icsv = 1:length(listing)
        switch listing(icsv).name
            case {'.','..','.MATLABDriveTag'}
                continue ;
            otherwise
                Countrycode = strsplit(listing(icsv).name,'_') ;
                Countrycode = Countrycode{2} ;
                PostCode.(['NUT' Countrycode]) = readtable([NUTPath filesep listing(icsv).name],'Delimiter',',');
        end
    end
end