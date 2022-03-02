function show_stack()
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input

stack = evalin('base','dynammo_error_stack');

nstack = stack.nstack;
stack = stack.entries;

%% Body

for ii = nstack-1:-1:1 % size can be 2, ok here...
    fileOnly = regexp(stack(ii).file,filesep,'split');
        fprintf(2, ...
                ' [-] <a href="matlab: opentoline(''%s'',%.0f)">%s (line %.0f)</a> \n', ...
                stack(ii).file, ...
                stack(ii).line, ...
                strrep(fileOnly{end},'.m',''), ...
                stack(ii).line);
end

fprintf('\n');

end %<eof>