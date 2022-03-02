function days = mycalendar(year,month)
%
% Faster version of Matlab's calendar() to get list of days in a given year/month
%
% INPUT: year+month ...numeric values
%
% OUTPUT: vector of days within given year/month
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Leap year determination according to Gregorian calendar
% Wikipedia on Leap_year:
%             if (year is not exactly divisible by 4) then (it is a common year)
%             else if (year is not exactly divisible by 100) then (it is a leap year)
%             else if (year is not exactly divisible by 400) then (it is a common year)
%             else (it is a leap year)

if mod(year,4)~=0
    % >>> common year <<<
    dpm = [31 28 31 30 31 30 31 31 30 31 30 31]; 
elseif mod(year,100)~=0
    % >>> leap year <<<
    dpm = [31 29 31 30 31 30 31 31 30 31 30 31]; 
elseif mod(year,400)~=0
    % >>> common year <<<
    dpm = [31 28 31 30 31 30 31 31 30 31 30 31]; 
else
    % >>> leap year <<<
    dpm = [31 29 31 30 31 30 31 31 30 31 30 31];
end

%% Days list
days = 1:dpm(month);
days = days(:);

end %<eof>