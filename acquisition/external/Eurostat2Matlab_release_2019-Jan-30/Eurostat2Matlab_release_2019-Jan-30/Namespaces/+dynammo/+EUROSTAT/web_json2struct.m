function filt = web_json2struct(filt)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Drop table name
filt = regexp(filt,'?','split');
filt = filt{2};

%% Collapse options
filt = regexp(filt,'&','split');
filt = cellfun(@(x) regexp(x,'=','split'),filt,'UniformOutput',false);

% Option names
opt = cellfun(@(x) x{1},filt,'UniformOutput',false);
opt = opt(:);

% Values
vals = cellfun(@(x) x{2},filt,'UniformOutput',false);
vals = vals(:);

%% Minor user-supplied options are neglected from
% -> taken from dynamm.EUROSTAT.json_ini() instead
timing = strcmpi(opt,'time');% -> always thrown away, by default we want all data
precision = strcmpi(opt,'precision');
shortLabel = strcmpi(opt,'shortLabel');
groupedIndicators = strcmpi(opt,'groupedIndicators');
unitLabel = strcmpi(opt,'unitLabel');
sinceTimePeriod = strcmpi(opt,'sinceTimePeriod');
lastTimePeriod = strcmpi(opt,'lastTimePeriod');
test_crit = timing | ...
            precision | ...
            shortLabel | ...
            groupedIndicators | ...
            unitLabel | ...
            sinceTimePeriod | ...
            lastTimePeriod;
if any(test_crit)
   opt = opt(~test_crit); 
   vals = vals(~test_crit); 
end

%% Multidimensional input treatment

unq = unique(opt);
nunq = length(unq);

% Check if request for a collection of time series
if nunq<length(opt) 
   multi = '';
   for ii = 1:nunq
       item_now = unq{ii};
       isthere = strcmp(opt,item_now);
       if sum(isthere)>1
          if isempty(multi) % We have found multi for the 1st time
             multi = item_now; 
             multi_vals = vals(isthere);
             vals = vals(~isthere);
             vals{end+1} = multi_vals;% Multi will be listed as last, this should be irrelevant for JSON query
             optnew = opt(~isthere);
             optnew = [optnew;multi];
             
          elseif ~strcmp(item_now,multi)
              error_msg('JSON query',['Ill-defined JSON query - only one data ' ...
                                      'dimension can contain multiple values ' ...
                                      '(not counting the time dimension). ' ...
                                      'This is a hypercube that you have requested!']);
          end
          
       end
   end
   
else
    optnew = opt;
    
end

%% Check for completeness of options on input
% -> we do this later on in dynammo.EUROSTAT.parser_json()

%% Create standard set of filtering criteria
filt = cell2struct(vals,optnew,1);

end %<eof>