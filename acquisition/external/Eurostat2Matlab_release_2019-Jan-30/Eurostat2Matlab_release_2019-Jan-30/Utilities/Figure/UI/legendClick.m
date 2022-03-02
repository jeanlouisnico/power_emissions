function legendClick(ient,legObj,colors,obj,varargin)
%
% Show/hide plotted objects (works on M2014a and older)
%
% INPUT: ient   ...item # clicked
%        legObj ...legend entry handle
%        colors ...colorset for line graphs only
%                   -> for bar graphs provide []
%        obj    ...line in graph (handle)
%       [obj2]  ...second set of graph objects related to 1 legend entry (applicable to bar graphs)
% 
% OUTPUT: none
%
% SEE ALSO: lgndItemClick() -> works on M2014b+
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

ient_orig = ient;

%% Augmented selection
% -> all line/bar objects are toggled at once
if strcmpi(get(gcf,'SelectionType'),'extend') % SHIFT+click

    % Select/de-select all items at once    
    ient = 1:length(obj);
    ient = ient(:)';

end
    
%% Body

if nargin>4 % Bar graphs have 1 legend entry, but possibly + and - data series
    
    obj2 = varargin{1};
    
    % Decide on the direction
    cond = get(legObj(ient_orig), 'UserData'); % It is on, turn it off
    
    % Do the action for one/all legend items according to the click type
    for ii = ient
        
        legObj_now = legObj(ii);
        obj_now = obj(ii);
        obj2_now = obj2(ii);
        
        % Swap happens here
        if cond
            set(obj_now,'HitTest','off','Visible','off','handlevisibility','off');
            set(obj2_now,'HitTest','off','Visible','off','handlevisibility','off');% This line is the only difference!!!
            set(legObj_now, 'Color', [0.5 0.5 0.5], 'UserData', false);
        else
            set(obj_now, 'HitTest','on','visible','on','handlevisibility','on');
            set(obj2_now, 'HitTest','on','visible','on','handlevisibility','on');% This line is the only difference!!!
            set(legObj_now, 'Color', [0 0 0], 'UserData', true);
        end
        
    end
    
else % Regular line plot
    
    % Decide on the direction
    cond = get(legObj(ient_orig), 'UserData'); % It is on, turn it off
    
    % Do the action for one/all legend items according to the click type
    for ii = ient
%         keyboard;
        legObj_now = legObj(ii);
        obj_now = obj{ii};
        
        % Swap happens here
        if cond
            %set(obj_now,'HitTest','off','Visible','off','handlevisibility','off');
            set(obj_now,'Color', [0.85 0.85 0.85],'MarkerSize',0.01);%'HitTest','off','Visible','off','handlevisibility','off');
            set(legObj_now, 'Color', [0.5 0.5 0.5], 'UserData', false);%(get(legObj_now, 'Color') + 1)/1.5
        else
            %set(obj_now, 'HitTest','on','visible','on','handlevisibility','on');
            set(obj_now, 'color',colors(ii,:),'MarkerSize',6);%'HitTest','on','visible','on','handlevisibility','on');
            set(legObj_now, 'Color', [0 0 0], 'UserData', true);%get(legObj_now, 'Color')*1.5 - 1
        end
        
    end

end

end %<eof>