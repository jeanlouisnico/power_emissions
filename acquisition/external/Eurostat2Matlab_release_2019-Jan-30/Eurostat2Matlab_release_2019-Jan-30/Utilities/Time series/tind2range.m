function range = tind2range(tind,freq)
%
% Computes range labels from numeric time indices (input can be scalar)
%
% INPUT: tind ...time indexation
%        freq ...data frequency
%
% OUTPUT: range ...cell of range labels
%
% SEE ALSO: tindrange(freq,start,finish) ...start/finish on input
%           range2tind(tind)             ...tind array on input
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
% -> Note: frequency could also be detected from diff(tind) but then 
%          the function would not process individual tind scalars

tind = tind(:);
switch upper(freq)
    case 'D'
        y = floor(tind);
        m = floor(12*(tind-y)+1.0004);% 4e-4 padding due to previous rounding
        d = round(365*(tind-y-1/12*(m-1))+1);
        range = strcat(sprintfc('%d',y),sprintfc('-%02d-',m),sprintfc('%02d',d));
        
    case 'M'
        y = floor(tind);
        m = round((tind-y)*12+1);
        range = strcat(sprintfc('%d',y),sprintfc('M%d',m));
        
    case 'Q'
        y = floor(tind);
        q = (tind-y)*4+1;
        range = strcat(sprintfc('%d',y),sprintfc('Q%d',q));
        
    case 'Y'
        range = sprintfc('%d',floor(tind));
        
    otherwise
        dynammo.error.tsobj('Unknown date frequency...');
end

end %<eof>