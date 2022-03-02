function suphan = addSuptitle(fignow,str,yscale)
%
% Adds a super title into a given figure
%
% INPUT: fignow ...handle to a figure
%        yscale ...a scalar controlling size of the super title region
%
% OUTPUT: suphan ...handle to a super title object
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Font size
fs = get(fignow,'defaultaxesfontsize')+4; 

%% Create new subplot

% >>> DO NOT DELETE THIS COMMENT - I HAD THIS IDEA MULTIPLE TIMES AND IT IS WRONG <<<
% Activate the correct figure before putting new axes obj.
% figure(fignow); -> !!! This causes the figure to become visible !!!
% -> setting the 'parent' option works well (see below)

ha=axes('pos',[0 yscale 1 1-yscale],'visible','off', ...off on
                'tag','suptitle');

%% Assign to correct parent
% -> axes() always uses normalized units
% -> parent figure units should not matter (checked), dynammo.plot.A4() leaves the figure units
%       in centimeters, but relative positioning of subplot follows the units set 
%       in the subplot object, not units of the parent object
set(ha,'parent',fignow);

%% Super title
suphan=text(.5,0.4,str);
set(suphan,'horizontalalignment','center', ...
            'fontsize',fs, ...
            'tag','suptitletext', ...
            'fontweight','normal');%'fontname','times');

end %<eof>