function [tind,range] = build_daily(start_,finish_)
%
% Range/tind generation for daily time series
%
% INPUT: start_  ...first tind (double)
%        finish_ ...last tind (double)
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

%% Bridging

years = (y1:1:y2).';

% Pre-allocation
tinds    = zeros(12*31*length(years),1);% -> this is hard to pre-allocate, we delete extra empty entries in the end
range_bin = cell(12*31*length(years),1);% -> this is hard to pre-allocate, we delete extra empty entries in the end
counter = 1;

% Faster way to process month days
chardays = ['01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';
            '16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30';'31'];
month_bin = ['-01-';'-02-';'-03-';'-04-';'-05-';'-06-';'-07-';'-08-';'-09-';'-10-';'-11-';'-12-'];
% moprint = sprintf('-%02d-',months(jj));

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
    
    glueyear = sprintf('%d',years(ii));
    
    for jj = 1:length(months)
        
        days = mycalendar(years(ii),months(jj));
        if ii==1 && jj==1
            days = days(days>=d1);
        end
        if ii==length(years) && jj==length(months)
            days = days(days<=d2);
        end
        ndays = length(days);
        
        % Pre-allocated way
        tinds(counter:counter+ndays-1,1) = round((years(ii)+(months(jj)-1)/12+(days-1)./365).*1e4)./1e4;
        
        glueyear = glueyear(ones(ndays,1),:);
        gluemonth=  month_bin(repmat(months(jj),ndays,1),:);
        
        s = [glueyear,gluemonth, chardays(days(1):days(end),:)];% More rows here!
        
        month_batch = cell(ndays,1);
        for kk=1:ndays
            month_batch{kk} = s(kk,:);% -> this is the bottle neck :(, but cellstr() uses the same for cycle inside
        end
        
        range_bin(counter:counter+ndays-1,1) = month_batch;
        counter = counter + ndays;
        
    end
end

%% Output

% Drop empty values (pre-allocation was bigger on purpose)
to_take = tinds~=0;
range = range_bin(to_take,1);
tind = tinds(to_take,1);

end %<eof>