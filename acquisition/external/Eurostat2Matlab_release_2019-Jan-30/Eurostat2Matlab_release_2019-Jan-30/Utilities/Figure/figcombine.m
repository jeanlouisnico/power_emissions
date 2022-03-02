function gobj_out = figcombine(cellhandles,varargin)
%
% Creates a combination of existing figures 
% - By default, the output figure gets adjusted by fig_redy() to make PDF printing easier
% - It is important to use 'A4' property, otherwise pdfgen() will reprocess the figure one more time
% 
% !!! Multiplots (already in matrix layout) cannot be combined !!! Only simple plots/figoverlays
% No error message is thrown because figoverlays can have many 'subx' fields, just like multiplots
% Multiplot on input will get processed, but with overlaid result :(, 
% legend is therefore in general assumed only on sub1 field
% 
% INPUT: cellhandles ...cell of handles to the original figure objects
%        [options]   ...see the list below
%
% OUTPUT: gobj_out ...handle to the newly created figure new figure clone
%
% EXAMPLE: figcombine({'','',f1;
%                      f2,f2,f2})   -> Existing figure with handle f1 will be placed 
%                                      to the north east position on a page
%                                   -> Existing figure with handle f2 will span 
%                                      the entire lower part of the newly generated figure
% 
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

p = inputParser;

addRequired(p,'cellhandles',@iscell);

if dynammo.compatibility.isAddParameter
   addParameter(p,'suptitle','',@ischar);
   addParameter(p,'clone',0,@(x) any(x==[0;1]));% To work with copies of the original figs
   addParameter(p,'A4','dont',@(x) any(strcmpi(x,dynammo.plot.A4types()))); %'4:3','16:9'
   addParameter(p,'scaling',1,@(x) length(x)<=2);
  %addParameter(p,'reuse',0,@(x) x==0);% Use 'clone' instead, re-using does not make sense
   addParameter(p,'ban_injection',0,@(x) any(x==[0;1]));% Option also used by figoverlay()
   
   addParameter(p,'debug',0,@(x) any(x==[0;1]));
   
else
   addParamValue(p,'suptitle','',@ischar);  
   addParamValue(p,'clone',0,@(x) any(x==[0;1]));% To work with copies of the original figs
   addParamValue(p,'A4','dont',@(x) any(strcmpi(x,dynammo.plot.A4types()))); %'4:3','16:9'
   addParamValue(p,'scaling',1,@(x) length(x)<=2);
  %addParamValue(p,'reuse',0,@(x) x==0);% Use 'clone' instead, re-using does not make sense
   addParamValue(p,'ban_injection',0,@(x) any(x==[0;1]));% Option also used by figoverlay()
   
   addParamValue(p,'debug',0,@(x) any(x==[0;1]));
   
end

p.parse(cellhandles,varargin{:});
args = p.Results;

% Not to be changed
args.reuse = 0;

%% Figure handles
[row,col] = size(cellhandles);
cellhandles = transpose(cellhandles);
cellhandles = cellhandles(:);
cellhandles(cellfun('isempty',cellhandles)) = {0};

fighandles = cellhandles;
for ii=1:length(cellhandles)
    if isstruct(cellhandles{ii})
        % Handle to plotted tsobj on input
        if isfield(cellhandles{ii},'fig')
            % Simple plots
            fighandles{ii} = cellhandles{ii}.fig;
            
        elseif isfield(cellhandles{ii},'fig1')
            % Overlaid figures have .fig1 structure
            fighandles{ii} = cellhandles{ii}.fig1.handle;
            
        elseif isfield(cellhandles{ii},'handle')
            % Cell/struct plots (only figx on input)
            fighandles{ii} = cellhandles{ii}.handle;            
            
        else
            error_msg('Figure combination','Wrong input structure of figures, must be a cell structure of single plot (multiplots are now allowed)...');
        end
        
    elseif cellhandles{ii}~=0
        try % Give chance for regular Matlab figures on input
            
            cellhandles{ii} = dynammo.plot.gcf2obj(cellhandles{ii});
            fighandles{ii}  = cellhandles{ii}.fig1.handle;
            
        catch %#ok<CTCH>
            error_msg('Figure combination','Wrong input structure of figures, must be a cell of plot structures (gobjs + regular Matlab figure handles)...');
        end
        
    end
end

% >>> M2014b+ graphics workaround
% -> Figure handles are entire [1x1 Figure] objects (not numbers), the rest can get thrown away (zeros)
% -> In earlier versions of Matlab fighandles is a vector of type 'double'
figobjs = ~cellfun(@(x) isa(x,'double'),fighandles);
if any(figobjs)
    fighandles = fighandles(figobjs);
    cellhandles = cellhandles(figobjs);
end

fighandles = cat(1,fighandles{:});
handles = unique(fighandles);% !!!!!! sorting is applied here, if the output has always different ordering of the contents
                             %        and makes it difficult to catch e.g. legend always in the same subx,
                             %        cloning forces the figure handles always to be assigned in ascending order
                             %        therefore it makes sense not to close any of the byproducts which serve
                             %        for creation of the components that consequently get combined using this fcn.
                             %
                             %        >>> the ultimate cause of this has been tracked to figoverlay(), 
                             %            where we create clones of f2 before f1 <<<
if length(handles)==length(fighandles)
   handles = fighandles; % This makes the above sorting in unique() ineffective, but may not be a solution for more complex cases...
end

if any(handles==0)
    handles = handles(2:end);
end

% <gobj> structures
gobjs = cell(length(handles),1);
nhans = length(handles);
isMenu = cell(length(handles),1);
for ihan = 1:nhans
    gobjs(ihan) = cellhandles(find(handles(ihan)==fighandles,1,'first'),1);
    
    % Temporary hide the figure GUI tools
    isMenu{ihan} = get(handles(ihan),'MenuBar');% 2014b+ compatible
    set(handles(ihan),'MenuBar','none','ToolBar','none');
    
end

%% Create identical copies of the original figures

% keyboard;

if args.clone==1
    
    % Create clones and leave the original figures untouched
    for ihan = 1:nhans
        
        gobjs{ihan} = figclone(gobjs{ihan});
        
    end
    
else
    
    % Process & destroy current figures
    for ihan = 1:nhans
        
        gobjs{ihan} = dynammo.plot.gobj_transform(gobjs{ihan});
        gobjs{ihan} = gobjs{ihan}.fig1; % fig1 always exists after taking the gobj_transform
        
        % Undock all figures
        set(gobjs{ihan}.handle,'WindowStyle','normal');% 'normal'|'docked'
        
    end
    
end

args.docked = 0;

%% New figure

figname = 'Combined figure';

% Scaling factor for potential super title 
args.yscale = dynammo.plot.yscale_size(args.A4);

% Visibility on (plot), off (reporting)
args.visible = get(handles(1),'visible');

shelf = 100;
screen_dims = get(0,'ScreenSize');
% orig_visibility = args.visible;

% figInitialize() in invisible mode does not generate GUI tools, which is what we need
% args.visible = 'off';

% ### New figure ###
args.fullHeight = 1;
outhan = dynammo.plot.figInitialize(figname,args,[shelf shelf screen_dims(3)-2*shelf screen_dims(4)-2*shelf]);

%% Object creation
nsub_visible = length(handles); % The # of visible subplots (each of which can be made up of several other subplots)
gobj_out.handle = outhan;

%% Correct tagging

if strcmpi(args.A4,'dont')
    
    % At least set the correct tag
    set(gobj_out.handle,'Tag','figready_dont');
    
end

%% Object shuffling
counter = 0;
for ihan = 1:nsub_visible
  hannow = handles(ihan);
    where = find(fighandles==hannow);
    loc = [min(where) max(where)];

    % Sniffing for space
    getPositions()
        
    % Transmit subplot handles <including legend>
    % sub -> sub1 encapsulation
    origfig = gobjs{ihan};

    candidates = sublist(fieldnames(origfig),'sub','<');
    lcan = length(candidates);
    for ic = 1:lcan 
        %subn = ['sub' sprintf('%.0f',ic+counter)];
         subn =        sprintf('sub%.0f',ic+counter);
        gobj_out.(subn) = origfig.(candidates{ic});% suptitle is dropped here intentionally
        
    end
    counter = inc(counter,lcan);
    
    % Current f2 contents
    ch = get(origfig.handle,'children');% Including diffs

    % Moving step
    for ik = length(ch):-1:1
        if ~strcmpi(get(ch(ik),'tag'),'legend') && ...
           ~strncmpi(get(ch(ik),'Type'),'ui',2)
       
            if strcmpi(get(ch(ik),'tag'),'suptitle')
                if isempty(args.suptitle)
                    % Inherit suptitle only if figcombine() does not have one on input
                    % -> if more suptitles in input figures, only the last matters
                    args.suptitle = get(get(ch(ik),'children'),'String');
                else
                    % No warning! The user obviously knows why 'suptitle' must be ignored
                    %warning_msg('Figure combine','''suptitle'' from input figure will be ignored ...'); 
                end
            else
                %keyboard;
                % Legends should not end up here
                set(ch(ik),'parent',outhan,'position',pos); %set(f2.sub1.handle,'parent',f1.handle);
            end
            
        else
            % Delete legend from the list of children
            ch(ik) = [];
        end
    end
    nch= length(ch);
    
    % Plug back the figure GUI tools
    if strcmpi(isMenu{ihan},'figure')
        set(handles(ihan),'MenuBar','figure','ToolBar','figure');
        pushbuttons(handles(ihan));

        % Clone too
        if args.clone==1
            set(gobjs{ihan}.handle,'MenuBar','figure','ToolBar','figure');
            pushbuttons(gobjs{ihan}.handle);
        end
        
    end
    
    
    if isfield(origfig.sub1,'legend') % After dynammo.plot.gobj_transform() the legend, if any, must be in sub1
                                      % Multiplots cannot be handled with this function 
                                      % (difficult to throw an error message since figoverlays can have similar structure)
        
        if dynammo.compatibility.M2017a
%             keyboard;
            lg = origfig.sub1.legend;%,'Legend');
            
        else
            lg1 = get(origfig.sub1.legend,'UserData'); 
% keyboard;
            lghandles = lg1.handles(:);
            lgstrings = lg1.lstrings(:);

            set(0,'currentfigure',outhan);

            if ~dynammo.compatibility.M2016a

                % !!! This is a final stage for legends, no need to store UserData structure, figcombine() can only be called once
                %     (except legend_best2() needs convHull)

                [lg,entries] = legend(origfig.sub1.handle,lghandles,lgstrings);
                set(lg,'color',[1 1 1]);

                % !!! convHull is called via evalin('caller',...)
                convHull = dynammo.plot.convexHull_legacy2014b(origfig.sub1.handle); %#ok<NASGU>

                % Mouse clicks
    %             if strcmpi(get(origfig.handle,'visible'),'on')
    %                 tmp = get(lg,'Userdata');
    %                 for ient = 1:size(tmp.handles,1)
    %                     item = get(tmp.handles(ient));
    %                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                     if isfield(item,'Color') % Probably line ('Color' may be shared across more objects)
    %                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                         colors = get(tmp.handles(ient),'Color');
    %                         set(entries(ient), 'HitTest', 'on', 'ButtonDownFcn',...
    %                             @(varargin) legendClick(ient,entries,colors,lghandles), ...
    %                             'UserData', true);
    % 
    %                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %                     elseif isfield(item,'FaceColor') % bars have 'FaceColor' property
    %                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %                         set(entries(ient), 'HitTest', 'on', 'ButtonDownFcn',...
    %                             @(varargin) legendClick(ient,entries,[],origfig.sub1.data{1},origfig.sub1.data{2}), ...
    %                             'UserData', true);
    % 
    %                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                     else % Unexpected situation
    %                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                         error_msg('Figcombine','Untreated situation occurred...');
    % 
    %                     end
    %                 end
    % 
    %             end     

            %%%%%%%%%%%%%%%%%%%%%
            else % M2016a+
            %%%%%%%%%%%%%%%%%%%%%

                % !!! This is a final stage for legends, no need to store UserData structure, figcombine() can only be called once
                %     (except legend_best2() needs convHull)

                if iscell(lghandles) % -> bar graph
                    lg = legend(origfig.sub1.handle,lghandles{1},lgstrings);% only 1st half of handles assumed
                    %lg.UserData.handles = {origfig.sub1.data{1};origfig.sub1.data{2}};
                else % -> line graph
                    lg = legend(origfig.sub1.handle,lghandles,lgstrings);
                    %lg.UserData.handles = double(lg.PlotChildren(:));
                end
                set(lg,'color',[1 1 1]);

                %lg.UserData.lstrings = lg.String(:);%lstrings(:);
                %lg.UserData.LabelHandles = entries;
                %lg.UserData.PlotHandle = origfig.sub1.legend;% Note that this field is not linked as a listener when the value changes
                                                             % -> gobj_generate() uses it, but it should work
                %lghandle.UserData.LegendPosition -> better to take it directly from legend handle (it is connected to listeners, when units/pos change)

                % Data envelope
                lg.UserData.convHull = lg1.convHull;

                % Mouse clicks
    %             if strcmpi(get(origfig.handle,'visible'),'on')
    %                 set(lg,'ItemHitFcn',@lgndItemClick);
    %             end             

            end
            
        end
        
        %drawnow;
        if args.ban_injection
            legend_best2(origfig.sub1.handle,lg,'no_inject');
        else
            legend_best2(origfig.sub1.handle,lg); 
        end

        gobj_out.(sprintf('sub%.0f',counter-lcan+1)).legend = lg;
        
    end

    % Update ylimits for patch (highlight) objects (top layer figure)
    % -> only the top sub1 necessary to check here, legend_best is applied to the top-most layer only
    if isfield(origfig.sub1,'highlighted')
           highs = origfig.sub1.highlighted;
           for ih = 1:length(highs)
               correct_ylims = get(get(highs{ih},'parent'),'ylim');
               set(highs{ih},'ydata',[correct_ylims(1)*ones(1,2) correct_ylims(2)*ones(1,2)]);
           end    
    end
    
end   

%% Super title

% Empty space was allocated previously in getPositions() no matter if suptitle is used or not
if ~isempty(args.suptitle)
    
    gobj_out.suptitle=dynammo.plot.suptitle_fast(outhan,args.suptitle,args.A4);

end

%% Destroy original graphs (these can also be clones)
for ihan = 1:nhans
    close(gobjs{ihan}.handle);
end
 
%% Final output
ftmp.fig1 = gobj_out;
gobj_out = ftmp;

%% Visibility treatment
% if strcmpi(orig_visibility,'on')
%     set(outhan,'visible','on');
% end

%% Nested functions

    function getPositions()
%         keyboard;
        temp_ = subplot(row,col,loc);
        pos = get(temp_,'position');
        
        % Make space for suptitle (even though it may stay empty)
        yscale = dynammo.plot.yscale_size(args.A4);
        pos(2) = pos(2)*yscale;
        pos(4) = pos(4)*yscale;
        
        delete(temp_);
        
    end %<getPositions>

end %<eof>