function transpose_time(file,delimiter)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

% Fetch the file contents
file_contents = import_data(file,'delimiter',delimiter);
[~,c] = size(file_contents);

% Find the timing info (order)
% -> this piece of code is redundant if 'filter' is empty, but is needed if non-empty 'filter'
columns = regexp(file_contents{1,1},',','split');
timing_pos = find(~cellfun('isempty',strfind(columns,'time')));% was working time\, but did not identify 'time' in other columns :(

% New structure of columns
newcol = strrep(file_contents{1,1},'time\','');
newcol = [newcol '\time'];

if timing_pos~=c
    disp('Untreated situation...');
    keyboard;% only situation a,b,c,time\d has been handled :(
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
else % Creepy condition passed...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dataOnly = file_contents(2:end,2:end);
    [rr,cc] = size(dataOnly);
    dataOnly = dataOnly.';
    dataOnly = dataOnly(:);
    
    % Headers transposed
    headers = file_contents(1,2:end);
    headers = headers(:);
    headers = repmat(headers,rr,1);
    
    % 1st column (',' delimited)
    col1st = file_contents(2:end,1);
    col1st = regexp(cellfun(@fliplr,col1st,'UniformOutput',false),',','split','once');
    
    timing = cellfun(@(x) x(1),col1st);
    timing = cellfun(@fliplr,timing,'UniformOutput',false);
    unq_timing = unique(timing);
    timing = repmat(timing,1,cc);
    timing = timing.';
    timing = timing(:);
    
    othercols = cellfun(@(x) x(2),col1st);%cellfun(@(x) x(1:c-1),col1st,'UniformOutput',false);
    othercols = cellfun(@fliplr,othercols,'UniformOutput',false);
    
    colprep = cell(cc*rr,1);
    ind = 1:cc:cc*rr;
    for ii = 1:cc
        colprep(ind(:)+ii-1,1) = othercols;
    end
    
    new1stcol = cellfun(@(x,y) [x,',',y],colprep,headers,'UniformOutput',false);
    
    % Process all time blocks
    
    cell_gen = cell(0,1+length(unq_timing));
    cell_gen{1,1} = newcol;
    cell_gen(1,2:end) = unq_timing;
    for ii = 1:length(unq_timing)
        timenow = unq_timing{ii};
        ind = strcmp(timenow,timing);
        
        % 1st column
        cell_gen(end+1:end+sum(ind),1) = new1stcol(ind,1);
        
        % Data
        cell_gen(end-sum(ind)+1:end,1+ii) = dataOnly(ind,1);
        
    end
    
    % Update the original file
    export(cell_gen,'filename',file,'setReadOnly',0,'delimiter','\t');
%      export(cell_gen,'filename','a.tsv','setReadOnly',0,'delimiter','\t')
end

end %<eof>