function data3 = loadEUfuelmonth

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

data3 = jsondecode(fileread([fparts{1} filesep 'input' filesep 'general' filesep 'json_result_merged.json'])) ;
%data3 = jsondecode(fileread('json_result_merged.json'));
allgeo = fieldnames(data3) ;

for igeo = 1:length(allgeo)
    geo = allgeo{igeo} ;   
    
    Timearray = cat(1, data3.(geo)(:).Time) ;
    Timearray = datetime(Timearray,'InputFormat','dd-MMM-uuuu') ;
    
    data3.(geo) = rmfield(data3.(geo),'Time') ;
    allfields = fieldnames(data3.(geo)) ;
    varnames = {} ;
    powerout = [] ;
    for ifield = 1:length(allfields)
        switch allfields{ifield}
            case {'Minutes5UTC' 'Minutes5DK' 'PriceArea'}
    
            otherwise
                datain = {data3.(geo)(:).(allfields{ifield})}';
                dataempty = cellfun(@(x) isempty(x), datain) ;
                datain(dataempty) = {NaN} ;
                powerout.(makevalidstring(allfields{ifield})) = cell2mat(datain) ;
                varnames = [varnames allfields(ifield)];
        end
    end
    data3.(geo) = array2timetable(struct2array(powerout), 'RowTimes', Timearray, 'VariableNames',varnames) ;
end