function hpstudio_callback(pb,ev)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Password
if ~strcmp(ev.Key,'return')
    return
end

% keyboard;

%% Access objects 
fig = evalin('base','hp__fig');

%% Which graph
userdt = get(pb,'UserData');

%% figure

fig = fig.fig1;
% f = fieldnames(fig);
% s = sublist(f,'sub','<');
s = {['sub' num2str(userdt.graphID)]};

%% 'Busy' status <red>
subs=cellfun(@(x) x.handle,struct2cell(fig*s),'UniformOutput',false);
subs{end+1}=fig.sub1.legend;
subs{end+1}=fig.subx.legend;
subs = cat(1,subs{:});
set(subs,'Color',[1 0.9 0.9]);

%%

drawnow; % all edit box values must be fresh

switch userdt.type
    case 'lambda'
        
        % Update trend/gap
        lambda = str2double(get(pb,'String'));
        if isnan(lambda)
            return
        end
        
        for ii = userdt.graphID % Only one graph :)

            origdata = get(fig.(['sub' sprintf('%.0f',ii)]).data{1},'YData');

            % Trend
            tmp = hp(tsobj({1:length(origdata)},origdata(:)),'lambda',lambda);
            set(fig.(['sub' sprintf('%.0f',ii)]).data{2},'YData',tmp.values.');
            
            % Current scaling factor
            curr_scale = str2double(get(userdt.uiscale,'String'));
            
            % Previous scaling factor
            userdt_scaling = get(userdt.uiscale,'UserData');
            
            % Gap
            tmp = hp(tsobj({1:length(origdata)},origdata(:)),'lambda',lambda,'output','prcgap');
            set(fig.subx.data{ii},'YData',curr_scale/userdt_scaling.basescale*tmp.values.');

        end
        
    case 'lead/lag'
        leadlag = str2double(get(pb,'String'));% lead (+)/lag (-)
        if isnan(leadlag)
            return
        end
        
        switch upper(userdt.freq)
            case 'D'
                step_ = 1/365;
            case 'M'
                step_ = 1/12;
            case 'Q'
                step_ = 1/4;
            case 'Y'
                step_ = 1;
        end
        set(fig.subx.data{userdt.graphID},'XData',get(fig.subx.data{userdt.graphID},'XData') +step_*(userdt.baseshift-leadlag) );
        
        % Update listener
        userdt.baseshift = leadlag;
        set(pb,'UserData',userdt);
        
    case 'scaling'
        scaling = str2double(get(pb,'String'));
        if isnan(scaling)
            return
        end     
        
        set(fig.subx.data{userdt.graphID},'YData',get(fig.subx.data{userdt.graphID},'YData')/userdt.basescale*scaling);
        
        % Update listener
        userdt.basescale = scaling;
        set(pb,'UserData',userdt);
        
    case 'reset'
        keyboard;
        
        
    case 'auto'
        
end

% drawnow;

%% 'Finished' status <white>
set(subs,'Color',[1 1 1]);

end %<eof>