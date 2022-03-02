function fighandle = figInitialize(figname,args,figposition)
%
% Initialization of a new figure object
%
% INPUT: figname ...name of the figure
%        args    ...figure options
%        figposition ...coordinates+height+width of the figure (4-element vector)
%
% OUTPUT: fighandle ...handle to the newly generated figure object
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Figure name overruling
if ~isempty(args.suptitle)
    figname = args.suptitle;
end

%% Re-using previously generated figure
if args.reuse && evalin('base','exist(''dynammo_fig_reuse'',''var'')~=0')
    
    fighandle = evalin('base','dynammo_fig_reuse');
    if ishandle(fighandle)
        clf(fighandle);
        return
    end
end

%% Crossroads

if strcmpi(args.visible,'on')
    
    if args.docked==0
        % Show also figure UI components in visible mode
        fighandle = figure('name',figname, ...
                           'visible','on', ...
                           'position',figposition, ...
                           'MenuBar','figure','ToolBar','figure', ...
                           'units','normalized', ...just for plot area definition, 
                                                 ...A4 other than 'dont' changes units to centimeters
                        ...'InvertHardcopy','off', ...printing background colors: preferred way is to do that ex post set(gcf,'InvertHardcopy','off');
                        ...'graphicssmoothing','off', ... -> only a slight performance improvement    
                           'Color',[1 1 1]);
    else
        % Show also figure UI components in visible mode
        fighandle = figure('name',figname, ...
                           'visible','on', ...
                        ...'position',figposition, ...
                           'MenuBar','figure','ToolBar','figure', ...
                           'units','normalized', ...just for plot area definition, 
                                                 ...A4 other than 'dont' changes units to centimeters
                        ...'InvertHardcopy','off', ...printing background colors: preferred way is to do that ex post set(gcf,'InvertHardcopy','off');
                           'Color',[1 1 1]);
    end
    
    % Always on top Java feature
    % + .pdf printer
    % + .pptx exporter
    pushbuttons(fighandle);
        
    % Enable auto xticks when zoomed
    zz = zoom();
    set(zz,'Enable','off');% Zoom is by default NOT clicked...
    set(zz,'ActionPostCallback',@dynammo.plot.updateXticks);
    
else
    
    if args.docked==0
        fighandle = figure('name',figname, ...
                           'visible','off', ...
                           'position',figposition, ...
                           'MenuBar','none','ToolBar','none', ...
                           'units','normalized', ...just for plot area definition, 
                                                 ...A4 other than 'dont' changes units to centimeters
                        ...'InvertHardcopy','off', ...printing background colors: preferred way is to do that ex post set(gcf,'InvertHardcopy','off');
                           'Color',[1 1 1]);
    else
        fighandle = figure('name',figname, ...
                           'visible','off', ...
                        ...'position',figposition, ...
                           'MenuBar','none','ToolBar','none', ...
                           'units','normalized', ...just for plot area definition, 
                                                 ...A4 other than 'dont' changes units to centimeters
                        ...'InvertHardcopy','off', ...printing background colors: preferred way is to do that ex post set(gcf,'InvertHardcopy','off');
                           'Color',[1 1 1]);
    end
end

%% Plot area definition in normalized units
if isfield(args,'fullHeight')
   args.yscale = 1; % >>> figcombine() needs it <<< 
end
setappdata(fighandle,'SubplotDefaultAxesLocation', ...
                    [0.13 0.1100*args.yscale 0.775 0.8150*args.yscale]);
                   %[0.13 0.0100*args.yscale 0.775 0.9150*args.yscale]); %

%% >>> 2014b+ graphics <<<
if dynammo.compatibility.newGraphics % isfield(get(fighandle),'Number')
    fighandle = fighandle.Number;
    set(fighandle,'Renderer','painters');
end

%% PDF/HTML exporting support
if ~strcmpi(args.A4,'dont')
    % Do not move A4 step before figure('position',...) step, units matter
    dynammo.plot.A4(fighandle,args.A4,args.scaling);
end

%% Make the figure handle available for future re-using
if args.reuse
    assignin('base','dynammo_fig_reuse',fighandle);
end

%% AOT feature in debug mode
if args.debug
   AOTfeature(gcf); 
end

end %<eof>