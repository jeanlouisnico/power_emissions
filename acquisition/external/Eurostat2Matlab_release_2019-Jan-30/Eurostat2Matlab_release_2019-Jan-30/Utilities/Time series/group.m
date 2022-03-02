function structobj = group(structobj,items,varargin) % varargin = group name
% 
% Groups selected tsobj() from a struct() into a collection
% of time series
% - Works on struct database of time series objects/collections
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Compatibility

error_msg('Syntax',['"implode(structobj * items)" is a ' ...
                    'preferred way to create time series collections']);

%%
if ~iscellstr(items) %~iscell(items) || ~all(cellfun(@ischar,items))
    error_msg('Grouping','Items to be grouped must form a cell array of chars...');
end

if ~isempty(varargin)
    group_name = varargin{1};
else
    group_name = 'auxaux_plotter';
end

names = fieldnames(structobj);
for ii = 1:length(items)
    if ~any(strcmp(items{ii},names))
        error_msg('Grouping','Item not found...',items{ii}); 
    end
end

%% Add group after previously generated groups

previous = length(sublist(names,group_name,'<'));
if previous >= 1
    structobj.(sprintf('%s_%.0f',group_name,previous+1)) = implode(structobj * items);
else
    structobj.(group_name)                              = implode(structobj * items);
end

%% Remove all grouped fields

structobj = rmfield(structobj,items);

end %<eof>