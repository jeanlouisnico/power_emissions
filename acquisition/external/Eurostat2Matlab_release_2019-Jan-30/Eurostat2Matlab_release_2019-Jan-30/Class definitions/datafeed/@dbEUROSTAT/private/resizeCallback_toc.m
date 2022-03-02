function resizeCallback_toc()
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Access to globals
global dbobj_set;

def = dbobj_set.def;

%% Current dimensions

dims = get(gcf,'position');
fig_w = dims(3);
fig_h = dims(4);

%% Super title

xstart = round(def.s1_xstart*fig_w);
xrange = def.s1_xrange;
ystart = max(1,fig_h -def.s1_yshift_down);

set(dbobj_set.s1s2simg{1},'Position',[xstart ystart xrange def.txt_h]);

%% Tree icon

set(dbobj_set.s1s2simg{4},'position',[xstart-def.simg2_toLeft ystart-def.simg2_toDown def.simg2_size def.simg2_size2]);

%% Search box

xend   = round((1-def.s1_xstart)*fig_w);
xstart = xend - def.s2_xrange;
ystart = fig_h -def.s1_yshift_down;

set(dbobj_set.s1s2simg{2},'position',[xstart ystart def.s2_xrange def.txt_h]);

%% Search icon

set(dbobj_set.s1s2simg{3},'position',[xstart-def.simg_toLeft ystart def.simg_size def.simg_size]);

%% Subtrees
h_old = dbobj_set.h_old;
nh = size(h_old,1);
for ii = 1:nh
    xstart = round(def.s1_xstart*fig_w);% + def.x_extra_subtree*ii;% +1 -> 1 extra for the newly generated row...
    xend   = round((1-def.s1_xstart)*fig_w);
    xrange = xend - xstart;%
    ystart   = fig_h-def.s1_yshift_down - ii*def.txt_h;

    set(h_old{ii,1},'Position',[xstart ystart xrange def.txt_h]);
    
end

%% Listbox

xstart = round(def.s1_xstart*fig_w);
xend   = round((1-def.s1_xstart)*fig_w);
xrange = xend-xstart;
ystart = round(def.self_ydown*fig_h);
yend   = fig_h - def.s1_yshift_down - size(dbobj_set.h_old,1)*def.txt_h - def.self_vert_shift;
yrange = max(1,yend-ystart);

set(dbobj_set.self,'Position',[xstart ystart xrange yrange]);

end %<eof>