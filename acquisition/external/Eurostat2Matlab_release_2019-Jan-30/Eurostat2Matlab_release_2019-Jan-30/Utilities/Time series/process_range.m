function [tind,range,freq] = process_range(rangein)
% 
% Core range processing functionality featuring:
% [1] identification of data frequency
% [2] non-standard date formatting on input
% 
% INPUT: rangein ...string indicating time label
% 
% OUTPUT: tind ...timing for the observations (vector)
%         range ...time labels based on data frequency
%         freq ...frequency of the data - yearly/quarterly/monthly/daily
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Pre-processing

% Cell input usually does not get validated, here we want the opposite
if iscell(rangein)
   rangein = rangein{1}; 
end

if ~ischar(rangein) && ~isa(rangein,'double')
    error_msg('Range processing','Wrong range input...',in);
end

%% Handle integer input
% -> IRF timing is usually yearly
if isa(rangein,'double')
   if all(floor(rangein)==rangein)
       if length(rangein)~=length(rangein(1):rangein(end))
            error_msg('Range processing','Time indices do not form a consecutive series...');
       end
       tind = (rangein(1):rangein(end)).';
       
       if ~all(tind==rangein(:))
            error_msg('Range processing','Time indices do not form a consecutive series...');
       end
       
       % It must be yearly data for sure
       range = sprintfc('%d',tind);
       freq = 'Y';
       
       return
       
   else
       error_msg('Range processing','The range must be a string or integer array...');
   end
end
    
%% Range boundaries

rangein = upper(rangein);

% Range bounds
bounds = regexp(rangein,':','split');
if length(bounds)>2
    error_msg('Range processing','Range processing failed...',rangein); 
end
start_ = bounds{1};
finish_ = bounds{end};

bounds = range2tind({start_;finish_});

%% Data frequency
%freq = unique(regexp(rangein,'(-|M|Q)','match'));
allfreqs = {'Q';'M';'-'};
freq_cands = cellfun(@(x) regexpi(rangein,x,'once'),allfreqs,'UniformOutput',false);
freq_found = ~cellfun('isempty',freq_cands);
if ~any(freq_found)

    if ~isempty(regexp(rangein,'[A-Z]','match'))
        error_msg('Range processing','Range processing failed...',rangein); 
    end   
    freq = 'Y';
    
else

    if sum(freq_found)~=1 %length(unique(freq))~=1
        error_msg('Range processing','Range processing failed...',rangein); 
    end
    
    freq = allfreqs(freq_found);
    freq = freq{1};
    
    if strcmpi(freq,'-')
       freq = 'D'; 
    end
    
end

%% Main build step
[tind,range] = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));

end %<eof>