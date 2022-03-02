function varargout = legend2(varargin)
%
% Wrapper function for standard legend() function to deal with empty
% UserData in M2014b+ (new graphics fix)
%
% INPUT: standard legend() input
%
% OUTPUT: standard legend() output, UserData contains some of the fields that used to be
%                                   generated prior to M2014b version
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

if dynammo.compatibility.oldGraphics
    
    % Standard call
    [LEGH,OBJH,OUTH,OUTM] = legend(varargin{:});

    % Output
    switch nargout
        case 1
            varargout{1} = LEGH;
        case 2
            varargout{1} = LEGH;
            varargout{2} = OBJH;
        case 3
            varargout{1} = LEGH;
            varargout{2} = OBJH;
            varargout{3} = OUTH;
        case 4
            varargout{1} = LEGH;
            varargout{2} = OBJH;
            varargout{3} = OUTH;
            varargout{4} = OUTM;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%
else % M2014b+ graphics
%%%%%%%%%%%%%%%%%%%%%%%
% keyboard;
    % Standard call
    LEGH = legend(varargin{:});
      
    % UserData is by default empty
    LEGH.UserData.handles = num2cell(double(LEGH.PlotChildren(:)));% !!!! This will not work for 'bar' graphs, both {han1half;han2half} needed
    LEGH.UserData.lstrings =  LEGH.String(:);%OUTM(:);
    %LEGH.UserData.LabelHandles = OBJH;
     LEGH.UserData.PlotHandle = get(LEGH.UserData.handles{1},'parent');% M2015b
    %LEGH.UserData.PlotHandle = get(LEGH.UserData.handles(1),'parent');% Note that this field is not linked as a listener when the value changes
                                                                      % -> gobj_generate() uses it, but it should work
    %lghandle.UserData.LegendPosition -> better to take it directly from legend handle (it is connected to listeners, when units/pos change)

    % Data envelope (convex hull)
    % -> here we use 'legacy' function, but it works well for M2014b+
    LEGH.UserData.convHull = dynammo.plot.convexHull_legacy2014b(LEGH.UserData.PlotHandle);
    
    if nargout==1
        varargout{1} = LEGH;
    elseif nargout>1
        error_msg('Legend creation','Legend cannot have more than 1 output argument in Matlab 2014b and newer...');
    end
    
end

end %<eof>