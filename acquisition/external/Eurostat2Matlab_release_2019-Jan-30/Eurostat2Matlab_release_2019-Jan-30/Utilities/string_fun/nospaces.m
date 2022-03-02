function out = nospaces(in)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if iscell(in)
    out_cell = cell(size(in));
    for ii = 1:length(in)
        out_cell{ii} = in{ii}(~isspace(in{ii})); 
    end
    out = out_cell;
elseif ischar(in)
    out = in(~isspace(in));
else
    error_msg('Invalid input, must be string, or cell of strings...');
end

end