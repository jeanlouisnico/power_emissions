function crop(gobj,varargin)
%
% Crops active figure /function incomplete, difficult to cope with multiple subs in 1 figure/
%
% INPUT: gobj ...set of handles to a graph
%       [buffers] ...optional set of buffer values to influence cropping 
%
% OUTPUT: ...
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

error_msg('Function','Last several times this fcn produced a bullshit. Suggested workflow:', ...
                    {'[*] dynammo.plot.cropSides() if vertical white space (on the left+right) is too big';
                     '[*] dynammo.plot.cropTitleArea() if the top part above graph matters';
                     '[*] dynammo.plot.legendSpace() to manipulate the white space below graph'});


%% Optional padding
if nargin==1
    buf_ = [0.01 0 0 0];
else
    buf_ = varargin{1};
end

%% Body

if isfield(gobj,'fig') % Simple plot

    if isfield(gobj.sub,'handle')
        ax = gobj.sub.handle;
    else
        ax = gobj.sub;
    end
    getDims();
    left1 = left;
    bottom1 = bottom;
    ax_width1 = ax_width;
    ax_height1 = ax_height;
    
    if isfield(gobj,'diffs')
        ax = gobj.diffs.axis;
        getDims();
        
            if left>left1
                left1 = left;
            end
            if bottom>bottom1
                bottom1 = bottom;
            end
            if ax_width<ax_width1
                ax_width1 = ax_width;
            end
            if ax_height<ax_height1
                ax_height1 = ax_height;
            end
        
    end
    
    set(ax,'Position',[left1 bottom1 ax_width1 ax_height1]);        
    
else % Multiple figures / multiple axes on a figure
    f = fieldnames(gobj);
    for ifig = 1:length(f)
        pos1 = 0;
        pos2 = 0;
        pos3 = Inf;
        pos4 = Inf;
        subs = findobj(gobj.(f{ifig}).handle,'type','axes');
        for isub = 1:length(subs)
            ax = subs(isub);
            getDims();
            if left>pos1
                pos1 = left;
            end
            if bottom>pos2
                pos2 = bottom;
            end
            if ax_width<pos3
                pos3 = ax_width;
            end
            if ax_height<pos4
                pos4 = ax_height;
            end
        end
        for isub = 1:length(subs)
            set(subs(isub),'Position',[pos1 pos2 pos3 pos4]);
        end
    end
    
end

%% Support functions

    function getDims()
%         keyboard;
        outerpos = get(ax,'OuterPosition'); % [left bottom width height]
        ti = get(ax,'TightInset'); % [left bottom right top] ...read only property!
%         keyboard;
%         newpos = outerpos + ti + buf_;
        left = outerpos(1) + ti(1) + buf_(1);
        bottom = outerpos(2) + ti(2) + buf_(2);
        ax_width = outerpos(3) - ti(1) - ti(3) + buf_(3);
        ax_height = outerpos(4) - ti(2) - ti(4) + buf_(4);
    end %<getDims>

end %<eof>