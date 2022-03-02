function headhandle = header(fignow,reportname,header)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Save currently visible axes
% h = findobj(fignow,'Type','axes');
% haold = h(1);

%% Retain current drawings
% np = get(fignow,'nextplot');
% set(fignow,'nextplot','add');
 
%% Draw new object
xpos = 0.05;
ypos = 0.97;%0.97
width = 0.90;%0.90
height = 1-ypos;
ha=axes('pos',[xpos ypos width height], ...
        'visible','off', ...
        'parent',fignow);% ...
        %'Tag','header');
if ispc
    textvertpos = 0.6;
    textlefthor = 0.01;
    textrighthor = 0.97;
else
    textvertpos = 1;
    textlefthor = 0.02;
    textrighthor = 0.96;
end
l = line([0 1],[-0.2 -0.2],'color','k');
set(l,'linewidth',0.25,'parent',ha);%,'visible','off');
t1 = text(textlefthor,textvertpos, ...
        sprintf('%s     %s',header{1},reportname), ...
            'fontname','Times', ...
            'fontsize',9, ...
            'parent',ha);
t2 = text(textrighthor,textvertpos,header{2}, ...
            'fontname','Times', ...
            'fontsize',9, ...
            'parent',ha);
set(ha,'ylim',[-0.2 1.5]);
 
%% Switch the settings back
% set(fignow,'nextplot',np);
% axes(haold);

%% Output
headhandle.axes = ha;
headhandle.textleft = t1;
headhandle.textright = t2;
headhandle.line = l;


end %<eof>