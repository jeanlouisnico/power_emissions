function [out,where] = sublist(names_in,filter,varargin)
% 
% Returns a sublist from the input list based on a filtering criterion
% 
% INPUT:  names_in ...[CELL] of strings
%         filter   ...[STRING] pattern to be searched for
%         varargin ...'<' - beginning with, 
%                     '>' - ending with,
%                     '<>' - part of
%                     '#' - [OBSOLETE OPTION!] exact match when testing for existence
%							use "strcmp(gg,'SW')"/"find(strcmp(gg,'SW'))" instead!!!
%
% OUTPUT: out      ...sublist of input fields
%         where    ...logical (0/1) positions of found items
%
% EXAMPLE: 1] sublist({'aab','b','b'},'a','<') returns  'aab'
%
%          2] eq = 'exp(2*x+y)'; 
%             sublist(eq,'exp','<') returns  'exp(2*x+y)'
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~ischar(filter) || ~iscell(names_in)
    try  
        names_in = {names_in};
    catch
        error_msg('Sublist()',['Input must be cell (list of strings), ' ...
									 '"filter" must be a string...']);
    end
end

if ~isempty(varargin)
    type = varargin{1};
else
    type = '<>';
end

if ~any(strcmp(type,{'<','>','<>'}))
    error('||| type must be "<", ">", "<>" or "#"...');
end

switch type
    case '<'
        %look_for_ = ['^' filter]; % slower
        where = strncmp(names_in,filter,length(filter));
        where = where(:);% logical ordering (0/1)!
        out = names_in(where);
        return
        
    case '>'
        %look_for_ = [filter '$']; % slower
        where = strncmp( ...
            cellfun(@fliplr,names_in,'UniformOutput',false), ...
            fliplr(filter),length(filter));
        where = where(:);% logical ordering (0/1)!
        out = names_in(where);
        return
        
    otherwise %<> part of
        look_for_ = filter;
end

temp_ = zeros(length(names_in),1);
where = zeros(length(names_in),1);
for ii = 1:length(names_in)
    if isempty(regexp(names_in{ii},look_for_,'once'))
        temp_(ii) = 1;
    else
        where(ii) = 1;% logical ordering (0/1)!
    end
end

out = cell_drop_elements(names_in,temp_);

end