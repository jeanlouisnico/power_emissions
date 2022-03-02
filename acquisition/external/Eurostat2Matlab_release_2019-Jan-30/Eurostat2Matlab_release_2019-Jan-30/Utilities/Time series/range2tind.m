function [tind,freq] = range2tind(range)
%
% Computes numeric time indices out of given range
%
% INPUT: range ...cell/array of range labels (individual char range works too, 
%                   but delimited ':' input must be processed via process_range()/tindrange())
%        freq  ...data frequency
% 
% OUTPUT: tind ...time indexation
%
% SEE ALSO: tindrange(freq,start,finish) ...start/finish on input
%           tind2range(freq,tind)        ...tind array on input
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input treatment

range = upper(range);

if ischar(range)
    range = {range};
elseif isa(range,'double')
    if all(floor(range)==range)
        range = sprintfc('%d',range); 
    else
        dynammo.error.tsobj('Numeric range input must pass floor(x)==x test...',range);
    end
end
    
range = range(:);

%% Body

if ~isempty(strfind(range{1},'Q'))
    % Recipe: floor((year1 + 1/12*(part1-1)).*1e4)./1e4
    tmp = strrep(range,'Q','+1/4*(');
    tmp = strcat(tmp,'-1)');
    tind = cellfun(@eval,tmp);
    freq = 'Q'; 
    
elseif ~isempty(strfind(range{1},'M'))
    % Recipe: floor((year1 + 1/12*(part1-1)).*1e4)./1e4
    tmp = strrep(range,'M','+1/12*(');
    tmp = strcat('floor((',tmp,'-1)).*1e4)./1e4');
    tind = cellfun(@eval,tmp);
    freq = 'M'; 
    
elseif ~isempty(strfind(range{1},'-'))
    % Recipe: round((years(ii)+(months(jj)-1)/12+(days-1)./365).*1e4)./1e4;
    tmp = regexprep(range,'-','+1/12*(','once');
    tmp = regexprep(tmp,'-','-1)+1/365*(','once');
    tmp = strcat('round((',tmp,'-1)).*1e4)./1e4');
    tind = cellfun(@eval,tmp);    
    freq = 'D'; 
    
else % Yearly data
    tind = cellfun(@eval,range);
    freq = 'Y'; 
       
end

end %<eof>