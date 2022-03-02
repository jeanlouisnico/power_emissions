function hpstudio(this)
%
% Real time calibration of 'lambda' parameter for HP filter
%
% INPUT: this ...tsobj()
%
% OUTPUT: none
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Determine subplot layout

nobj = length(this.techname);
dsgn = [1 1];
increment_last = 1;
while true
    if dsgn(1)*dsgn(2) >= nobj
        break
    else
       if increment_last
           dsgn(2) = inc(dsgn(2));
           increment_last = 0;
       else
           dsgn(1) = inc(dsgn(1));
           increment_last = 1;
       end
    end
end
    
% Add final row for gaps comparison
dsgn(1) = inc(dsgn(1));

%% HP filtering + plot step

deflambda = 1000;

if nobj==1
    hpdata = hp(this,'lambda',deflambda);
    gobj = rplot(explode(this)+explode(hpdata),'legend',{'Data','Trend'},'subplot',dsgn,'A4','dont','caption','techname');
    gapdata = hp(this,'lambda',deflambda,'output','prcgap');
else
    hpdata = hp(this,'lambda',deflambda);
    gobj = rplot(explode(this)+explode(hpdata),'legend',{'Data','Trend'},'subplot',dsgn,'A4','dont','caption','techname');
    gapdata = hp(this,'lambda',deflambda,'output','prcgap');
end

set(gobj.fig1.handle,'Units','normalized','Name','HP Studio');

%% Gaps comparison
% keyboard;

% Line colors
args.type = 'line';
args.alpha = 0.7;
tmp = dynammo.plot.defStyle(nobj,args);
cols =tmp.Color;

subs = sublist(fieldnames(gobj.fig1),'sub','<');
gobj.fig1.subx.handle = subplot(dsgn(1),dsgn(2),prod(dsgn)-dsgn(2)+1:prod(dsgn));
hold on;
gobj.fig1.subx.data = cell(nobj,1);
for ii = 1:nobj
    gobj.fig1.subx.data{ii} = plot(gapdata.tind,gapdata.values(:,ii),'color',cols(ii,:),'linewidth',2);
end
hold off;
grid on;
box on;
ylabel('%');
if nobj==1
    title(gobj.fig1.subx.handle,'Gap');
else
    title(gobj.fig1.subx.handle,'Gaps comparison');    
end

% Legend
gobj.fig1.subx.legend = legend(cat(1,gobj.fig1.subx.data{:}),strrep(this.techname,'_','\_'));
set(gobj.fig1.subx.legend,'Location','EastOutside');

%% Clickable legend
if dynammo.compatibility.newGraphics
    %error_msg('HP studio','Matlab 2014b and newer is needed for this function to run...');
    set(gobj.fig1.subx.legend,'ItemHitFcn',@lgndItemClick);
end

%% Edit fields

% keyboard;

% Dimensions
w_ = 0.04;
h_ = 0.03;
offset_ = 0.002;
scale_ = 3/2;

for ii = 1:nobj
    pos_ = get(gobj.fig1.(['sub' num2str(ii)]).handle,'Position');
    %units = get(gobj.fig1.(['sub' num2str(ii)]).handle,'Units');
    
    % >>> Scaling field <<< [3] -> moved here, need scaling for lambda handle
    uiscale = uicontrol('Style','edit', ...
              'String',num2str(1), ...
              'Units', 'normalized', ...
              'Position', [pos_(1)+pos_(3) pos_(2)+4*h_ w_ h_], ...
              'KeyPressFcn',@hpstudio_callback);
          
    userdt = struct();
    userdt.graphID = ii;
    userdt.type = 'scaling';
    userdt.basescale = 1;% *1 by default
    set(uiscale,'UserData',userdt);
    
    t = uicontrol('Style','Text');
%     set(ui,'Units','pixels');
%     pos2 = get(ui,'Position');
%     set(ui,'Units','normalized');
    set(t,'String','Scaling','Units','normalized');%,'Parent',gobj.fig1.(['sub' num2str(ii)]).handle);%,'FontSize',fontsize);
    set(t,'Position',[pos_(1)+pos_(3)+offset_ pos_(2)+5*h_ w_ h_/scale_]);
    set(t,'Units','normalized');% We want to move the text field when resizing
    
    % >>> Lambda field <<< [1]
    uilam = uicontrol('Style','edit', ...
              'String',num2str(deflambda), ...
              'Units', 'normalized', ...
              'Position', [pos_(1)+pos_(3) pos_(2) w_ h_], ...
              'KeyPressFcn',@hpstudio_callback);
          
    userdt = struct();
    userdt.graphID = ii;
    userdt.type = 'lambda';
    userdt.uiscale = uiscale;
    set(uilam,'UserData',userdt);
    
    t = uicontrol('Style','Text');
%     set(ui,'Units','pixels');
%     pos2 = get(ui,'Position');
%     set(ui,'Units','normalized');
    set(t,'String','l','Units','normalized','FontName','symbol');%,'Parent',gobj.fig1.(['sub' num2str(ii)]).handle);%,'FontSize',fontsize);
    set(t,'Position',[pos_(1)+pos_(3)+offset_ pos_(2)+h_ w_ h_/scale_]);
    set(t,'Units','normalized');% We want to move the text field when resizing
    
    % >>> Lead/lag field <<< [2]
    uilag = uicontrol('Style','edit', ...
              'String',num2str(0), ...
              'Units', 'normalized', ...
              'Position', [pos_(1)+pos_(3) pos_(2)+2*h_ w_ h_], ...
              'KeyPressFcn',@hpstudio_callback);
          
    userdt = struct();
    userdt.graphID = ii;
    userdt.type = 'lead/lag';
    userdt.freq = this.frequency;
    userdt.baseshift = 0;
    set(uilag,'UserData',userdt);
    
    t = uicontrol('Style','Text');
%     set(ui,'Units','pixels');
%     pos2 = get(ui,'Position');
%     set(ui,'Units','normalized');
    set(t,'String','Lag (-)','Units','normalized');%,'Parent',gobj.fig1.(['sub' num2str(ii)]).handle);%,'FontSize',fontsize);
    set(t,'Position',[pos_(1)+pos_(3)+offset_ pos_(2)+3*h_ w_ h_/scale_]);
    set(t,'Units','normalized');% We want to move the text field when resizing
    
end

%% Static fields

% Keep track of edit fields and their values
% usrdta = struct();
% usrdta.lambdas = lambdas;
% usrdta.scaling = scaling;
% usrdta.leadlag = leadlag;
% 
% usrdta.type = 'reset';
% resbut = uicontrol('Style','pushbutton','Parent',gobj.fig1.handle, ...
%                    'Units','normalized','Position',[0 0.95 0.05 0.04], ...
%                    'Callback',@(varargin) hpstudio_pushbuttons(gobj,usrdta));%, ...
%                    %'UserData',usrdta);
% set(resbut,'String','Reset');

% usrdta.type = 'auto';
% autobut = uicontrol('Style','pushbutton','Parent',gobj.fig1.handle, ...
%                    'Units','normalized','Position',[0 0.90 0.05 0.04], ...
%                    'Callback',@(varargin) hpstudio_pushbuttons(gobj,usrdta));%, ...
%                    %'UserData',usrdta);
% set(autobut,'String','Auto');

% keyboard;

%% Save figure handles in base workspace
assignin('base','hp__fig',gobj);

%% Show GUI
set(gobj.fig1.handle,'MenuBar','figure','ToolBar','figure');
pushbuttons(gobj.fig1.handle);
set(gobj.fig1.handle,'Visible','on');

end %<eof>