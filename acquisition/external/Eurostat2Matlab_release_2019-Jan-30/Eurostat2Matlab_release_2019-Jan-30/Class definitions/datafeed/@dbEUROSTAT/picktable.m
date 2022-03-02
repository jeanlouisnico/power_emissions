function picktable(this)
%
% User interface to select exact set of time series from a given EUROSTAT table 
%
% INPUT: toc   ...EUROSTAT Table of contents structure
%
% OUTPUT: none
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Define globals
global dbobj_set; %self h_old s1s2 level fig def last_ystart;

%% Fetch the table of contents
toc = TOC(this,'refresh',0);

%% Checks

if ~isstruct(toc)
    dynammo.error.dbobj('Table of contents must be a struct() object...');
end

%% Resave the input in the base workspace
% assignin('base','dbobj_toc',toc);
level = inputname(1);%'toc';%inputname(1);%'dbobj_toc';

%% Figure prep

scrn_dims = get(0,'ScreenSize');

def = struct();
fig_w = 0.50*scrn_dims(3);%960;%[px]
fig_h = 0.70*scrn_dims(4);%756;%[px] 
fig_col = [0.8 0.8 0.8];
fig = figure('Name','Table selection','units','pixels', ...
            'color',fig_col); % To align the color with search icon :)
set(fig,'position',[0.25*scrn_dims(3) ...
                    0.25*scrn_dims(4) ...
                    fig_w fig_h]);        
AOTfeature(gcf);

% Hide all UI features                                                                   
set(fig,'Menubar','none');

%% Initialize fields

% Default values
def.txt_h = 20; % Row height [px]
def.x_extra_subtree = 1; % Horizotal shift for subtrees [# of spaces]
def.buf1  = 8;  % Between columns min. space [px]

% Drawing from/to
def.s1_xstart = 0.05;
fnt_siz = 12;

% Colors busy/idle
def.col_idle = [0.9812 0.9812 0.9812];% whiteish
def.col_busy = [1 0.7 0.7];% reddish

%% Super title

def.s1_xrange = 260;%[px]
def.s1_yshift_down = 40;%[px from top]
% def.all_yaddon = 20;%[px from previous row]

def.posx = 0.0;
xstart = round(def.s1_xstart*fig_w);
%xend   = xstart + def.s1_xrange;%round(def.s1_xend*def.fig_w);
xrange = def.s1_xrange;%xend-xstart;
ystart = fig_h -def.s1_yshift_down;%round((def.pos2-def.posx)*def.fig_h);

s1 = uicontrol('Style','checkbox',...text
            'units','pixels',...
            'String','EUROSTAT table selection', ...
            'horizontalalignment','left', ...
            ...'verticalalignment','center', ...option does not exist :(
            'fontsize',fnt_siz,'FontName','FixedWidth', ...
            'BackgroundColor',fig_col);%
set(s1,'Position',[xstart ystart xrange def.txt_h]);
% set(s1,'units','pixels');

%% Click icon

% Read from file
img = imread([dynammoroot filesep 'Utilities' filesep 'Pics' filesep 'mouseClick2.png']);
img = double(img)./255;

% Show it
simg2 = subplot(1,1,1);
image(img);
axis(simg2,'off');

% Adjust the position and size
% - Position is now absolute (in pixels)
% - size is absolute (in pixels)
set(simg2,'units','pixels');
def.simg2_toLeft = 40;
def.simg2_toDown = 10;% Rescaled by its original size
def.simg2_size = 35;
def.simg2_size2= def.simg2_size / 112*149;% Rescaled by its original size
set(simg2,'position',[xstart-def.simg2_toLeft ystart-def.simg2_toDown def.simg2_size def.simg2_size2]);

%% Search box

def.s2_xfromleft = 100;%[px]
def.s2_xrange = 250;

xend   = round((1-def.s1_xstart)*fig_w);
xstart = xend - def.s2_xrange;
ystart = fig_h -def.s1_yshift_down;
ini_string = 'Search field...';
s2 = uicontrol('Style','Edit', ...
                'units','pixels', ...
                'fontsize',fnt_siz,'FontName','FixedWidth', ...
                'String',ini_string, ...
                'HorizontalAlignment','left');
            
set(s2,'position',[xstart ystart def.s2_xrange def.txt_h]);
set(s2,'BackgroundColor',def.col_idle);

%% Search icon

% h=imread(directory of picture);
% set(handles.uicontrol,'CData',h);

% Read from file
img = imread([dynammoroot filesep 'Utilities' filesep 'Pics' filesep 'magn_glass.png']);
img = double(img)./255;

% Flip the image horizontally
img(:,:,1) = fliplr(img(:,:,1));
img(:,:,2) = fliplr(img(:,:,2));
img(:,:,3) = fliplr(img(:,:,3));

% Show it
simg = subplot(1,1,1);
imhan = image(img);
axis(simg,'off');

% Adjust the position and size
% - Position is now absolute (in pixels)
% - size is absolute (in pixels)
set(simg,'units','pixels');
def.simg_toLeft = 30;
def.simg_size = 20;% Original is 95x75
set(simg,'position',[xstart-def.simg_toLeft ystart def.simg_size def.simg_size/95*75]);

%% Handle containers
h_old = cell(0,1);
s1s2simg = {s1;s2;simg;simg2};

%% Initial listbox

% Transform TOC contents
newfields = prep_listbox_fields(toc,def.buf1);

% Positioning

def.self_ydown = 0.05;
def.self_vert_shift = 20; %[px]
xstart = round(def.s1_xstart*fig_w);
xend   = round((1-def.s1_xstart)*fig_w);
xrange = xend-xstart;
ystart = round(def.self_ydown*fig_h);
yend   = fig_h-def.s1_yshift_down - size(h_old,1)*def.txt_h - def.self_vert_shift;
                               % # of preceding subtree rows is initially 0
yrange = yend-ystart;

self = uicontrol('style','list', ...
              'max',1,'min',1, ...%Only 1 row to be selected
              'units','pixels', ...
              'string',newfields, ...
              'fontname','FixedWidth', ...
              'fontsize',fnt_siz); 

set(self,'Position',[xstart ystart xrange yrange]);
set(self,'BackgroundColor',def.col_idle);

%% Global container
dbobj_set = struct();
dbobj_set.self = self;
dbobj_set.h_old = h_old;
dbobj_set.s1s2simg = s1s2simg;
dbobj_set.level = level;
dbobj_set.fig = fig;
dbobj_set.def = def;
dbobj_set.toc = toc;
dbobj_set.fig_col = fig_col;
dbobj_set.orig_name = level;
dbobj_set.this = this;
% dbobj_set.ini_string = ini_string;

%% Register events
set(self,'Callback',@(varargin) browseCallback());% No special arguments
set(s2,'KeyPressFcn',@search_field_callback);% Handles + event listeners are special arguments
% set(s1,'HitTest','off');
set(s1,'Callback',@(varargin) subtreeClick(0));% Super title is 0th among h_old :)
% set(s1,'ButtonDownFcn',@subtreeClick);% Super title is 0th among h_old :)
set(imhan,'ButtonDownFcn',@(varargin) search_field_internal());

%% Resizing must change the layout
% - units 'normalized' will allow the object to change when resizing happens
% - units 'pixels' will keep the object according to its 'position' (southwest corner is the base :()
% - the shape of the magnifying glass must be in fixed pixels, as well as the position

set(fig,'ResizeFcn',@(varargin) resizeCallback_toc());% No special arguments

end %<eof>