function browseCallback(varargin)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Access to globals
global dbobj_set;

%% Single click does nothing
% -> 'normal' marks a single click on gcf
% -> 'open' indicates a double click on gcf

% Internal recursive calls will always be calculated,
% only the user calls will be tested for double-clicking
if nargin==0
    if strcmpi(get(gcf,'SelectionType'),'normal')
       return 
    end
end

% keyboard;

%% Pull some info
self = dbobj_set.self;
h_old = dbobj_set.h_old;
s1s2simg = dbobj_set.s1s2simg;
level = dbobj_set.level;
% fig = dbobj_set.fig;
def = dbobj_set.def;
%last_row_y = dbobj_set.last_row_y;
toc = dbobj_set.toc;
% whoClicked = dbobj_set.whoClicked;

%% Busy status notification
set(self,'BackgroundColor',dbobj_set.def.col_busy);

%% Current dimensions

dims = get(gcf,'position');
fig_w = dims(3);
fig_h = dims(4);

%% Analyze the clicked row

% keyboard;

% Future level entries
row = get(self,'value');
curr_values = get(self,'string');
try
    curr_val = curr_values{row};
catch
   keyboard; 
end
% Tree contents must always be named 'toc' in this fcn
level = regexprep(level,'\w*','toc','once');

% Future level
% + nargin>0 happens if the user clicked the search results
% if nargin==0
    curr_val_naked = regexprep(curr_val,'<a.*?a>[ ].*?','');%'\[link.+?\][ ].*?',''); \[.*?\].*?
    %level = [level '.' regexp(curr_val,'(?<=>)\w+','match','once')];
    level = [level '.' regexp(curr_val_naked,'(?<=>)\w+','match','once')];
% end

% User clicked on a final table (not a subtree)
% crit = regexpi(curr_val,'(?<==")\w+(?=")','match','once');
% if strcmpi(crit,'blue') || strcmpi(crit,'888888')
crit_no_link = ~isempty(strfind(curr_val,'[link N/A]'));% || ...
crit_link_ready = ~isempty(strfind(curr_val,'[link ready]'));
if crit_link_ready || crit_no_link
    

    orig_name = dbobj_set.orig_name;
    try
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Table from current tree level clicked
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tableInfo = eval(level);
    catch
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Adjust the level to match currently clicked table (this happens if search results were clicked)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Get the last occurrence (table name)
        tmp = regexp(fliplr(level),'\.','split','once');
        tablename  = fliplr(tmp{1});%fliplr(regexp(fliplr(level),'\w+','match','once'));
        current_level = fliplr(tmp{2});
        
        % Find the table in the structure
        %[level,~] = table_finder(toc,tablename,'toc'); % 
         [level,~] = table_finder(eval(current_level),tablename,current_level);
        tableInfo = eval(level);
        
    end

    tmp = dbobj_set.this;
    tmp.table = tableInfo;
    
    % Listeners are not responsive, must be updated manually
    tmp.filter = '';
    tmp.status = 'Empty filter: tsobj() call will give available filtering options...';
    
    n = length(level);
    %fprintf('\n\n%s',repstr('%%',max(n,21)+3));
    fprintf('\n\n%s%s\n',' %%% >>> <strong>Table definition</strong> <<< %%%',repstr('%',max(n-33,0)+8));
    fprintf('%s\n',['     ' tableInfo.title]);
    if crit_link_ready %strcmpi(crit,'blue')
        fprintf(2,'%s\n',['     ' level]);
    else
        fprintf(2,'%s\n',['     ' '!!! Unfortunately, EUROSTAT does not allow downloading of this table :(']);
    end
    fprintf('%s%s%s\n',' ',repstr('%',33),repstr('%',max(n-33,0)+8));
    fprintf('%s\n\n',['     Need <a href="matlab: ' ...
                  'disp('' -> ''''toc.'''' in the above structure refers to ''),' ...
                  'disp(''    the result of TOC() function''),' ...
                  'disp(''    (the EUROSTAT Table of contents)''),' ...
                  'fprintf(''\n'')">help</a>?']);              
    assignin('base',orig_name,tmp);
    
    set(self,'BackgroundColor',dbobj_set.def.col_idle);
    
    return
    
end

% keyboard;
try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Enter higher tree level
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subTree = eval(level);
    
catch
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Adjust the level to match currently clicked subtree (this happens if search results were clicked)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Get the last occurrence (table name)
    tablename = fliplr(regexp(fliplr(level),'\w+','match','once'));
    actLevel = regexprep(level,['\.' tablename],'');
    subTree = eval(actLevel);
    
    % Find the table in the structure
    [level,~] = table_finder(toc,tablename,'toc');
    
    % List of all higher lavels
    levels = regexp(level,'\.','split');
    levels = levels(:);
    
    % Determine current subTree level
    % + no need to delete current subTree structure -> all search results are from the current subTree
    nh = size(h_old,1);
    
    % Transform TOC contents
    newfields = prep_listbox_fields(subTree,def.buf1);%dbobj_set.toc
    
    % Update the listbox
    set(self,'value',1);% !!! Must precede the next 'String' assignment !!!, old value might be higher than the new range
    set(self,'String',newfields); 
    
    % Select correct row
    [~,~,nakedFields] = prep_listbox_fields(subTree,def.buf1);
    rowSelect = find(strcmp(levels{1+nh+1},nakedFields)); % 2 is the minimum length of levels (base TOC + the one in which the search passed its crit.)
    set(self,'value',rowSelect);
    
    dbobj_set.level = actLevel;
    for ifloor = (1+nh+1+1):length(levels); % 1 was subTree was already done out of the for cycle
        
        % Recursion
        browseCallback(0);% -> 0 here just to make the nargin>0
        
        % Get current listbox contents
        [~,~,nakedFields] = prep_listbox_fields(eval(dbobj_set.level),def.buf1);
         
        % Select correct row
        rowSelect = find(strcmp(levels{ifloor},nakedFields));
        set(self,'value',rowSelect);

    end
    
    % Final call
    browseCallback(0);% -> 0 here just to make the nargin>0
    
    % Update the layout
    resizeCallback_toc();
    
    set(self,'BackgroundColor',dbobj_set.def.col_idle);
    
    return
    
end
    
% Transform TOC contents
[newfields,maxlength] = prep_listbox_fields(subTree,def.buf1);

% Update subtree structure
nh = size(h_old,1);

xstart = round(def.s1_xstart*fig_w);% + def.x_extra_subtree*(nh+1);% +1 -> 1 extra for the newly generated row...
xend   = round((1-def.s1_xstart)*fig_w);
xrange = xend - xstart;%
ystart   = fig_h-def.s1_yshift_down - (nh+1)*def.txt_h;

% Get rid of spaces and HTML tags
% value_to_print = regexprep(curr_val,['(&nbsp;){1,' sprintf('%.0f',maxlength+def.buf1+1) '}'],' | ');
value_to_print = regexprep(curr_val_naked,['(&nbsp;){1,' sprintf('%.0f',maxlength+def.buf1+1) '}'],' | ');
% value_to_print = regexp(value_to_print,'(?<=<BODY.+?>).+?(?=</BODY>)','match','once'); % ### if HTML colors used (color tag present)
  value_to_print = regexp(value_to_print,'(?<=<BODY.*?>).+?(?=</BODY>)','match','once'); % ### if default JAVA colors used

% Draw another row for this given subtree
h_old{end+1,1} = uicontrol('Style','checkbox',...text
            'units','pixels',...
            'String',[repstr(' ',def.x_extra_subtree*(nh+1)) char(187) ' '  ...
                                value_to_print ' ' char(171)], ...
            'horizontalalignment','left', ...
            ...'verticalalignment','center', ...option does not exist :(
            'fontsize',12,'FontName','FixedWidth', ...
            'BackgroundColor',dbobj_set.fig_col);%
set(h_old{end,1},'Position',[xstart ystart xrange def.txt_h]);
set(h_old{end,1},'Callback',@(varargin) subtreeClick(length(h_old)));

% Update the listbox
set(self,'String',newfields); 
set(self,'value',1);

%% Update the global container
dbobj_set.self = self;
dbobj_set.h_old = h_old;
dbobj_set.s1s2simg = s1s2simg;
dbobj_set.level = level;
% dbobj_set.fig = fig;
dbobj_set.def = def;
dbobj_set.toc = toc;

%% Adjust the layout

% Non-empty nargin if the search results were clicked
% resizing is done manually in that case after the recursion completely finishes
if nargin==0
    resizeCallback_toc();
end

%% Task done notification
set(self,'BackgroundColor',dbobj_set.def.col_idle);

end %<eof>