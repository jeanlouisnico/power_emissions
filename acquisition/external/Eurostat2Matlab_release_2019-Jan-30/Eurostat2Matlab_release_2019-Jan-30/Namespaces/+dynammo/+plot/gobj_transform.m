function out = gobj_transform(gobj)
%
% Transforms tsobj/tscoll output structure: 
% 
% gobj.fig
% gobj.sub
% gobj.data
% gobj.legend 
% gobj.diffs
% gobj.emphasized 
% gobj.highlighted
% gobj.title
% gobj.suptitle
% 
% into standard structure:
% 
% out.fig1.handle
% out.fig1.sub1.handle
% out.fig1.sub1.data
% out.fig1.sub1.legend
% out.fig1.sub1.diffs
% out.fig1.sub1.emphasized
% out.fig1.sub1.highlighted
% out.fig1.sub1.title
% out.fig1.suptitle
%
% INPUT: gobj ...structure generated by plot()
%
% OUTPUT: out ...transformed structure
%
% See also: dynammo.plot.gcf2obj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Mandatory fields
if isfield(gobj,'fig')
    out.fig1.handle = gobj.fig;
    out.fig1.sub1.handle = gobj.sub;
   % out.fig1.sub1.data = gobj.data; % tsobj() has data mandatory, but not needed for matlab plots
    
elseif isfield(gobj,'handle')
    out.fig1 = gobj;
    
elseif isfield(gobj,'fig1')
    % Already in correct format
    %           gobj.fig1.handle
    %             
    out = gobj;
    return

else
    error_msg('gobj transformation','Input structure unrecognized...');
    
end
    
%% Optional fields

if isfield(gobj,'data')
    out.fig1.sub1.data = gobj.data;
end
if isfield(gobj,'legend')
    out.fig1.sub1.legend = gobj.legend;
end
if isfield(gobj,'diffs')
    out.fig1.sub1.diffs = gobj.diffs;
end
if isfield(gobj,'emphasized')
    out.fig1.sub1.emphasized = gobj.emphasized;
end
if isfield(gobj,'highlighted')
    out.fig1.sub1.highlighted = gobj.highlighted;
end
if isfield(gobj,'title')
    out.fig1.sub1.title = gobj.title;
end
if isfield(gobj,'suptitle')
    out.fig1.suptitle = gobj.suptitle;
end

end %<eof>