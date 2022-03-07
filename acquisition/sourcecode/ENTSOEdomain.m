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

countrydomain = cellfun(@(x) strsplit(x,{'_','-'}), countrylist', 'UniformOutput', false) ;

for idomain = 1:length(countrydomain)
    countrylist2(idomain) = countrydomain{idomain,1}(1) ;
end

domain(:,1) = ENTSOElist.countrycode(contains(countrylist2, countrycode))   ;
domain(:,2) = ENTSOElist.domain(contains(countrylist2, countrycode)) ;