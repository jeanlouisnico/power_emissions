function resizeCallback_dsd(handles,opt)
%
% Resizing must change the layout of the DSD figure
%
% INPUT: handles to the objects in the DSD overview
%
% OUTPUT: none
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Current GUI dimensions

tmp = get(handles.f,'position');
fig_w = tmp(3);
fig_h = tmp(4);

%% Horizontal measures
xstart = round(opt.c1*fig_w);
xend   = round(opt.c2*fig_w);
xrange = xend-xstart;
ystart = fig_h-opt.fromTop;

%% Facade
% ystart = round(opt.c3*fig_h)-opt.txt_h;
opt.yTopRow = ystart;
set(handles.facade,'Position',[0 opt.yTopRow fig_w fig_h-ystart]);
       
%% Status bar background

set(handles.statbar_bckgnd,'Position',[xstart opt.yTopRow+opt.yBufTop xrange opt.fromTop-2*opt.yBufTop]);

%% Selection button

selbutt_xstart = xend - opt.sel_butt_width - opt.butt_dist;
selbutt_width  = opt.sel_butt_width;
selbutt_ystart = opt.yTopRow+opt.yBufTop;
selbutt_height = fig_h-ystart-2*opt.yBufTop;

set(handles.selbutt,'Position',[selbutt_xstart selbutt_ystart selbutt_width selbutt_height]);

%% Check button

selbutt_xstart = selbutt_xstart - opt.horzShift - opt.check_select_buff;
selbutt_width  = opt.sel_butt_width + opt.check_select_buff;
selbutt_ystart = opt.yTopRow+opt.yBufTop;
selbutt_height = fig_h-ystart-2*opt.yBufTop;

set(handles.chckbutt,'Position',[selbutt_xstart selbutt_ystart selbutt_width selbutt_height]);

%% Status bar text field

set(handles.statbar_text,'Position',[xstart+opt.statbar_inset ...
                            opt.yTopRow+opt.yBufTop ...
                            xrange-2*(opt.sel_butt_width+opt.butt_dist)-opt.butt_dist-opt.check_select_buff ...
                            fig_h-ystart-2*opt.yBufTop-opt.statbar_inset]);
                        
%% Vertical measures

% Vertical start affected by the scroll bar situation
scval = get(handles.scrlb,'value');

% Phase I - determine by how much newy is currently below the bottom edge of the GUI figure
% ystart = round(opt.c3*fig_h);% Usual spot to start from
ystart_top = ystart;
newy = ystart;%opt.movingContentStart;%ystart
for ii = 1:length(opt.heights)
   
    % Category code
    newy = newy-opt.txt_h;
    
    % Draw list box
    yheight = opt.heights(ii)*opt.txt_h+opt.buf1;
    newy = newy-yheight;
    newy = newy-opt.txt_h;
    
end

% Linear mapping of the scroll bar setting to the newy
if newy<0
    % Positive increment will move the objects north
    ystart = ystart+newy*(scval-1);
end


%% Re-drawing main objects

% Phase II - update the positions of all objects
newy = ystart;%opt.movingContentStart;%ystart
for ii = 1:length(opt.heights)
    
    han_id = ii*2;
    % Category code
    newy = newy-opt.txt_h;
    set(handles.hans{han_id-1},'Position',[xstart newy xrange opt.txt_h]);
    
    % Draw list box
    yheight = opt.heights(ii)*opt.txt_h+opt.buf1;
    newy = newy-yheight;
    set(handles.hans{han_id},'Position',[xstart newy xrange opt.heights(ii)*opt.txt_h]);
    
    newy = newy-opt.txt_h;
    
end
      
%% Scroll bar
% keyboard;
if newy<0 || ystart>ystart_top
    set(handles.scrlb,'position',[fig_w-opt.vert_scrlb_pos 0 opt.vert_scrlb_pos fig_h-opt.fromTop],'visible','on');
else
    set(handles.scrlb,'position',[fig_w-opt.vert_scrlb_pos 0 opt.vert_scrlb_pos fig_h-opt.fromTop],'Value',1,'visible','off');
end

end %<eof>