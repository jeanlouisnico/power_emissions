function suphan=suptitle(fignow,str,varargin)
% 
% Adds a super title above all subplots, handles re-positioning of all subplots
% 
% INPUT: fignow ...handle to an existing figure
%        str    ...super title text
%        [optional] ...scaling factor for the figure objects (by how much everything gets scaled down)
% 
% OUTPUT: suphan ...handle to the text object containing super title
% 
% See also: suptitle_fast()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Down scaling subplot objects

if nargin==3
    yscale = varargin{1};
else
    yscale = 0.93;%0.85;
end

try
    axobjs = findobj(fignow,'Type','axes');% M2014b+ does not have legend marked as 'axes', 
                                           %     this is problem if 'A4' set to 'dont'
catch
    error_msg('Super title','Figure handle cannot be found, did you delete it??'); 
end

for ii = 1:length(axobjs)
    % Legend sometimes disappears during this cycle :(, isn't it just hidden below the graph?
    %     -> in manual mode stays :(
    
    obj_as_struct = get(axobjs(ii));
    pos = obj_as_struct.Position;%get(axobjs(ii),'position');
    pos(2) = pos(2)*yscale;
    pos(4) = pos(4)*yscale;
    
    % We have to save the legend line handles, they disappear from cloned figures :(
    % Problem #2: figoverlay() - legend loses its handles when the below "set(axobjs(ii),'position',pos);" command is executed
    
    if isfield(obj_as_struct,'UserData') 
        % -> this should be a legend
        usrdata = obj_as_struct.UserData;
        usrdata.LegendPosition = pos;
        set(axobjs(ii),'position',pos);% -> this sometimes changes Userdata (handles disappear) -> cloning problem
        set(axobjs(ii),'userdata',usrdata);
    else
        set(axobjs(ii),'position',pos);
    end
end

%% Super title
suphan = dynammo.plot.addSuptitle(fignow,str,yscale);

end %<eof>