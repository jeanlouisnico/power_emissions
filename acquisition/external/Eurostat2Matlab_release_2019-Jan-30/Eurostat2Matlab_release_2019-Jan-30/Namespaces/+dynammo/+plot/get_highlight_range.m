function [highlight_per_from,highlight_per_to] = get_highlight_range(freq,args,max_x_limit,ih,isZebra)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

highrange = args.highlight{ih};

% if isZebra==0
    highlight_per = process_range(highrange);
% else
%     highlight_per
% end
%   highlight_per = tindrange(freq,highrange);

highlight_per_from = highlight_per(1);
highlight_per_to   = highlight_per(end);
if length(args.highlight)==1 && ... multiple input ranges
   highlight_per_from==highlight_per_to % highlight from given range to end
   highlight_per_to = max_x_limit;
end

%% Buffers

switch freq
    case 'Y'
        buf_ = 0.5;
    case 'Q'
        buf_ = 0.125;
    case 'M'
        buf_ = 0.0417;
    case 'D'
        buf_ = 0.0014;
end

highlight_per_from = highlight_per_from - buf_;

if isZebra==2
    highlight_per_to = highlight_per_to - buf_;% - half period
else
    highlight_per_to = highlight_per_to + buf_;% + half period
end

end %<eof>