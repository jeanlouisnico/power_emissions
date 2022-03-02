function search_field_internal()
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Access to globals
global dbobj_set;

%% Body

src = dbobj_set.s1s2simg{2};
set(src,'BackgroundColor',dbobj_set.def.col_busy);
set(dbobj_set.self,'BackgroundColor',dbobj_set.def.col_busy);
set(dbobj_set.self,'Value',1);

% Get listing of found entries
pause(0.01);
str = get(src,'String');
% keyboard;
% Process the input string
% [1] "..." strict matches (applies to inside a word as well)
strict_str = regexp(str,'(?<=").+?(?=")','match'); % -> "..." strict match between "" (these must be found to match the field)
for imatch = 1:length(strict_str)
    str = strrep(str,['"' strict_str{imatch} '"'],'');
end
% [2] word matches (applies to inside a word as well)
tmp = regexp(str,' ','split');
strings = tmp(~cellfun('isempty',tmp(:)));% Single words to be matched (all must be present to match the final)
nstr = length(strings);
nstr2 = length(strict_str);

% Fetch some stuff
toc = dbobj_set.toc; %#ok<NASGU>
level = dbobj_set.level;

% Clear values from the listbox
set(dbobj_set.self,'String',{' Searching...'});
pause(0.05);

% Tree contents must always be named 'toc' in this fcn
level = regexprep(level,'\w*','toc','once');
toclevel = eval(level);

% Start recursive search
assignin('base','search_success',0);
% dbobj_set.success = 0;
exploreLevel(dbobj_set,toclevel);

% No results found
if evalin('base','search_success')==0
    set(dbobj_set.self,'String',{' No results found :('});
end

set(dbobj_set.self,'BackgroundColor',dbobj_set.def.col_idle);
set(src,'BackgroundColor',dbobj_set.def.col_idle);

%% Subfunction

    function exploreLevel(dbobj_set,toclevel)
        
        prep_listbox_fields_internal();
        
        if size(addfields,1)~=0
            assignin('base','search_success',1);
            
            % Update the enlisted values
            vals = get(dbobj_set.self,'String');
            if strcmp(vals{1}(1),' ');% Searching... text with a space at the beginning
                % Start from scratch
                set(dbobj_set.self,'String',addfields);
            else
                % Add new fields
                set(dbobj_set.self,'String',[vals;addfields]);
            end
            
        end
        
        % Recursion
        if any(tab_ind==0)
            for ifield = 1:length(fds)
                exploreLevel(dbobj_set,toclevel.(fds{ifield}));
            end
        end
        
        %% Subfunction
        function prep_listbox_fields_internal()
        % this fcn is based on prep_listbox_fields
        
        fds = fieldnames(toclevel);
        nfds = length(fds);

        expl = cell(nfds,1); % with 1 empty field
        codes = cell(nfds,1);% with 1 empty field
        tab_ind = zeros(nfds,1);% with 1 empty field
        linkReady = zeros(nfds,1);% with 1 empty field
        taken = zeros(nfds,1);
        
        for ii = 1:nfds%:-1:1
            if strcmpi(fds{ii},'downloadLink')
                continue
            end
            
            fnow = toclevel.(fds{ii});
            
            if ~isstruct(fnow)
                % title is a string, but is not processed 
            else
                
                % Check if the next child is another subtree, or a table
                if isfield(fnow,'downloadLink')
                    tab_ind(ii,1) = 1;
                    if ~isempty(fnow.downloadLink.bulk)
                        linkReady(ii,1) = 1;
                    end                    
                end
                
                try
                    expl{ii} = fnow.title;
                catch
                    keyboard;
                end
                codes{ii} = fds{ii};

                % Strict match using "..." (should not be found inside a word, only exact phrase)
                foundnow2 = 1;
                for jj = 1:nstr2
                    isExpl = 1;
                    isCode = 1;
                    if isempty(regexpi(expl{ii},['(?<![a-z])' strict_str{jj} '(?![a-z])'],'once'))
                        isExpl = 0;
                    end
                    if isempty(regexpi(codes{ii},['(?<![a-z])' strict_str{jj} '(?![a-z])'],'once'))
                        isCode = 0;
                    end
                    if (isExpl+isCode)==0
                       foundnow2 = 0;
                       break
                    end                        
                end

                % Space free expression (can be found inside a word)
                foundnow = 1;
                for jj = 1:nstr
                    isExpl = 1;
                    isCode = 1;
                    if isempty(regexpi(expl{ii},strings{jj},'once'))
                        isExpl = 0;
                    end
                    if isempty(regexpi(codes{ii},strings{jj},'once'))
                        isCode = 0;
                    end
                    if (isExpl+isCode)==0
                       foundnow = 0;
                       break
                    end
                end
                taken(ii,1) = (foundnow2+foundnow)==2;% Both must be found
                
            end
            
        end
        
        % Empty entry because of 'title' field ( + 'creationDate')
        empties = cellfun('isempty',codes);
        codes = codes(~empties);
        expl = expl(~empties);
        tab_ind = tab_ind(~empties,1);
        taken = taken(~empties,1);
        linkReady = linkReady(~empties,1);
        fds = fds(~empties);
        
        if sum(taken)==0
            addfields = cell(0,1);
            return
        end

        % Alignment
        maxlength = max(cellfun('length',codes));
        addfields = cell(sum(taken),1);
        counter = 1;
        for jj = 1:length(codes)
            if taken(jj,1)==1
                cand = codes{jj};
                diff_length = maxlength-length(cand) + dbobj_set.def.buf1;% Buffer
                cand = [cand repstr('&nbsp;',diff_length)];  %#ok<AGROW>
                if tab_ind(jj,1) == 1
                    if linkReady(jj,1)
                        %addfields{counter} = sprintf('<HTML><BODY color="%s">%s</BODY></HTML>','blue', [cand expl{jj}]);%FF9900
                         addfields{counter} = sprintf('<HTML><BODY>%s</BODY></HTML>', ['<a color="0099FF">[link ready]</a> ' cand expl{jj}]);%FF9900
                    else
                        %addfields{counter} = sprintf('<HTML><BODY color="%s">%s</BODY></HTML>','blue', [cand expl{jj}]);%FF9900
                         addfields{counter} = sprintf('<HTML><BODY>%s</BODY></HTML>', ['<a color="FF0000">[link N/A]&nbsp;&nbsp;</a> ' cand expl{jj}]);%FF9900
                        
                    end
                else
                    %addfields{counter} = sprintf('<HTML><BODY color="%s">%s</BODY></HTML>','black',[cand expl{jj}]);
                     addfields{counter} = sprintf('<HTML><BODY>%s</BODY></HTML>',[cand expl{jj}]);
                end
                counter = counter + 1;
            end
        end

        end %<prep_listbox_fields_internal>

    end %<exploreLevel> 
        
end %<eof>