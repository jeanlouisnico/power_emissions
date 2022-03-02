function Answer = outfilename(Title,task_str,default_str,suffix)
%
% UI prompt for a file name (used while generating PDF from a figure)
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input dialog
% Title = 'Figure export to PDF';

InputFig=dialog(                     ...
    'Visible'          ,'on'      , ...off
    'KeyPressFcn'      ,@doFigureKeyPress, ...
    'Name'             ,Title      , ...
    'Pointer'          ,'arrow'    , ...
    'Units'            ,'pixels'   , ...
    'UserData'         ,'Cancel'   , ...
    'position',[873.5000  745.2667  195.0000   83.6000], ...
    'Tag'              ,Title      , ...
    'HandleVisibility' ,'callback' , ...
    ...'Color'            ,FigColor   , ...
    'NextPlot'         ,'add'      , ...
    ...'WindowStyle'      ,WindowStyle, ...
    ...'DoubleBuffer'     ,'on'       , ...
    'Resize'           ,'off'       ...
    );

AOTfeature(InputFig);

AxesHandle=axes('Parent',InputFig,'Position',[0 0 1 1],'Visible','off');%'off'

Edinfo.Units= 'pixels';
Edinfo.FontSize= 8;
Edinfo.FontWeight= 'normal';
Edinfo.HorizontalAlignment= 'left';
Edinfo.HandleVisibility= 'callback';
Edinfo.Style= 'edit';
Edinfo.BackgroundColor= 'white';

TextInfo.Units = 'pixels';
TextInfo.FontSize = 8;
TextInfo.FontWeight = 'normal';
TextInfo.HorizontalAlignment = 'left';
TextInfo.HandleVisibility = 'callback';
TextInfo.VerticalAlignment = 'bottom';
TextInfo.Color = [0 0 0];
                  
%Input pole
EditHandle=uicontrol(InputFig,Edinfo, ...
                     'Max',1, ...
                     'Position',[5 36.6 165 23], ...
                     'String', default_str, ...
                     'Tag','Edit', ...
                     'Callback',@doEnter);
                 
% Popisek input pole
QuestHandle=text('Parent',AxesHandle,TextInfo, ...
                 'Position',[5 59.6], ...
                 'String',task_str, ...
                 'Tag','Quest'); %#ok<NASGU>

BtnInfo.Units= 'pixels';
BtnInfo.FontSize= 8;
BtnInfo.FontWeight= 'normal';
BtnInfo.HorizontalAlignment= 'center';
BtnInfo.HandleVisibility= 'callback';
BtnInfo.Style= 'pushbutton';
BtnInfo.BackgroundColor= [0.8314 0.8157 0.7843];

% OK nutton
OKHandle=uicontrol(InputFig, BtnInfo , ...
                   'Position',[59 5 53 26.6], ...
                   'KeyPressFcn',@doControlKeyPress, ...
                   'String','OK', ...
                   'Callback',@doCallback , ...
                   'Tag','OK', ...
                   'UserData','OK'); %#ok<NASGU>

CancelHandle=uicontrol(InputFig,BtnInfo, ...
                       'Position',[117 5 53 26.6], ...
                       'KeyPressFcn',@doControlKeyPress, ...
                       'String','Cancel', ...
                       'Callback',@doCallback, ...
                       'visible','on', ...
                       'Tag','Cancel', ...
                       'UserData','Cancel'); %#ok<NASGU>

set(InputFig,'Visible','on');

% Highlight the default input text
uicontrol(EditHandle);

uiwait(InputFig);

if ishandle(InputFig)
    if strcmp(get(InputFig,'UserData'),'OK'),
        Answer=[get(EditHandle,'String') suffix];
    end
    delete(InputFig);
else
    Answer='';
end

%% Support functions

function doFigureKeyPress(obj, evd) %#ok<INUSL>
    switch(evd.Key)
         case {'return'}%space
          set(gcbf,'UserData','OK');
          uiresume(gcbf);
         case {'escape'}
          delete(gcbf);
          close(InputFig);
    end
end

function doEnter(obj, evd)

    h = get(obj,'Parent');
    x = get(h,'CurrentCharacter');
    if unicode2native(x) == 13
        doCallback(obj,evd);
    end

end

function doControlKeyPress(obj, evd)
    switch(evd.Key)
     case 'return'
          if ~strcmp(get(obj,'UserData'),'Cancel')
              set(gcbf,'UserData','OK');
              uiresume(gcbf);
          else
              delete(gcbf)
          end
     case 'escape'
         delete(gcbf);
         close(InputFig);
    end

end

function doCallback(obj, evd) %#ok
    if ~strcmp(get(obj,'UserData'),'Cancel')
        set(gcbf,'UserData','OK');
        uiresume(gcbf);
    else
        delete(gcbf)
    end

end

end %<eof>