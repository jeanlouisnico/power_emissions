function out = dbobj2struct(in)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

f = fieldnames(in);

out = struct();
for ii = 1:length(f)
    out.(f{ii}) = in.(f{ii});
end

end %<eof>