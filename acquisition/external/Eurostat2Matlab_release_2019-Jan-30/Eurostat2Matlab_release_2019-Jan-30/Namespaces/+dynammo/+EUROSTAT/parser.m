function out = parser(file,dbobj)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Open file

fid = fopen(file,'r');
if fid == -1
    error_msg('EUROSTAT download','Cannot open locally downloaded file:',file);
end

%% Filtering string

if ~isempty(dbobj.filter)
    [filtglue,multipleSelection,multiwhere] = dynammo.EUROSTAT.filter_resolution(dbobj);

end

%% Read from file line by line and create a cell matrix

% Pre-allocation
rowc = 1e6;% Regular pre-allocation if the data are organized rather vertically
colc = 1;
nline = 1;
line = fgets(fid);

delimiter = '\t';% always a TAB in the EUROSTAT DB

% Get series pattern of the time series in current table
% + Quit
if isempty(dbobj.filter)
    linenow = regexp(line,delimiter,'split');
    linestart = linenow{1};
    
    %fprintf('\n --- Series pattern in table "%s"\n',file);
    %fprintf(2,' --- %s \n\n',strrep(linestart,'\time',''));
    tmp = strrep(linestart,'\time','');%'';
    
    % Deal with 'time\' swap in the source file
    % -> timing dimension is sometimes along with other vertical dims :(
    if ~isempty(strfind(linestart,'time\'))
        
        % Close the file, it will be modified...
        fclose(fid);
        rehash();
        
        % Modify the original file (transposition)
        dynammo.EUROSTAT.transpose_time(file,delimiter);
        
        % Try again with the modified source file
        out = dynammo.EUROSTAT.parser(file,dbobj);
        return

    end
    
    tmp = regexp(tmp,',','split');
    out.crit_pattern = tmp(:);
    
    % Fetch all column names for multidimensional browsing
    cellfile = cell(rowc,length(regexp(out.crit_pattern,',','split')));
    % -> here the large 'rowc' pre-allocation works even if the data is horizontally wide :)
    
    line = fgets(fid);
    while ischar(line)
        linenow = regexp(line,delimiter,'split','once');
        cellfile(nline,:) = regexp(linenow{1},',','split');%strtrim(linenow);
        
        nline = nline +1;
        line = fgets(fid);

    end
    
    % Drop empty pre-allocated space
    cellfile = cellfile(~cellfun('isempty',cellfile(:,1)),:);
    
    fclose(fid);
    out.crit_sets = cellfile;
    return
    
end

% First line of data is always taken
linenow = regexp(line,delimiter,'split');
horz_width = length(linenow);

% Consider the pre-allocation only if the data seem to be organized rather vertically
if horz_width<=100
    cellfile = cell(rowc,colc);
else
    cellfile = cell(1,1);
end

linenow{1} = strrep(linenow{1},',','__');
if ~isempty(regexp(linenow{1},'(time,|,time,)','once')) % Search for 'time' at the beginning/inside, but not in the last part of linenow
   error_msg('EUROSTAT download','Problem with timing allocation, some EUROSTAT tables are in an unsupported format :(...'); 
end
linenow{1} = strrep(linenow{1},'\time','');

% Deal with 'time\' swap in the source file
% -> this condition handles the usual swap cases
if ~isempty(strfind(linenow{1},'time\'))
        
    % Close the file, it will be modified...
    fclose(fid);
    rehash();

    % Modify the original file (transposition)
    dynammo.EUROSTAT.transpose_time(file,delimiter,dbobj);

    % Try again with the modified source file
    out = dynammo.EUROSTAT.parser(file,dbobj);
    return

end

%% File contents

cellfile(nline,1:horz_width) = strtrim(linenow);
nline = nline +1;
line = fgets(fid);

% keyboard;

fprintf('Postprocessing time series...');  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if multipleSelection % Multiple selection will be a clue for technames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    while ischar(line)
        % keyboard;
        linenow = regexp(line,delimiter,'split');
       
        % Filtering
        if regexp(linenow{1},['\<' filtglue '\>'])==1 % 1 refers to 1st position of the linenow{1} string
            % keyboard;
            linestart = regexp(linenow{1},',','split');
            
            % Techname determined by a multiple selection field
            linenow(1) = linestart(multiwhere);
           
            horz_width = length(linenow);
            cellfile(nline,1:horz_width) = strtrim(linenow);
            nline = nline +1;
        end

        line = fgets(fid);

    end
    
    % Drop empty pre-allocated space
    cellfile = cellfile(~cellfun('isempty',cellfile(:,1)),:);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
else % technames can be a glue of 1st column contents :(, or the table name can be used (now done in EUROSTAT_download())
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    while ischar(line)
%     keyboard;

        linenow = regexp(line,delimiter,'split');
    %     linestart = linenow{1};
    %     linestart = regexp(linestart,',','split'); %#ok<NASGU>

    %     try
    %        taken = eval(filt_str);
    %     catch %#ok<CTCH>
    %        error_msg('EUROSTAT download','Wrong filtering criterion',dbobj.filter); 
    %     end

        % Filtering
        if regexp(linenow{1},['\<' filtglue '\>'])==1;% strrep(linenow{1},'\time','') %taken || nline==1
            %keyboard;
            horz_width = length(linenow);
            
           %linenow{1} = strrep(linenow{1},',','__');% techname as glue
            linenow{1} = 'empty techname for single tsobj()';
            
            %linenow{1} = strrep(linenow{1},'\time',''); % -> only the first line had \time
            %cellfile(nline,1:horz_width) = strrep(linenow,sprintf('\r\n'),'');
            %cellfile(nline,1:horz_width) = strrep(linenow,sprintf('\n'),'');
            cellfile(nline,1:horz_width) = strtrim(linenow);
            nline = nline +1;
        end

        line = fgets(fid);

    end
    
    % Drop empty pre-allocated space
    cellfile = cellfile(~cellfun('isempty',cellfile(:,1)),:);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nline==1
    error_msg('Data download','No data found, perhaps check filtering...');
end

% Close the source file
fclose(fid);

% Transpose + flip upside down
cellfile = transpose(cellfile);
cellfile = cellfile([1 end:-1:2],:);

% Check for emptiness
if size(cellfile,2)==1
   error_msg('Data download','No data on output - the applied filter may be too strict...'); 
end

%% Process names

technames = cellfile(1,2:end);
technames = technames(:);

% Names are empty, but in EUROSTAT_download are replaced by .dic contents
names = cell(length(technames),1);
names(:) = {''};

%% Process range
% -> No input parser needed 
%   (EUROSTAT data should be error free)

range = cellfile(2:end,1);
%range = strrep(range,' ','');

% If mixed frequencies encountered, take the one with longer length
% e.g. 1975, 1975Q1, 1975Q2, 1975Q3, 1975Q4, 1976, 1976Q1, ...
lengths = cellfun('length',range);
takenrows = lengths==max(lengths);
if ~all(takenrows)
    range = range(takenrows);
    cellfile = cellfile([true;takenrows],:);
end

% Guess frequency
guineapig = range{1};
if length(guineapig)==10
    freq = 'D';
    range = regexprep(range,'(D|M)','-');
elseif ~isempty(strfind(guineapig,'Q'))
    freq = 'Q';
elseif ~isempty(strfind(guineapig,'M'))
    % Daily data processed earlier, no conflict here
    freq = 'M';
    [range,where] = sort(range);% -> needed here because 2005M10 would be right after 2005M1
    range = strrep(range,'M0','M');
else
    freq = 'Y';
end

% Some tables, such as BP6, contain non-sorted timing :(
if ~strcmp(freq,'M') % Monthly range processed right above
    [range,where] = sort(range);
end
tmp = cellfile(2:end,:);
tmp = tmp(where,:);
cellfile(2:end,:) = tmp;

% Range direction resolution
tind = tind_build2(range,freq);
flipped = 0;
if isempty(tind)
    flipped = 1;
    tind = tind_build2(flipud(range),freq);
    if isempty(tind)
       error_msg('EUROSTAT download','Time indication was not extracted from given table...'); 
    end    
end

%% Process data

values = cellfile(2:end,2:end);%cellfile([false;takenrows],2:end);%
values = regexprep(values,':.*?','NaN');% Missing values treatment
try
    values = cellfun(@eval,values);
catch
    try
        fprintf('[lower quality data also present]...');
        
        % Get rid of alphabetic left overs
        values = regexprep(values,'NaN','#@');% Encoding...
        values = regexprep(values,'[a-zA-Z]','');
        values = regexprep(values,'#@','NaN');% Decoding...
        values = cellfun(@eval,values);
        
    catch
        keyboard;
    end
end

if flipped==1
   values = flipud(values); 
end

%% Bridge missing data

[tind,new_range] = dynammo.tsobj.tind_build(freq,tind(1),tind(end));

nanvalues = nan(length(new_range),size(values,2));
if flipped==0
    % Do not use ismembc2(), range may not be always sorted!
    [~,found] = ismember(range,new_range);
else
    [~,found] = ismember(flipud(range),new_range);
end

% Debugging
if any(found==0)
   disp(range(found==0));
   keyboard;
end

nanvalues(found,:) = values;

%% Output for tsobj() class constructor

out.techname = technames;
out.name = names;
out.frequency = freq;
out.values = nanvalues;
out.tind = tind;
out.range = new_range;

fprintf('OK!\n');

%% Support functions

    function tind = tind_build2(range,freq)
        % -> Similar to dynammo.tsobj.tind_build, but here we check for ascending tind ordering
        
        if strcmp(freq,'Y')
            tind = cellfun(@eval,range);
            if tind(1)>tind(end)
               tind = []; 
               tind = tind(:);
            end
        elseif strcmp(freq,'Q')
            start_  = eval(range{1}(1:4)) + (eval(range{1}(6))-1)/4;
            finish_ = eval(range{end}(1:4)) + (eval(range{end}(6))-1)/4;
            tind = start_:0.25:finish_;
            tind = tind(:);
        elseif strcmp(freq,'M')
            start_  = eval(range{1}(1:4)) + (eval(range{1}(6:end))-1)/12;
            finish_ = eval(range{end}(1:4)) + (eval(range{end}(6:end))-1)/12;
            tind = floor((start_:(1/12):finish_).*1e4)./1e4;
            tind = tind(:);    
        elseif strcmp(freq,'D')
            % Recipe: round((years(ii)+(months(jj)-1)/12+(days-1)./365).*1e4)./1e4;
            tmp_ = regexprep(range,'-','+1/12*(','once');
            tmp_ = regexprep(tmp_,'-','-1)+1/365*(','once');
            tmp_ = strcat('round((',tmp_,'-1)).*1e4)./1e4');% sprintfc() would not work here
            tind = cellfun(@eval,tmp_);       
            %tind = zeros(length(range),1);
            %for irow = 1:length(range)
            %    tind(irow) = round((eval(range{irow}(1:4)) + (eval(range{irow}(6:7))-1)/12 + (eval(range{irow}(9:10))-1)/365)*1e4)/1e4;
            %end
            if tind(1)>tind(end)
               tind = []; 
               tind = tind(:);
            end           
        end

    end %<tind_build2>

end %<eof>