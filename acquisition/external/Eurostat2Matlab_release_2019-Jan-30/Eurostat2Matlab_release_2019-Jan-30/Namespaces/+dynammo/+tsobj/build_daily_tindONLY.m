function tind = build_daily_tindONLY(start_,finish_)
%
% Range/tind generation for daily time series
%
% INPUT: start_  ...first tind (double)
%        finish_ ...last tind (double)
%
% SEE ALSO: dynammo/tsobj/build_daily (also returns range)
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Range bounds

y1 = floor(start_);
m1 = floor(12*(start_-y1)+1.0004);% 4e-4 padding due to previous rounding
d1 = round(365*(start_-y1-1/12*(m1-1))+1);

y2 = floor(finish_);
m2 = floor(12*(finish_-y2)+1.0004);% 4e-4 padding due to previous rounding
d2 = round(365*(finish_-y2-1/12*(m2-1))+1);

%% <stolen build_daily w/o range computation parts>

years = (y1:1:y2).';

% Pre-allocation
tinds    = zeros(12*31*length(years),1);% -> this is hard to pre-allocate, we delete extra empty entries in the end
counter = 1;

for ii = 1:length(years)
    
    if ii==1 && ii==length(years)
        months = m1:1:m2;
    elseif ii==1
        months = m1:1:12;
    elseif ii==length(years)
        months = 1:1:m2;
    else
        months = 1:1:12;
    end
    months = months(:);
    
    for jj = 1:length(months)
        
        days = mycalendar(years(ii),months(jj));
        if ii==1 && jj==1
            days = days(days>=d1);
        end
        if ii==length(years) && jj==length(months)
            days = days(days<=d2);
        end
        ndays = length(days);
        
        tinds(counter:counter+ndays-1,1) = round((years(ii)+(months(jj)-1)/12+(days-1)./365).*1e4)./1e4;

        counter = counter + ndays;
        
    end
end

%% Output

% Drop empty values (pre-allocation was bigger on purpose)
tind = tinds(tinds~=0,1);

end %<eof>