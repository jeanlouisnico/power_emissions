function rangeout = correct_date_format(rangein,dateformat)
%
% Convertor into standard date formatting using 'ymd' indication
% 
% INPUT: rangein ...the input range as cell()
%        dateformat ...string indicating the input type (e.g. yyyy-mm)
%
% OUTPUT: rangeout ...converted range into 
%                       yyyy-mm-dd format (daily data)
%                       yyyyQq     format (quarterly data)
%                       yyyyMmm    format (monthly data)
%                       yyyy       format (yearly data)
%
% <Function intended for manual use>
% SEE ALSO: dynammo.tsobj.deal_dateformat()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Char input
if ischar(rangein)
    rangein = {rangein};
end
    
%% Body
rangeout = rangein;% Pre-allocation
for ir = 1:length(rangein)
  rangeout{ir} = dynammo.tsobj.deal_dateformat(rangein{ir},dateformat);
end
rangeout = rangeout(:);

end %<eof>