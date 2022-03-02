function lgndItemClick(lg,ev)
%
% Visibility toggle for plotted objects based on legend clicks
% 
% COMPATIBILITY: This fcn works only in Matlab 2014b and newer
%                (legendClick() fcn works in M2014a-)
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

peers = double(ev.Peer);

%% Right click

if strcmpi(ev.SelectionType,'extend') % SHIFT + click

    % Select/de-select all items at once    
    peers = lg.UserData.handles;
    %keyboard;
    
% elseif strcmpi(ev.SelectionType,'open') % double click - works, but 2 consecutive single clicks may be recognized inadvertently as double click
%     defaultItemHitCallback(lg,ev);
%     return
end

%% Crossroads

if isfield(get(ev.Peer),'FaceColor') % -> bar graph
    
    % Deal with all peers
    if length(peers)==1
        % Find current peer and its complement in the negative half plane
        peers = [peers;double(lg.UserData.handles{2}(double(lg.UserData.handles{1})==double(ev.Peer)))];
    else
        % Simply take all peers from legend and their complements
        peers = double(cat(1,lg.UserData.handles{:}));
    end
    
    passColor = 'FaceColor'; 
    
else % -> line graph
    passColor = 'Color';
    
end

%% Body
    
% Decide on the direction
cond = isempty(get(peers(1),'UserData')); % It is on, turn it off

% Do the action for one/all legend items according to the click type
% Swap happens here
if cond % -> Hide it

    for ii = 1:length(peers)
        if isempty(get(peers(ii),'UserData'))
            set(peers(ii),'UserData',get(peers(ii),passColor));
            set(peers(ii),passColor,[0.85 0.85 0.85]);
        end
    end

else % -> Make it visible

    for ii = 1:length(peers)
        if ~isempty(get(peers(ii),'UserData'))
            set(peers(ii),passColor,get(peers(ii),'UserData'));
            set(peers(ii),'UserData',[]);
        end
    end

end

end %<eof>