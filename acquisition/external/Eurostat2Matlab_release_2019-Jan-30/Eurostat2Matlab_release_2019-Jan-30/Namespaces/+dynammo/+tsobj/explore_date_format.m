function processed_format = explore_date_format(dateformat)
%
% Input date format pattern is case sensitive !!!
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Auto case

processed_format = struct();

if ~ischar(dateformat)
    error_msg('Range processing','Date format should be entered as a string...');
    
elseif strcmpi(dateformat,'auto')% Standard case
    processed_format.user_dataformat = '';
    return
end

%% Body
    
% Date formating: '2001', '2001q3', '2001m9' - other format types
%                 and daily data format available if dateformat
%                 passed in as an argument, e.g. 'yyyy.m', 'yy-q',
%                 'mm/dd/yyyy', 'yyQq', et cetera
orig_format = dateformat;
%dateformat = upper(dateformat); %-> 96Q1 needs to be processed case sensitive!

% Delimiter identification (type irrelevant)
delimiter = unique(regexprep(dateformat,'(d|m|q|y)',''));
if length(delimiter)>1
    error_msg('Range processing','Date format: Multiple delimiter types declared...');
    
elseif length(delimiter)==1 % Standard yyyy/mm case
    dateformat_split = regexp(dateformat,sprintf('\\%s',delimiter),'split');

    findyear = find(~cellfun('isempty',strfind(dateformat_split,'y')));
    findq    = find(~cellfun('isempty',strfind(dateformat_split,'q')));
    findm    = find(~cellfun('isempty',strfind(dateformat_split,'m')));
    findd    = find(~cellfun('isempty',strfind(dateformat_split,'d')));
    if isempty(findyear)
        error_msg('Range processing','Date format: "Year" must be always specified...',orig_format);
    end

    processed_format.user_dataformat = orig_format;
    processed_format.dateformat_split = dateformat_split;
    processed_format.findyear = findyear;
    processed_format.findq = findq;
    processed_format.findm = findm;
    processed_format.findd = findd;
    processed_format.delimiter = delimiter;

elseif isempty(delimiter) % length 0 case also
    processed_format.user_dataformat = orig_format;
    processed_format.delimiter = '';

end

end %<eof>