function rangeout = deal_dateformat(rangein,processed_format)
%
% Converts given time range into a proper format
%
% INPUT: rangein ...input range (individual date, efficient vectorization not yet solved)
%        dateformat ...string indicating the input date format
%                       (e.g. yyyy/mm/dd, or yyyymmm)
%
% OUTPUT: rangeout ...converted range(s)
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Easy case
if isempty(rangein)
   rangeout = '';
   return
end

% dbrange = rangein;       % Char on input guaranteed
% rangein = upper(rangein);% -> 96Q1 is case sensitive
delimiter = processed_format.delimiter;

%% Body

if length(delimiter)==1 % Standard yyyy/mm case
    
    % User-implied date format (pre-processed)
    %user_dateformat = processed_format.user_dataformat;
    dateformat_split = processed_format.dateformat_split;
    findyear = processed_format.findyear;
    findq    = processed_format.findq;
    findm    = processed_format.findm;
    findd    = processed_format.findd;
    
    % Catch the input delimiter
    delimiter2 = unique(regexprep(rangein,'\d*',''));
    if length(delimiter2)>1
        %error_msg('Range processing','Date format: Multiple delimiter types on input...');
        rangeout = '';
        return        
    end
    
    % Extract parts
    parts = regexp(rangein,sprintf('\\%s',delimiter2),'split');
    
    if length(dateformat_split)~=length(parts)
        %error_msg('Range processing',['Date format: Input dates "' dbrange '" do not match ' ...
        %   'supplied format... ' user_dateformat]);
        rangeout = '';
        return         
    end
    
    % -> year
    findyear = parts{findyear};
    if length(findyear) == 2
        if eval(findyear) < 50
            findyear = ['20',findyear];
        elseif eval(findyear) <= 99
            findyear = ['19',findyear];        
        end
    end
    rangein_glue = findyear;
    
    % -> quarter
    if ~isempty(findq)
        findq = parts{findq};
        rangein_glue = sprintf('%sQ%s',rangein_glue,findq);
    end
    
    % -> month
    if ~isempty(findm)
        if ~isempty(findq)
            %error_msg('Range processing',['Wrong date format: Both months ' ...
            %    'and quarters identified...'],user_dateformat);
            rangeout = '';
            return              
        end
        findm = parts{findm};
        rangein_glue = sprintf('%sM%s',rangein_glue,findm);
        if isempty(findd)
            rangein_glue = strrep(rangein_glue,'M0','M');
        end
    end
    
    % -> day
    if ~isempty(findd)
        if isempty(findm)
            %error_msg('Range processing',['Wrong date format: Daily format ' ...
            %    'requires months to be declared as well...'],user_dateformat);
            rangeout = '';
            return              
        end
        if length(findm)==1
            rangein_glue = strrep(rangein_glue,'M','M0');
        end
        findd = parts{findd};
        rangein_glue = sprintf('%s-%02d',rangein_glue,eval(findd));
        rangein_glue = strrep(rangein_glue,'M','-');
    end
    
    rangeout = rangein_glue;
    
elseif isempty(delimiter) % No delimiter -> e.g. 2014Dec case
    if strcmp(processed_format.user_dataformat,'yyyymmm')
        if ~isempty(strfind(rangein,'JAN'))
            rangeout = [rangein(1:4) 'M1'];
        elseif ~isempty(strfind(rangein,'FEB'))
            rangeout = [rangein(1:4) 'M2'];
        elseif ~isempty(strfind(rangein,'MAR'))
            rangeout = [rangein(1:4) 'M3'];
        elseif ~isempty(strfind(rangein,'APR'))
            rangeout = [rangein(1:4) 'M4'];
        elseif ~isempty(strfind(rangein,'MAY'))
            rangeout = [rangein(1:4) 'M5'];
        elseif ~isempty(strfind(rangein,'JUN'))
            rangeout = [rangein(1:4) 'M6'];
        elseif ~isempty(strfind(rangein,'JUL'))
            rangeout = [rangein(1:4) 'M7'];
        elseif ~isempty(strfind(rangein,'AUG'))
            rangeout = [rangein(1:4) 'M8'];
        elseif ~isempty(strfind(rangein,'SEP'))
            rangeout = [rangein(1:4) 'M9'];
        elseif ~isempty(strfind(rangein,'OCT'))
            rangeout = [rangein(1:4) 'M10'];
        elseif ~isempty(strfind(rangein,'NOV'))
            rangeout = [rangein(1:4) 'M11'];
        elseif ~isempty(strfind(rangein,'DEC'))
            rangeout = [rangein(1:4) 'M12'];
        else
            %error_msg('Date format conversion','Unrecognized month...');
            % Here questionable: do we want to skip unrecognized months??
            rangeout = '';
            return
        end
    else
        error_msg('Date format conversion','Untreated situation...');
        % Keep this error message! We do not want to continue if dateformat is not yet defined...
    end
    
end

end %<eof>