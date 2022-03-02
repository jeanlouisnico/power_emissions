function st = mystyle(type)
%
% Here you can predefine the design of your graphs and overrule the default setup.
% This function is to be modified by the user. However, it is not meant to 
% be called directly by the user. 
% 
% INPUT: type ...style # to be applied to current graph
%  
% OUTPUT: st ...structure of design parameters for the plotter (line color, marker, etc.)
%
% ##############################################################
% Alternatively, create style from scratch using appropriate Matlab properties 
% (on top of the default style properties) <beware: the number of elements 
% inside the styling structure must match the number of plotted objects>
% 
% st = struct();
% st.Color = [1 0 0; % These are RGB triplets
%             0 0 1;
%             0 1 0;
%             1 0 1];
% st.Marker = 'o';% -> one value used for all objects
% st.MarkerFaceColor = {[0 1 1],'none','none','none'};% -> different value for different object
% st.LineWidth = [1,2,3,4];
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body 

st = struct();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Style definitions (this section can be modified freely by the user) <# fields are case sensitive#>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch lower(type)
    case 1 % Pre-specified style #1
        % Line properties
        st.Color =  [241 104 37;       % Brown/orange
                     11  53  144;      % Dark blue
                     255 201 5;        % Yellow  
                     102 209 22]./255; % Green   
        st.LineWidth = 2;%
        st.Marker = 'none';

   case 'sparta'
       % Bar plot
       st.FaceColor =  [166 168 171;        % Grey 
                        221 30  57;         % Red      
                        251 174 24;         % Yellow
                        73  130 194]./255;  % Blue     
                    
   case 3
        %Type your personal plotting style here :)

    otherwise
        error_msg('Plot formatting','Unknown style type selection...');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Favorite colors <colormap.bmp, https://colorbrewer2.org/> 
% colors = cell(5,1);
% 
% % Dull
% colors{1} = [73  130 194;      % Blue    (1,1)
%              221 30  57;       % Red     (1,2)
%              251 174 24;       % Yellow  (1,3)
%              63  131 60;       % Green   (1,4) 
%              166 168 171]./255;% Grey    (1,5)
%              
% % Bright
% colors{2} = [0   112 192;      % Blue    (2,1)
%              255 0   0;        % Red     (2,2)
%              255 201 5;        % Yellow  (2,3)
%              102 209 22]./255; % Green   (2,4)
% 
% colors{3} = [217 119 0;           % Dark yellow (3,1)
%              0   148 185;         % Azuro blue  (3,2)
%              167 188 129]./255;   % Light green/grey  (3,3)
%              
% colors{4} = [241 104 37;       % Brown/orange (4,1)
%              11  53  144]./255;% Dark blue    (4,2)
% 
% colors{5} = [184 100 0;           % Brown 1 (5,1)
%              219 168 74;          % Brown 2 (5,2)
%              240 217 157]./255;   % Brown 3 (5,3)
% Yellow marker [226 250 97]./255

%% RGB finder
% RGBstudio()
% RGBstudio(rand(100,3))

end %<eof>