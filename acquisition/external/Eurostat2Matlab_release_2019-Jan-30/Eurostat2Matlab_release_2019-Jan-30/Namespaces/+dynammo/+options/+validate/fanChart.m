function args = fanChart(in,args)
%
% Input validator for fan charts
%
% INPUT: in ...collection of time series
%        args ...set of plotting options
%
% REQUIREMENTS: [*] odd number of input series (1 main + symmetrical intervals)
%               [*] intervals must form a strictly increasing band (overlaps in invervals not allowed)
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Validation
[~,objs] = size(in.values);

if objs<3
    error_msg('Fan chart graphing','The input collection of time series must contain at least 3 series (1 main + two defining the interval)');
end
if mod(objs,2)==0
    error_msg('Fan chart graphing','The input collection of time series must contain odd # of input series (1 main + pairs of series defining the intervals)');
end

%% Options
if args.emphasize==0
    args.emphasize = 3;% Line must always be visible in a fan chart
end
nobjs_int = floor(objs/2);
if length(args.alpha)~=nobjs_int
    nobji = floor(objs/2);
    alphas = linspace(0,1,nobji+2);% +2 is here because we will trim the extreme values in the end (full opacity and full transparency)
    alphas = alphas(2:end-1);
    args.alpha = alphas(:);    
else
    args.alpha = args.alpha(:); 
end


end %<eof>