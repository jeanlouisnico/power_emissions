function [tind,range,values,freq,names,technames] = process_imported_data(cellfile,dateformat)
%
% Reveal time series information from a imported file 
%
% INPUT: cellfile ...cell of text information
%        dateformat ...useful for daily data only (e.g. yyyy-mm-dd)
%
% OUTPUT: tsobj() properties
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Process names
technames = transpose(cellfile(1,2:end));
validnamesind = find(~cellfun('isempty',technames));
technames = technames(validnamesind);
 
% Duplicities not allowed
if length(unique(technames))~=length(technames)
    technames = sort(technames);
    dupl_pos = strcmp(technames,[technames(2:end);' ']);
    black_list = unique(technames(dupl_pos));
    error_msg('csvload()','Imported data contain duplicities:',black_list);
end

% Valid technames are never empty, but names are not always defined
names = cellfile(2,2:end)';
names = names(validnamesind);
 
%% Date formatting
processed_format = dynammo.tsobj.explore_date_format(dateformat);

%% Range processing

range = cellfile(:,1);

% Daily data saved with leading apostrophe ('2011-04-29, to prevent XLS date format conversion)
if iscellstr(range(3:end)) % Range can be of type 'double' when loaded from spreadsheet (yearly data)
    pat_ = {''''; % This matters for daily data
            '"'   % This matters for external tseries() data
           };
    range(3:end) = regexprep(range(3:end),pat_,'');
end

cellrange = cell(size(range,1),1);
tind = nan(size(range,1),1);
tind_last = 0;
freq_first = true;
blacklist = cell(0,1);
warning_shown = 0;
% keyboard;


for ii = 3:size(range,1) % 1] techname, 2] comment (name), 3] first possible data row
    
    % keyboard;
    
    % [1] Input as 'char'
    if isempty(range{ii}) % Empty rows in the input file
        continue % w/o blacklisting
    end
    if isa(range{ii},'double')
        % 2001.4 (yyyy.q) case might be recognized as double
        range{ii} = sprintf('%g',range{ii});
    end
    if ~ischar(range{ii}) % + no longer 'double'
        blacklist = [blacklist;class(range{ii})]; %#ok<*AGROW>
        continue 
    end
    
    % [2] User-supplied date format 
    if ~isempty(processed_format.user_dataformat)
        oldrng = range{ii};
        range{ii} = dynammo.tsobj.deal_dateformat(range{ii},processed_format);
        if isempty(range{ii})
            blacklist = [blacklist;oldrng]; 
            continue
        end        
    end
    
    % [3] Range processing (individual)
    [tind(ii),cellrange(ii),freq,success] = dynammo.tsobj.process_range_individual(range{ii});
    if success==0
        blacklist = [blacklist;range{ii}]; 
        continue
    end
    
    % [4] Ex post checks
    if freq_first
            freq_last = freq;
            freq_first = false;
    end
    if ~strcmp(freq,freq_last)
        error_msg('Imported data processing','Mixed data frequencies not allowed',[freq_last '-vs-' freq]); 
    end
    if warning_shown==0 && tind(ii) <= tind_last
        
        warning_msg('Imported data processing',['The timing in DB should ' ...
                     'form a consecutive series, sorting '...
                     'will be applied...'],cellrange(ii));
        warning_shown = 1;
    end
    tind_last = tind(ii);
   
end

% Only numeric dates in blacklist retained
blacklist = blacklist(~cellfun('isempty',regexp(blacklist,'\d*','match')));
if ~isempty(blacklist)
   warning_msg('Data input','Following dates skipped (unrecognized):',blacklist);
end

% Any recognized data?
if freq_first
   dynammo.error.tsobj('Data input: No data loaded, date format probably unrecognized, check also the delimiter...'); 
end

validdatesind = find(~cellfun('isempty',cellrange));
%range = cellrange(validdatesind);
tind  = tind(validdatesind);
 
%% Process data
% keyboard;
values = cellfile(validdatesind,validnamesind+1);
validvalues = nan(size(values));
% for ii = 1:size(values,1)
%     for jj = 1:size(values,2)
% %         try %#ok<TRYNC>
%             if isa(values{ii,jj},'double')
%                 validvalues(ii,jj) = 	  values{ii,jj} ; 
%             else
%                 try %#ok<TRYNC>
%                     validvalues(ii,jj) = eval(values{ii,jj}); 
%                 end
%             end
% %         end
%     end
% end
% keyboard;
for jj = 1:size(values,2)
    try % Vectorized attempt
        validvalues(:,jj) = cellfun(@eval,values(:,jj));
    catch %#ok<CTCH> % Piece by piece attempt
        for ii = 1:size(values,1)
            if isa(values{ii,jj},'double')
                validvalues(ii,jj) = 	  values{ii,jj} ; 
            else
                try %#ok<TRYNC>
                    validvalues(ii,jj) = eval(values{ii,jj}); 
                end
            end
        end
    end
end
 
%% Sorting data according to time index

[sortedval,ind] = sort(tind,1,'ascend');
 
testcrit = abs(   zeros(length(ind)-1,1) - ...
                 (sortedval(1:end-1,1)-sortedval(2:end,1)) ...
              ) < 1e-10;
if any(testcrit)
    
   dynammo.error.tsobj(['csvload: Input date string used more than ' ...
              'once, must be unique...']); 
end
tinddata = tind(ind);
%range = range(ind);
validvalues = validvalues(ind,:);
 
%% Bridge missing data

[tind,range] = dynammo.tsobj.tind_build(freq,tinddata(1),tinddata(end));

values = nan(length(range),size(validvalues,2));
%[~,found] = ismember(range,new_range);
found = ismembc2(tinddata,tind);

values(found,:) = validvalues;
% range = new_range;
% tind = new_tind;

end %<eof>