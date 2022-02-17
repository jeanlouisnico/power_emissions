function domain = ENTSOEdomain(countrycode)


p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

val = jsondecode(fileread([fparts{1} filesep 'input' filesep 'general' filesep 'ENTSOElist2.json']));
idx = cellfun('isempty',{val(:).countrycode});
countrylist = cellfun(@(x) x, {val(~idx).countrycode}, 'UniformOutput', false) ;
countrydomain = cellfun(@(x) x, {val(~idx).query}, 'UniformOutput', false) ;
area = cellfun(@(x) x, {val(~idx).areas}, 'UniformOutput', false) ;
ENTSOElist = [countrylist' , countrydomain', area'] ;
ENTSOElist = cell2table(ENTSOElist, 'VariableNames', {'countrycode' 'domain' 'area'}) ;

domain = ENTSOElist.domain(ismember(ENTSOElist.countrycode, countrycode)) ;