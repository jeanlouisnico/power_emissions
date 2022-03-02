function [tind,range,freq,success] = process_range_individual(range)
% 
% This fcn is based on more general process_range() and is meant
% to be used only by process_imported_data())
% 
% Error message texts are not necessary due to try-catch wrapper, but 
% it would be difficult to debug the code to account for all possible
% input inconsistencies
% 
% INPUT: range ...string indicating time label
%        dateformat ...date format must be parsed prior to calling this fcn (for speed)
% 
% OUTPUT: tind ...timing for the observations (vector)
%         range ...time labels based on data frequency
%         freq ...frequency of the data - yearly/quarterly/monthly/daily
% 
% Date formating: '2001', '2001q3', '2001m9' - other format types
%                 and daily data format available if dateformat 
%                 passed in as an argument, e.g. 'yyyy.m', 'yy-q', 
%                 'mm/dd/yyyy', et cetera
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

success = 1;

% !!! the input is guaranteed to be 'char'

%% Upper case input
% -> 96Q1 is case sensitive!
% -> user-defined date format must always be lower case (e.g. yyyy-mm),
%    therefore here we need to uppercase the range
range = upper(range);

%% Data frequency
freq = unique(regexp(range,'(-|M|Q)','match'));

%% Yearly data
if isempty(freq)
    if ~isempty(regexp(range,'[A-Z]','match')) || floor(log(range)/log(10)+1)>4 % # of digits tested
       %error_msg('Range processing','Range processing failed...',range); 
       tind=0;range={[]};freq='';success=0;
       return       
    end
        
    tind = eval(range);
    range = {range};
    
    freq = 'Y';
    return
    
end

% Do not move from here
if length(freq)~=1
   %error_msg('Range processing','Range processing failed...',range);
   tind=0;range={[]};freq='';success=0;
   return    
end

freq = freq{1};

%% Daily data
if strcmp(freq,'-')
    
    if length(strfind(range,'-'))~=2 || length(range)~=10
       %error_msg('Range processing','Wrong input format',range);
       tind=0;range={[]};freq='';success=0;
       return        
    end
    
    timing = regexp(range,'-','split');
    year_  = eval(timing{1});
    month_ = eval(timing{2});
    day_   = eval(timing{3});
    
    tind = round((year_+(month_-1)/12+(day_-1)./365).*1e4)./1e4;
    range = {range};
    
    freq = 'D';
    return

end

%% Q and M data

% Quarterly
if strcmp(freq,'Q')
    
    if length(strfind(range,'Q'))~=1 || length(range)~=6
       %error_msg('Range processing','Wrong input format',range);
       tind=0;range={[]};freq='';success=0;
       return        
    end    
    
    tind  = eval(range(1:4)) + (eval(range(6:end))-1)/4;
    range = {[range(1:4),'Q',range(6:end)]};
    return

end

% Monthly
if strcmp(freq,'M')
    
    if length(strfind(range,'M'))~=1 || length(range)>7
       %error_msg('Range processing','Wrong input format',range);
       tind=0;range={[]};freq='';success=0;
       return        
    end   
    
    tind = eval(range(1:4)) + (eval(range(6:end))-1)/12;
    range = {[range(1:4),'M',range(6:end)]};
    return

end

%% Too far
%error_msg('Range processing','Unknown frequency...',range); 
tind=0;range={[]};freq='';success=0;

end %<eof>