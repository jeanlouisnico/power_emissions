function [tickFirst,tickLast] = ticksNearEdge(xlims,freq)
%
% Returns first possible xtick after xlims(1) and last possible before xlims(2)
% for a given data frequency
% 
% INPUT: xlims ...
%        
%
% OUTPUT: ...
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

freq = lower(freq);

%% Body
        
switch freq
    case 'y'
        tickFirst = ceil(xlims(1));
        tickLast = floor(xlims(2));
    case 'q'
        tickFirst = ceil(xlims(1)*4)/4;
        tickLast = floor(xlims(2)*4)/4;
    case 'm'
        tickFirst = ceil(xlims(1)*12)/12;
        tickLast = floor(xlims(2)*12)/12;
    case 'd'
        %keyboard;
        start_year = floor(xlims(1));
        start_month= ceil((xlims(1)-start_year)*12);%(floor(xlims(1)*12)/12 - start_year) * 12;
        
        % Look for the first occurrence of day>xlim(1)
        tickFirst = '';
        searchForDayFIRST();
        if isempty(tickFirst)
            if abs(start_month-12)<1e-1
                start_year = start_year + 1;
                start_month = 1;
            else
                start_month = start_month+1;
            end
            searchForDayFIRST();% Now the day should be found for sure...
        end
        
        start_year = floor(xlims(2));
        start_month= ceil((xlims(2)-start_year)*12);%(floor(xlims(2)*12)/12 - start_year) * 12 + 1;
        
        % Look for the last occurrence of day<xlim(2)
        tickLast = '';
        searchForDayLAST();
        if isempty(tickLast)
            if abs(start_month-1)<1e-1
                start_year = start_year - 1;
                start_month = 12;
            else
                start_month = start_month-1;
            end
            searchForDayLAST();% Now the day should be found for sure...
        end
end

% If the interval is too narrow we might end up with bad ticks max<min
if ~strcmp(freq,'d')
    if tickFirst>tickLast
        tmp = tickFirst;
        tickFirst = tickLast;
        tickLast = tmp;
    end
else
    % Let's risk it and do nothing about it... <twisted input hard to cope with>
end

%% Nested fcns

    function searchForDayFIRST()
        inddays = mycalendar(start_year,start_month);
        for iday = transpose(inddays)
            test_tind = round((start_year + (start_month-1)/12 + (iday-1)/365)*1e4)/1e4;
            if (test_tind-xlims(1))>0
                if log10(start_month)<1
                    tickFirst =  sprintf('%d-0%d-',start_year,start_month);
                else
                    tickFirst =  sprintf('%d-%d-',start_year,start_month);
                end
                if log10(iday)<1
                    tickFirst = sprintf('%s0%d',tickFirst,iday);
                else
                    tickFirst = sprintf('%s%d',tickFirst,iday);
                end
                break
            end
        end
    end %<searchForDay>

    function searchForDayLAST()
        inddays = mycalendar(start_year,start_month);
        inddays = flipud(inddays);
        for iday = transpose(inddays)
            test_tind = round((start_year + (start_month-1)/12 + (iday-1)/365)*1e4)/1e4;
            if (test_tind-xlims(2))<0
                if log10(start_month)<1
                    tickLast =  sprintf('%d-0%d-',start_year,start_month);
                else
                    tickLast =  sprintf('%d-%d-',start_year,start_month);
                end
                if log10(iday)<1
                    tickLast = sprintf('%s0%d',tickLast,iday);
                else
                    tickLast = sprintf('%s%d',tickLast,iday);
                end
                break
            end
        end
    end %<searchForDay>
        
end %<eof>