function yscale = yscale_size(orientation)
%
% >>> Internal file <<<
% 
% Space allocation for super title
% 
% INPUT: orientation ...'portrait'/'landscape'/'slide'/'dont'/etc. paper orientation
%                       'dont' case does not create any space for super title
% OUTPUT: yscale ...scalar that specifies the % share of page that will be filled with graphs,
%                       (1-yscale) is the % reserved for super title
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

switch lower(orientation)
    case 'portrait'
        yscale = 0.93;
    case 'landscape'
        yscale = 0.85;
    case 'slide'
        yscale = 0.999;% Cannot be 1, dynammo.plot.addSuptitle() uses (1-yscale)
    case 'doc1'
        yscale = 0.999;% Cannot be 1, dynammo.plot.addSuptitle() uses (1-yscale)        
    case 'pg_halfwidth'
        yscale = 0.999;% Cannot be 1, dynammo.plot.addSuptitle() uses (1-yscale)    
    case 'pg_fullwidth'
        yscale = 0.999;% Cannot be 1, dynammo.plot.addSuptitle() uses (1-yscale)          
    case 'dont'
        yscale = 0.95;% Scaled down from 0.99 to 0.95 because figcombine in 'dont' format made the suptitle invisible...
    otherwise
        error_msg('Plot format','Unknown page type; list of implemented types:',dynammo.plot.A4types());
end

%% Debugging

% yscale = 1;
% return

end %<eof>