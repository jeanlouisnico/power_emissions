function fig2print(inputfig,varargin)
%
% Sets up paper position prior to PDF printing
% -> this is a more general wrapper for dynammo.plot.A4() 
%    which requires numeric handle on input
%
% INPUT: inputfig    ...gobj structure, or numeric handle to the figure
%       [orientation]...'portrait'/'landscape'/'dont'/'slide' paper orientation (a string)
%                       'dont' type only marks the figure with a 'dont' tag,
%       [scaling]    ...by default scaling is not applied (==[1 1])
%                       scaling=1.5 -> both dimensions augmented by a factor 1.5
%                       scaling=[1.2 1] -> only the width gets augmented
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input recognition

if isstruct(inputfig)
    
    %gobj_input = 1;
    
    % Handle to plotted tsobj on input
    if isfield(inputfig,'fig')
        % Simple plots
        inputfig = inputfig.fig;
        
    elseif isfield(inputfig,'fig1')
        % Overlaid figures have .fig1 structure
        inputfig = inputfig.fig1.handle;
        
    elseif isfield(inputfig,'handle')
        % Cell/struct plots (only figx on input)
        inputfig = inputfig.handle;
        
    else
        error_msg('Figure combination','Wrong input structure of figures, must be a cell structure of single plot (multiplots are now allowed)...');
    end

elseif inputfig==0
    error_msg('Figure formatting','Input figure unrecognized...');
    
else
    % No need to do anything
    % gobj_input = 0;    
end

% Correct object structure
gobj = dynammo.plot.gcf2obj(inputfig);

%% Options validation (paper orientation)
if nargin>1
    orientation = varargin{1};
else
    orientation = 'landscape'; 
end
if ~any(strcmpi(orientation,{'landscape','portrait','dont','slide'})) %'4:3','16:9'
    error_msg('Paper positioning','2nd argument to figready() should be a string:',{'landscape','portrait','dont','slide'}); %'4:3','16:9'
end

%% Don't case
% User did not wish any paper positioning
% - this might be useful if e.g. figoverlay() is called and the PDF reporting is not needed
if strcmpi(orientation,'dont')
    
    % Only mark the object, don't do anything else
    set(gobj.fig1.handle,'Tag',['figready_' orientation]);
    
    % Input mirroring on output
    %if gobj_input
    %    outfig = gobj;%.fig1.handle;
    %else
    %    outfig = gobj.fig1.handle;
    %end
    
    return
    
end

%% Paper positioning + figure tagging
if nargin>2
    scaling = varargin{2};
    if length(scaling)==1
        scaling = [scaling scaling];
    end
else
    scaling = [1 1]; 
end

dynammo.plot.A4(gobj.fig1.handle,orientation,scaling);

%% Input mirroring on output
% if gobj_input
%     outfig = gobj;%.fig1.handle;
% else
%     outfig = gobj.fig1.handle;
% end
     
end %<eof>