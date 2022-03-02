function args = subplot_layout(args,nsubplots)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
   
to_test = [1 1];
if strcmpi(args.A4,'portrait')
    increment_last = 0;
else % 'dont' 'landscape'
    increment_last = 1;
end
while true
    if to_test(1)*to_test(2) >= nsubplots
        break
    else
       if increment_last
           to_test(2) = inc(to_test(2));
           increment_last = 0;
       else
           to_test(1) = inc(to_test(1));
           increment_last = 1;
       end
    end
end
args.subplot = to_test;

%% Subplot positioning

% args.subplot_pos

end %<eof>