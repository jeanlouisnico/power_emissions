function out = parser_json(table,dbobj,check_filter)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Collect JSON query responses

%Query design
json_query = dynammo.EUROSTAT.json_ini();

% Pick table
json_query = strrep(json_query,'#table_name#',table);

%% Collect JSON query responses

% Filtering criteria 
% -> filtglue is potentially multidimensional reflecting the possibility of multiple selection,
%    1 query per data dimension is assumed
[filtGlues,technames] = dynammo.EUROSTAT.filter_resolution_json(dbobj);
    
JSON_resp = cell(size(filtGlues));
nqueries = length(JSON_resp);

for ir = 1:nqueries
    
    % Status msg
    if nqueries==1
        fprintf('\nCollecting server response (in JSON format)...'); 
    else
        if ir==1
            fprintf(['\nCollecting server response (in JSON format) - series 1/' sprintf('%.0f',nqueries) '...']);
        elseif ir<=10 % one backspace needed
            fprintf(['Collecting server response (in JSON format) - series ' sprintf('%.0f',ir) '/' sprintf('%.0f',nqueries) '...']);
        else
            fprintf(['Collecting server response (in JSON format) - series ' sprintf('%.0f',ir) '/' sprintf('%.0f',nqueries) '...']);
        end
    end
    
    % Prepare current JSON query
    query_now = strrep(json_query,'#userFilters#',filtGlues{ir});
    
    % Give it several attempts to download the data
    attempt = 1;
    while true
        [JSON_resp{ir},status] = urlread(query_now);
        if status==1
            break
        end
        if attempt==9
            error_msg('EUROSTAT download','Problem with JSON response - try this link in your browser:',strrep(query_now,'"',''));
        elseif attempt==2
            fprintf('\n                                            ...attempt #1');
            fprintf('\n                                            ...attempt #2');
        elseif attempt~=1
            fprintf(['\n                                            ...attempt #' sprintf('%.0f',attempt)]);
        end
        attempt = attempt+1;
        pause(0.2+rand()); % This is important, otherwise EUROSTAT could cut us off!
    end
    
    fprintf('OK!\n');
    
end



%% Completeness of filtering criteria supplied by user
% -> applies to web based query only
% keyboard;
if check_filter
    % All filtering options taken from JSON response
    % -> Perhaps we only need to check one of the server responses (the rest should have equivalent form, except for 1 dimension)
    
    % >>> Used to work    <<<
    %allcrit = regexp(JSON_resp{1},'(?<="dimension":{"id":[).*?(?=])','match');
    % >>> Should work now <<<
     allcrit = regexp(JSON_resp{1},'(?<="id":[).*?(?=])','match');
      
    allcrit = regexp(allcrit,',','split');
    allcrit = allcrit{1};
    allcrit = strrep(allcrit,'"','');
    allcrit = allcrit(:);
    allcrit = allcrit - 'time';% Time is included by default, no specification needed by the user
    
    % User-supplied filters (based on web query builder)
    byUser = fieldnames(dbobj.filter);
    isok = ismember(allcrit,byUser);
    if ~all(isok)
       error_msg('JSON parser',['User-supplied (web based) query does not ' ...
                                'specify some filtering criteria which are ' ...
                                'mandatory:'],allcrit(~isok)); 
    end
    
end

%% Data processing

fprintf('\nPostprocessing time series...'); 

for ir = 1:nqueries
    
    % Extract dates
    range = regexp(JSON_resp{ir},'(?<={"label":"time","category":{"index":{).*?(?=})','match');
    range = regexp(range,',','split');
    range = range{1};
    range_labels = cellfun(@(x) regexp(x,'(?<=").*?(?=")','match'),range);
    range_labels = range_labels(:);
    indices = cellfun(@(x) regexp(x,'(?<=":).*','match'),range);
    indices = indices(:);
    
    % Extract values
    vals = regexp(JSON_resp{ir},'(?<="class":"dataset","value":{).*?(?=})','match');
    if ~isempty(strfind(vals{1},'{')) % empty {} cannot be captured by the above regex
        vals = {'NaN'};
        vals_dt = indices(1);
    else
        vals = regexp(vals,',','split');
        vals = vals{1};
        vals_dt = cellfun(@(x) regexp(x,'(?<=").*?(?=")','match'),vals);
        vals_dt = vals_dt(:);
        vals = cellfun(@(x) regexp(x,'(?<=":).*','match'),vals);
        vals = vals(:);
    end
    
    % Dates vs. values mapping
    [~,where] = ismember(vals_dt,indices);
    if any(where==0)
        error_msg('JSON parser','Unknown dates in JSON response:',vals_dt(where==0));
    end
    range_taken = range_labels(where);
    
    % If mixed frequencies encountered, take the one with longer length
    % e.g. 1975, 1975Q1, 1975Q2, 1975Q3, 1975Q4, 1976, 1976Q1, ...
    lengths = cellfun('length',range_taken);
    takenrows = lengths==max(lengths);
    if ~all(takenrows)
        range_taken = range_taken(takenrows);
        vals = vals(takenrows);
    end
    
    % Sort data according to date info
    % -> sorting on string input works well (on M01 and D01 convention)
    sorted = sortrows([range_taken vals],1);
    range_taken = sorted(:,1);
    vals = sorted(:,2);
    
    % Guess frequency
    guineapig = range_taken{1};
    if length(guineapig)==10
        freq = 'D';
        range_taken = regexprep(range_taken,'(D|M)','-');
    elseif ~isempty(strfind(guineapig,'Q'))
        freq = 'Q';
    elseif ~isempty(strfind(guineapig,'M'))
        freq = 'M';
        range_taken = strrep(range_taken,'M0','M');
    else
        freq = 'Y';
    end
    
    % Series concatenation - range resolution
    % -> frequency mismatch should not occur here...
    if ir==1
        prev_freq = freq;
        
        % Bridge missing data
        bounds = range2tind({range_taken{1};range_taken{end}});
        [tind,new_range] = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));        
        
        % Missing entries
        nanvalues = nan(length(new_range),1);%size(vals,2));
        [~,found] = ismember(range_taken,new_range);
        try
            vals = cellfun(@eval,vals);
        catch
            error_msg('JSON parser','Some of the following values cannot be easily converted to a numeric vector:',vals);
        end
        nanvalues(found,:) = vals;
        
        vals = nanvalues;
        range = new_range;
        
        vals_cont = vals;
        range_cont = range;
        tind_cont = tind;
        
    else
        
        % Check for frequency mismatch
        if ~strcmp(freq,prev_freq)
           error_msg('JSON parser',['Frequency mismatch has occurred. The ' ...
                                    'time series do not share the same ' ...
                                    'frequency, it is suggested to divide ' ...
                                    'the downloading process into 2 or ' ...
                                    'more sub-downloads...']); 
        end
        
        % Bridge missing data
        tindnow = range2tind({range_taken{1};range_taken{end}});
        %tindnow = tind_spit({range_taken{1},range_taken{end}},freq);

        % Compare ranges
        newtind_start  = min(tindnow(1),tind_cont(1));
        newtind_finish = max(tindnow(2),tind_cont(end));

        % Range augmentation
        if tind_cont(1)  >newtind_start || ...
           tind_cont(end)<newtind_finish

            % Update container
            [tind_cont,full_range] = dynammo.tsobj.tind_build(freq,newtind_start,newtind_finish);
            
        else % we stay within previously defined boundaries
            full_range = range_cont;

        end

        % Missing values treatment
        nanvalues = nan(length(full_range),size(vals_cont,2)+1);% +1 for newly appended series
        [~,found_old] = ismember(range_cont, full_range);
        [~,found_new] = ismember(range_taken,full_range);
        try
            vals_num = cellfun(@eval,vals);
        catch
            error_msg('JSON parser','Some of the following values cannot be easily converted to a numeric vector:',vals);
        end
        nanvalues(found_old,1:end-1) = vals_cont;            
        nanvalues(found_new,end) = vals_num;            

        % Update containers
        vals_cont = nanvalues;
        range_cont = full_range;
        
    end

end

%% Lower quality data treatment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -> JSON format does not seem to face this issue :)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% values = cellfile(2:end,2:end);%cellfile([false;takenrows],2:end);%
% values = regexprep(values,':.*?','NaN');% Missing values treatment
% try
%     values = cellfun(@eval,values);
% catch
%     try
%         fprintf('[lower quality data also present]...');
%         % Get rid of alphabetic left overs
%         values = regexprep(values,'NaN','#@');
%         values = regexprep(values,'[a-zA-Z]','');
%         values = regexprep(values,'#@','NaN');
% %         values = regexprep(values,'(?<=\d.*)[a-zA-Z ]','');
% 
%         values = cellfun(@eval,values);
%     catch
%         keyboard;
%     end
% end
% 
% if flipped==1
%    values = flipud(values); 
% end

%% Names assignment

technames = technames(:);

% Names are empty, but in EUROSTAT_download are replaced by .dic contents
names = cell(length(technames),1);
names(:) = {''};

%% Output for tsobj() class constructor

out.techname = technames;
out.name = names;
out.frequency = freq;
out.values = vals_cont;
out.tind = tind_cont;
out.range = range_cont;

fprintf('OK!\n');

end %<eof>