function [path,found] = table_finder(toc,tablename,path)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

% path = 'toc.';
found = 0;

f = fieldnames(toc);
for ii = 1:length(f)
    if strcmp(f{ii},tablename)
        % Match found
        path = [path '.' tablename]; %#ok<AGROW>
        found = 1;
        return
    end
    if isstruct(toc.(f{ii}))
        if strcmpi(f{ii},'lastUpdate')
            return
        end
        
        pathold = path;
        [path,found] = table_finder(toc.(f{ii}),tablename,[path '.' f{ii}]);
        if found==0
            path = pathold;
        else
            return
        end
        
    end     
end


end %<eof>