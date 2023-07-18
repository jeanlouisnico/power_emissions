function declarepath
    p = mfilename('fullpath') ;
        [filepath,~,~] = fileparts(p) ;
        fparts = split(filepath, filesep) ;
        fparts = join(fparts(1:end), filesep) ;
        
        addpath(genpath([fparts{1} filesep 'acquisition']));

        extractdata_fuel ;
end