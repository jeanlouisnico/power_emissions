function suphan=suptitle_fast(fignow,str,orientation)
% 
% INTERNAL function: intended to be called by other functions, not by the user!
% 
% Adds a super title above all subplots, positioning of all subplots must be
% accomplished prior to calling suptitle_fast()
% 
% INPUT: fignow ...handle to an existing figure
%        str    ...super title text
%        orientation ...paper positioning 'landscape'/'portrait' ('dont' case not assumed
%                               as this function is called after 'dont' case is ruled out)
% 
% OUTPUT: hout ...handle to the text object containing super title
% 
% See also: suptitle()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Down scaling axes

% By how much the downscaling was performed
% -> now in this function we only intend to plug in a new object containing super title
yscale = dynammo.plot.yscale_size(orientation);

%% Super title
suphan = dynammo.plot.addSuptitle(fignow,str,yscale);

end %<eof>