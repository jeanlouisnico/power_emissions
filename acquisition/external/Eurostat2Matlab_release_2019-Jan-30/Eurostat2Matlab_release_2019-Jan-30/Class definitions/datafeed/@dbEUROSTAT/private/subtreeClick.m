function subtreeClick(whoClicked)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Access to globals
global dbobj_set;

%% Unclick the checkbox
if whoClicked==0
    % Top layer click
    set(dbobj_set.s1s2simg{1},'value',0)
    h_old = dbobj_set.h_old;% Here for speed
    
else
    % Subtree click 
    h_old = dbobj_set.h_old;% Here because it's needed...
    set(h_old{whoClicked},'value',0)
        
end

%% New set of children

% Delete all children
nh = size(h_old,1);
for ii = (whoClicked+1):nh
    delete(h_old{ii});
end

% Update the list of children
dbobj_set.h_old = h_old(1:whoClicked,1);

% Update the level at which we are now
if any(strfind(dbobj_set.level,'.'))
    parts = regexp(dbobj_set.level,'\.','split');
    newend = find(strcmp(parts{whoClicked+1},parts(:)));
    tmp = parts{1};
    for ii = 2:newend
        tmp = [tmp '.' parts{ii}]; 
    end
    dbobj_set.level = tmp;
else
    % This is already the top level, no need to adjust
end

%% Update the listbox as well

level = dbobj_set.level;
def   = dbobj_set.def;
self  = dbobj_set.self;
toc   = dbobj_set.toc; %#ok<NASGU>

% Tree contents must always be named 'toc' in this fcn
level = regexprep(level,'\w*','toc','once');

% Transform TOC contents
[newfields,~] = prep_listbox_fields(eval(level),def.buf1);

% New values for the listbox
set(self,'String',newfields); 
set(self,'value',1);

%% Adjust the layout
resizeCallback_toc();

end %<eof>