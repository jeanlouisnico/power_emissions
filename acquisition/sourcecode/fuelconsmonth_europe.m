function data5 = fuelconsmonth_europe

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

inputfile = [fparts{1} filesep 'input' filesep 'general' filesep 'json_result_merged.json'] ;

if isfile(inputfile)
    FileInfo = dir(inputfile) ;
    datecompare = datetime("now") ;
    datefile    = datetime(FileInfo.datenum, "ConvertFrom", "datenum") ;

    % Check daily if the data have changed
    if ~(datecompare.Year == datefile.Year && datecompare.Month==datefile.Month && week(datecompare)==week(datefile) && minute(datecompare)==minute(datefile))
        start(timer('StartDelay',5, 'TimerFcn',@(~,~)delay_extract));
        data5 = loadEUfuelmonth ;
    else
        data5 = loadEUfuelmonth ;
    end
else
    start(timer('StartDelay',5, 'TimerFcn',@(~,~)delay_extract));
    data5 = loadEUfuelmonth ;
end
disp('function completed')
    function delay_extract
        !"matlab.exe" -batch "declarepath"
    end
    function dataout = convert2timetable(obj)
        match = [" ",":"];
        time = cellfun(@(x) strsplit(x, 'M'), obj.range, 'UniformOutput', false) ;
        time = cellfun(@(x) datetime(str2double(x{:,1}), str2double(x{:,2}),1), time, 'UniformOutput', false) ;
        array = [time{:}]';
        dataout = timetable(obj.values, 'RowTimes', array) ;
    end

end
