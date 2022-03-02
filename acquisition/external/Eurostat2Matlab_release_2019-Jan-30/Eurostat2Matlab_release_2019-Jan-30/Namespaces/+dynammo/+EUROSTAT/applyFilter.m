function f = applyFilter(dsd,filtering_sets)
%
% !!! Internal function, not to be called by the user
%     tsobj() constructor automatically launches this fcn if the .filter field is empty
% 
% User interface to select exact set of time series from a given table from EUROSTAT
%
% INPUT: dsd   ...Data structure definition from EUROSTAT
%
% OUTPUT: figure handle
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Checks

if ~isstruct(dsd)
    dynammo.error.dbobj('Second argument must be the Data structure definition (dsd)...');
end

%% Stack control <part I>
% In case the user closes the GUI, the function should quit
assignin('base','GUIshutdown',1);

%% Pre-analyze DSD

fields = fieldnames(dsd);
nf = length(fields);

counts = zeros(nf,1);
for ii = 1:nf
    counts(ii) = size(dsd.(fields{ii}),1);
end

heights = counts+1+1;% One extra row if only a few entries in category
                     % Another extra row for "...Please select" row 

handles = struct();
opt = struct();
opt.heights = min(10,heights); % 10 rows is a maximum (scroll bar will appear automatically for longer input)

%% Figure prep

scrn_dims = get(0,'ScreenSize');

fig_col = [0.8 0.8 0.8];
white_col = [0.97 0.97 0.97];
fnt_siz = 10;

fig_w = 0.50*scrn_dims(3);
fig_h = 0.70*scrn_dims(4);
handles.f = figure('Name','Applicable filtering criteria','units','pixels', ...
           'position',[0.25*scrn_dims(3) ...
                       0.25*scrn_dims(4) ...
                       fig_w fig_h], ...
                       'color',fig_col);
f = handles.f;
AOTfeature(f);

% Hide all UI features                                                                   
set(f,'Menubar','none');

%% Positioning params

% Default values
opt.txt_h = 20;% -> default text field height = 20
opt.buf1 = 5;

% Drawing from/to
opt.c1 = 0.05;
opt.c2 = 0.95;
opt.fromTop = 50;
%opt.bar_width = 25;

xstart = round(opt.c1*fig_w);
xend   = round(opt.c2*fig_w);
xrange = xend-xstart;
ystart = fig_h-opt.fromTop;

% newy = ystart;

%% Facade
% newy = ystart-opt.txt_h;
opt.yTopRow = ystart;
handles.facade = uicontrol('Style','text',...
                'Position',[0 opt.yTopRow fig_w fig_h-ystart],...
                'String','', ...
                'BackgroundColor',fig_col);%-0.2*rand(1,3));

%% Status bar background

opt.yBufTop = 12;
handles.statbar_bckgnd = uicontrol('Style','text',...
                'Position',[xstart opt.yTopRow+opt.yBufTop xrange opt.fromTop-2*opt.yBufTop],...
                'String','', ...
                'BackgroundColor',white_col);%-0.2*rand(1,3));
         
%% Selection button

opt.sel_butt_width = 55;
opt.butt_dist = 10;

selbutt_xstart = xend - opt.sel_butt_width - opt.butt_dist;
selbutt_width  = opt.sel_butt_width;
selbutt_ystart = opt.yTopRow+opt.yBufTop;
selbutt_height = fig_h-ystart-2*opt.yBufTop;

handles.selbutt = uicontrol('Style','PushButton',...
    'Position',[selbutt_xstart selbutt_ystart selbutt_width selbutt_height], ...
    'String','Select', ...
    'FontSize',fnt_siz);

%% Check button
% -> this button is in the end made invisible (callbacks+KeyPressFcns used instead)

opt.horzShift = opt.sel_butt_width+opt.butt_dist;
opt.check_select_buff = 60;

selbutt_xstart = selbutt_xstart - opt.horzShift - opt.check_select_buff;
selbutt_width  = opt.sel_butt_width + opt.check_select_buff;
selbutt_ystart = opt.yTopRow+opt.yBufTop;
selbutt_height = fig_h-ystart-2*opt.yBufTop;

handles.chckbutt = uicontrol('Style','PushButton',...
    'Position',[selbutt_xstart selbutt_ystart selbutt_width selbutt_height], ...
    'String','Check selection', ...
    'FontSize',fnt_siz, ...
    'Visible','off');% ZZZ zzz ZZZ zzz

%% Status bar text field

opt.statbar_inset = 8;
handles.statbar_text = uicontrol('Style','text',...
                'Position',[xstart+opt.statbar_inset ...
                            opt.yTopRow+opt.yBufTop ...
                            xrange-2*(opt.sel_butt_width+opt.butt_dist)-opt.butt_dist-opt.check_select_buff ...
                            fig_h-ystart-2*opt.yBufTop-opt.statbar_inset],...
                'String','', ...
                'horizontalalignment','left', ...
                'BackgroundColor',white_col, ...
                'FontSize',fnt_siz, ...
                'FontName','FixedWidth');
            
%% Core objects
hans = cell(2*nf,1);
selection_hans = cell(nf,1);
trigger_no_selection = 0;
opt.fixed_ydrop = 0;
% newy = 
newy = fig_h-opt.fromTop - opt.fixed_ydrop;
for ii = 1:nf
    
    han_id = ii*2;
    % Category code
    newy = newy-opt.txt_h;
    if ii==1
       opt.movingContentStart = fig_h - newy; 
    end
    
    hans{han_id-1} = uicontrol('Style','text',...
                    'Position',[xstart newy xrange opt.txt_h],...
                    'String',['   ' upper(fields{ii}) ':'], ...
                    'horizontalalignment','left', ...
                    ...'verticalalignment','center', ...
                    'fontsize',fnt_siz,'FontName','FixedWidth', ...
                    'BackgroundColor',white_col);
                
    % Items to print in list box
    fnow = dsd.(fields{ii});
%     if size(fnow,1)>1
%        trigger_no_selection = 1; 
%        maxlength2 = max(cellfun('length',fnow(:,2)));
%        fnow = [{'---',['---' repstr(' ',max(1,maxlength2-3))]};fnow]; %#ok<AGROW>
%     end
    nitems = size(fnow,1);
    newfields = cell(nitems,1);
    maxlength = max(cellfun('length',fnow(:,1)));
    for jj = 1:length(newfields)
        cand = fnow{jj,1};
        diff_length = maxlength-length(cand) + 5;% Buffer
        cand = [cand repstr(' ',diff_length)]; 
        newfields{jj} = [cand fnow{jj,2}];
    end
    
    % Draw list box
    yheight = heights(ii)*opt.txt_h+opt.buf1;
    newy = newy-yheight;
    hans{han_id} = uicontrol('style','list', ...
                  'max',nitems+10,'min',1, ...# of maximum/minimum clickable rows at once
                  'Position',[xstart newy xrange heights(ii)*opt.txt_h], ...
                  'string',newfields, ...
                  'fontsize',fnt_siz,'FontName','FixedWidth', ...
                  'BackgroundColor',white_col);
	selection_hans{ii} = hans{han_id};
    newy = newy-opt.txt_h;
    
end

handles.hans = hans;
handles.selection_hans = selection_hans;

%% Initial filter validation
dynammo.EUROSTAT.pickdata.dsd_filter_validator(handles,filtering_sets,dsd);

%% Vertical scrollbar

opt.vert_scrlb_pos = 20;

handles.scrlb =uicontrol('style','slider','Min',0,'Max',1,'SliderStep',[0.05 0.25]);%[1/(10^ceil(log10(abs(newy)))) 0.1]
                        % newy can be either positive (slider is invisible), 
                        % or negative (1/ceil(log10(abs(newy))) becomes relevant)
set(handles.scrlb,'value',1,'position',[fig_w-opt.vert_scrlb_pos 0 opt.vert_scrlb_pos fig_h-opt.fromTop]);

if newy<0
    set(handles.scrlb,'visible','on');
else
    set(handles.scrlb,'visible','off');
end

%% Proper kids ordering

set(handles.f,'children', ...
    cat(1,handles.scrlb, ...
          handles.chckbutt, ...
          handles.selbutt, ...
          handles.statbar_text, ...
          handles.statbar_bckgnd, ...
          handles.facade, ...
          handles.hans{:}));

%% Registering events

% Select button
set(handles.selbutt,'Callback', ...
    @(varargin) dynammo.EUROSTAT.pickdata.selectCallback(handles,dsd));

% Scroll bar click must trigger the same callback as the resizing event
set(handles.scrlb,'Callback', ...
    @(varargin) dynammo.EUROSTAT.pickdata.resizeCallback_dsd(handles,opt));

% Check button - this one is now invisible...
% set(handles.chckbutt,'Callback', @(varargin) checkbutt_dsd(handles,filtering_sets,dsd));

% Main listboxes - 
for ii = 1:nf
    set(selection_hans{ii},'KeyPressFcn', ...
        @(varargin) dynammo.EUROSTAT.pickdata.dsd_filter_validator(handles,filtering_sets,dsd));
    set(selection_hans{ii},'Callback', ...
        @(varargin) dynammo.EUROSTAT.pickdata.dsd_filter_validator(handles,filtering_sets,dsd));
end

% Resizing must change the layout
set(handles.f,'ResizeFcn', @(varargin) dynammo.EUROSTAT.pickdata.resizeCallback_dsd(handles,opt));

% keyboard;

end %<eof>