function out = figclone(gobj_figx)
%
% This utility function creates identical copy of an existing figure
%
% INPUT: gobj_figx ...substructure of gobj relating to a particular figure
%                      -> i.e. to create a copy of figure 1, we input here gobj.fig1)
%                      -> .fig structures from single plots can be transformed inside this fcn 
%
% OUTPUT: gobj of new figure clone
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ishandle(gobj_figx) % -> regular Matlab figure on input
    fhan = dynammo.plot.gcf2obj(gobj_figx);
    gobj_figx = fhan.fig1;
    fhan = fhan.fig1.handle;
    
elseif isfield(gobj_figx,'handle')
    fhan = gobj_figx.handle;
else
    gobj_figx = dynammo.plot.gobj_transform(gobj_figx);
    if isfield(gobj_figx,'fig1')
        gobj_figx = gobj_figx.fig1;
        fhan = gobj_figx.handle;
    else
        error_msg('Cloning','Handle to the original figure was not found...');
    end
end

%% Undock current figure
set(fhan,'WindowStyle','normal');% 'normal'|'docked'

%% Create a copy of already existing figure
% keyboard;
% try
    visibility = get(fhan,'visible');
% catch
%    disp(['The last time we ran into this problem was that fhan was 0 and M2014b+ translated it ' ...
%          'into the "Root" handle while M2014a- would filter out zeros on input']);
%    keyboard; 
% end

% GUI tools handled later after we identify all children
clone = figure('visible',visibility,'name','clone', ...
               'WindowStyle','normal', ...'normal'|'docked'
               'MenuBar','none','ToolBar','none');

% Identify only children that are not part of the figure GUI
% isMenu = get(fhan,'MenuBar');
% set(fhan,'MenuBar','none','ToolBar','none');
kids = get(fhan,'children');% -> is it really safe to get all children, including figure buttons?
                            %    it accidently happened once, but then everything seemed to be ok
                            %    during next attempt :(
                            % SOLVED here by removing the toolbar temporarily and inserting it back according to the original figure

% container = [kids(:) kids(:)];
% for ii = length(kids):-1:1
%           keyboard;  
%     % Copy own kids respecting the original layers
%     container(ii,2) = copyobj(kids(ii),clone);
% 
% end
% container(:,2) = copyobj(kids,clone);
copyobj(kids,clone);

%% Re-generate object structure

% Parent handle
container = [fhan clone];

% Grand kids were already copied in previous step, but their handles needed later
kids_orig = getChildren(fhan);
kids_clone= getChildren(clone);
if ~isempty(kids_orig)
    container = [container;[kids_orig kids_clone]]; 
end

out = dynammo.plot.gobj_generate(gobj_figx,fhan,clone,container);

%% Formatting
set(clone,'units',get(fhan,'units'));
set(clone,'position',get(fhan,'position')+[0 0 0 0]);% !! Do not attempt to perturb the position, it would have to depend on units!

end %<eof>