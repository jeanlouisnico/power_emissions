function elapsed_time(varargin)
%
% Converts the toc() output into hours-mins-seconds format
%
% INPUT: if nothing ...toc() compared to last tic()
%        if previously saved tic() ...compared to the input tic()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Time interval

if nargin>0
    time_from = varargin{1};
    elapsed = toc(time_from);
    
else
    elapsed = toc;
    
end

%% Body

mins = floor(elapsed/60);
if mins>0 && mins<60
    seconds = elapsed - floor(elapsed/60)*60;
    disp(['Elapsed time is ' sprintf('%.0f',mins) ' minutes, ' ...
                             sprintf('%.8f',seconds) ' seconds.']);
elseif mins==0
    seconds = elapsed - floor(elapsed/60)*60;
    disp(['Elapsed time is ' sprintf('%.8f',seconds) ' seconds.']);
else
    hours = floor(mins/60);
    mins = mins - hours*60;
    seconds = elapsed - mins*60 - hours*3600;
    disp(['Elapsed time is ' sprintf('%.0f',hours) ' hours, ' ...
                             sprintf('%.0f',mins) ' minutes, ' ...
                             sprintf('%.8f',seconds) ' seconds.']);
end

end %<eof>