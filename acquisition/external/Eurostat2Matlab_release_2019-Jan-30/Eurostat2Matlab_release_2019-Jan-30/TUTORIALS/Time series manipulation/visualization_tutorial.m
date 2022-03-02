
%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

clear all;
close all;

% 
% In this tutorial we show most of the visualization capabilities of plotting time series data
% Line by line execution of the code is strongly suggested rather than F5ing entire code at once
% 

%% General rules
%
% Time series objects from tsobj() class can be simply plotted by plot() function.
% Should tsobj() contain multiple series, all will be overlaid in one plot together.
% 
% Legend is generated automatically using the input data (name/techname properties 
%   of time series objects).
% 
% To plot different time series separately, the tsobj() objects must be collected 
% in a struct object.
% Struct object of time series may contain both single time series
%   and time series collections - these may even contain data of various 
%   frequencies (daily, monthly, quarterly, or yearly).
% - Plots have tsobj name in place of captions
% - Multiline plots have automatically generated legend instead (no title)
% 
% Comparison of two or more databases can be done using the '+' (plus) operator
%  - e.g. plot(db1 + db2) will plot corresponding time series from both databases 
%           into one subplot.
%  - names of the corresponding time series should be aligned, this can be quickly 
%           achieved using the dictionary() function (see the example below).
% 
% the result of a plot() function is a collection of function handles to all plotted
% objects, i.e. figures, subplots, data lines, and legends. 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HINT: Each figure has extra elements in its icon bar - the one that looks 
%       like eye activates always-on-top feature so that the figure does not 
%       disappear when the user wants to execute piece of code from the editor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Data preparation

% Single time series objects
rng(1234);
d1 = tsobj('2001-01-01:2006-12-31',randn(2191,1),'daily data'); %#ok<*NOPTS>
d1.techname = 'daily'

rng(4321);
d2 = tsobj('2001-01-01:2006-12-31',randn(2191,1),'daily data 2');
d2.techname = 'daily2'

% Change data frequency from daily to monthly, quarterly and yearly
m1 = convert(d1,'freq','m')
m2 = convert(d2,'freq','m')

q1 = convert(m1,'freq','q')
q2 = convert(m2,'freq','q')

y1 = convert(q1,'freq','y')
y2 = convert(q2,'freq','y')

% For future reference set the names of the series 
% (any kind of string)
m1.name = 'monthly data'
q1.name = 'quarterly data'
y1.name = 'yearly data'
m2.name = 'monthly data 2'
q2.name = 'quarterly data 2'
y2.name = 'yearly data 2'

% Plot legends are generated by default using the techname property of a time series
% (string, but must be a valid variable name, i.e. no spaces, no special characters)
m1.techname = 'monthly'
q1.techname = 'quarterly'
y1.techname = 'yearly'
m2.techname = 'monthly2'
q2.techname = 'quarterly2'
y2.techname = 'yearly2'

% Time series collections (more than one time series present)
dcoll = [d1 d2]
mcoll = [m1 m2]
qcoll = [q1{-1} q2{-3}] % Lag operator used
ycoll = [y1 y2]

% Struct database
db = implode() % All time series objects in workspace to be taken into one struct()

% Struct DB with a collection of mixed frequencies data
db_mixed = db
db_mixed.mixed = [d1 q1]

% Generate 2 DBs having the same structure
db1 = db;
db1 = db1 * {'m1','q1','d1','y1'} % Chosen fields
db2 = db;
db2 = db2 * {'m2','q2','d2','y2'} % Chosen fields
db2 = dictionary(db2,{'m2','m1'; ...% -> 'm2' to be renamed as 'm1'
                      'q2','q1'; ...
                      'y2','y1'; ...
                      'd2','d1'}); % In DB comparison, all names must be aligned 
                                   % (this function matches the corresponding names)
                  
% db1 can contain an extra time series (not contained in db2)
db1.extra = tsobj(2005:2007,[5 6 4]','extra field');


%% Figure handles

% All available figure settings are stored in form of handles.
% Call to plot() function always generates 'gobj' in the workspace,
% equivalently, p = plot() will generate 'p' with the same properties.
% Manipulating figures ex post is very easy due to an easy access to 
% all available object handles.

close all;

% 'gobj' object of handles generated in the workspace
plot(m2)
display(gobj);

% Let's say we do not like the legend box
% 'get(gobj.legend)' will guide us how to achieve this...
set(gobj.legend,'box','off');

% Store the figure handles into a specified container called 'p'
p = plot(m2);
display(p);

% e.g. change the font color of X axis
% Again, use get(p.sub) to see the list of available options
set(p.sub,'Xcolor',[0.1 0.8 0.5]);

%% Range cut-offs
close all;

% Plot the data in a specified range.
% Yearly specification is allowed even if the data frequency is different
plot(q1,'range','2004:2007');
plot(q1,'range', 2004:2007);      % the same result
plot(q1,'range','2004q1:2007q4'); % the same result

% Timing convention:
% - yearly data    -> e.g. 2004 (can be numeric/string)
% - quarterly data -> e.g. 2004q3
% - monthly data   -> e.g. 2004m12
% - daily data     -> e.g. 2004-05-31

% Simplified timing notation
% - quarterly data -> e.g. 2004 is equivalent to 2004q1
% - monthly data   -> e.g. 2004 equiv. to 2004m1
% - daily data     -> e.g. 2004, or 2004-01 equiv. to 2004-01-01

%% Legend + Caption
% Legend entries are generated automatically if more than 1 line is present in the graph.
% Special user-defined legend can be passed to plotter via 'legend' option,
% which expects a cell object of strings on input.
% Legend option is ignored when plotting more figures at once.

close all;

% Automatic legend using 'techname' property of the time series
plot([q1 q2]);

% Automatic legend using 'name' property of the time series
plot([q1 q2],'caption','name');

% User-defined legend
plot([q1 q2],'legend',{'data1','data2'});

% Legend for mixed frequencies better via techname/name properties
q1.name = 'data Quarterly'
m1.name = 'data Monthly'
plot([q1 m1],'caption','name')

% Caption
% 'caption' option can be set to 'name', or 'techname' values only.
% The default value for 'caption' is 'techname' meaning that variable
% names will be used in place of legend text fields, or as a figure titles.
% Technames do not contain spaces. Setting 'caption' to 'name' will trigger
% use of time series commented names (possibly including spaces).

% - name contents of the tsobj() used 
    plot(q1,'caption','name');
    disp(q1.name)
% - techname contents of the tsobj() used <by default>
    plot(q1);
    disp(q1.techname);

%% Title
    
% A title can be passed to simple plots only. Multiplots ignore
% this option. In case the title is desirable for any reason, it
% can be added to the generated graphs ex post <see the example below>.

close all;

% User-defined title
plot(q1,'title','This is my title');

% This will NOT work (multiplot on input) - titles are generated automatically
plot(db1,'title','This is my title');

% Add title to the very last subplot
% (by navigating to its handle)
title(gobj.fig1.sub5.handle,'This should work :)');

%% Horizontal/vertical margins
% -> Space padding around plotted objects
% 50% of the data range in the top part of the figure is left blank,
%   for instance, this can be used in case the legend does not fit in the figure
plot(q1,'margin_top',0.5,'title','Top margin 50% of data range');
% 150% of the data range to be left blank in the bottom part
plot(q1,'margin_bottom',1.5,'title','Bottom margin 150% of data range');
% 40% of the time span to be left blank before the data sample starts/after the data sample ends
plot(q1,'margin_inset',0.4,'title','Inset margin 40% of time span on each end');

%% Highlighting, docking, maxticks
close all;

% Background highlighting at specific periods of time
% Shaded rectangular area is put under the data being plotted
plot(q1,'highlight','2005q3');
plot(q1,'highlight',{'2005q3','2004q1:2004q2'});

% Docking/undocking the generated figure
% - as a new window
    plot(q1);
% - as a window somewhere inside the Matlab window
%   (this option is ignored if the visibility of the figure is switched off)
    plot(q1,'docked',1);
    
% Number of labels on horizontal axis
%  - by default 12 labels are chosen in equidistant intervals (6 for daily data)
     plot(q1);
%  - 3 labels max
     plot(q1,'maxticks',3);
     

%% Subplots, emphasizing
close all;

% Subplotting
% - Entire struct object will be plotted in a single giant figure
    plot(db2);
% - Plot each time series object in a separate figure
    plot(db2,'subplot',[1 1]);
% - Time series objects are to be plotted in subplots of size 1 by 4
    plot(db2,'subplot',[1 4]);
    
% Line highlighting
% - Width equals 'linewidth' + 3
     plot(q1,'emphasize',3); 
% - Width equals 'linewidth' + 10     
     plot(q1,'emphasize',10);
% Only first line to be highlighted
     plot([q1 y2],'emphasize',10)
     set(gobj.fig1.sub1.emphasized{2},'visible','off');% -> ex post modification

%% User-defined graph styling
% -> All object properties can be set up prior to generating the graphs, or ex post
%    (we have already shown how to manipulate graphs ex post 
%     using the 'gobj' structure of Matlab handles to all plotted objects)

% Option 0: Default styling
plot(implode(db2),'range',2001:2002);

% Option 1: User-defined style taken from 'mystyle()' code, 
%           which is intended to be freely modified by the user
plot(implode(db2),'style',1,'range',2001:2002);

% Option 2: Create style from scratch using appropriate Matlab properties (on top of the default style properties)
%           <beware: the number of elements inside the styling structure must match the number of plotted objects>
st = struct();
st.Color = [1 0 0; % These are RGB triplets
            0 0 1;
            0 1 0;
            1 0 1];
st.Marker = 'o';% -> one value used for all objects
st.MarkerFaceColor = {[0 1 1],'none','none','none'};% -> different value for different object
st.LineWidth = [1,2,3,4];

plot(implode(db2),'style',st,'range',2001:2002);

% !!! Note that the styling properties are case sensitive !!!

%% Transparency
% -> controlled by the alpha channel
% -> alpha value is by default set to 0.9
close all;

% Plotted lines fully opaque
plot(implode(db2),'alpha',1);

% Plotted lines rather transparent
plot(implode(db2),'alpha',1);


%% Single quick plots

close all;

% Quarterly time series object
plot(q1);

% Collection of 2 monthly time series overlaid in one plot
plot(mcoll);

% Collection of data with mixed frequencies - yearly and daily
plot([y1 d1]);

% Again, mixed frequencies figure - this time taken from a struct object
plot(db_mixed.mixed);

% All quarterly data from db overlaid in one plot
plot(implode(db,'q'));

    % Don't like the legend? Change it using available function handles
    % -> here we follow Matlab internal syntax
    handles = gobj;
    legend_entries = get(handles.legend,'string');
    legend_entries{3} = 'name of 3rd line';
    legend_entries{4} = 'name of 4th line';
    set(handles.legend,'string',legend_entries);% M2014b+ does not expand the legend
                                                % box sufficiently, must be done manually :(     

%% Plot entire database
close all;

% 'db' is a struct object of:
%  - time series objects (1 per subplot)
%  - time series collections (1 per subplot => possibly more lines in one plot)
plot(db,'maxticks',2);

%% Compare multiple databases
close all;

% - DB comparison can be achieved via '+' operator
% - Note that the extra field in db2 is missing 
%   (1 line plotted only in the corresponding graph)
% - legend option is desirable, names of the databases are never stored
plot(db1 + db2,'legend',{'model1','model2'});

% - In case one compares 2 databases, it might be useful to show 
%    the differences between 2 corresponding series (as bars)
plot(db1 + db2,'legend',{'model1','model2'},'diffs',1);
plot(db1 + db2,'legend',{'model1','model2'},'diffs',2);% Difference bars reversed
plot(db1 + db2,'legend',{'model1','model2'},'diffs',1,'suptitle',sprintf('%s\n%s','Super title - line #1','Super title - line #2'));

%% Combining existing figures

g5 = plot(tsobj(1:10,[-1.8418;
   +1.549;
   -1.2964;
   -0.4358;
   -0.4264;
   -0.2947;
    1.5255;
   -0.3464;
   -0.7129;
   -0.7984]),'type','bar','highlight',5,'legend','oandf','title','asdffdsa');

g6 = plot([tsobj(1:10,randn(10,1)) tsobj(1:10,randn(10,1))], ...
            'emphasize',5,'diffs',1,'suptitle','Super gigle', ...
            'legend',{'rada 1','rada 2'}, ...
            'margin_top',0.1,'margin_top',0.1);
g7 = plot(db2.m1,'suptitle','PLOT object, no headers');

% 2x2 matrix of subplots, lower line merged
figs = {g5,g6;g7,g7};
gall1 = figcombine(figs,'suptitle','new suptitle');


g1 = plot([tsobj(1:10,randn(10,1)) tsobj(1:10,randn(10,1))], ...
            'emphasize',5,'diffs',1,'suptitle','Super gigle', ...
            'legend',{'rada 1','rada 2'}, ...
            'margin_top',0.1,'margin_top',0.1);
g2 = plot(db2.m1,'suptitle','PLOT object, no headers');

% 2x3 layout, rightmost column merged
% -> note that g1 occupies only the top half in the left, 
%    while g2 spans through the entire height of the resulting figure
figs = {g1,'',g2;
        '','',g2};
gall2 = figcombine(figs,'suptitle','new suptitle');

% Combining figures leaving the original figures unaffected (this time we create clones)
close all;

f1 = plot(tsobj('2000q1:2004q4',1),'legend','Quarterly series');
f2 = plot(tsobj('2000q1:2004q4',rand(20,1)),'title','Some title');

% Figure layout
figs = {f1,f2};
    
combfig = figcombine(figs,'suptitle','Combined figures','clone',1);

%% Overlaying figures

close all;

% Figure #1 - quarterly data
% -> This figure is generated only because of its background that we will use later,
%    rest of the figure contents is deleted/made invisible
f1 = plot(tsobj('2005q1:2007q4',rand(12,1)),'highlight',{'2005q2:2005q3',{'2006q1'}});
delete(f1.legend);
f1 = rmfield(f1,'legend');
set(f1.data{1},'visible','off');

% Figure #2 is made up of 2 overlaid figures (yearly and quarterly data)
f2 = plot(tsobj(2001:2010,5*rand(10,1),'Some name'));
f3 = plot(tsobj('2005q1:2007q4',5*rand(12,1),'Some name #2'),'emphasize',5);
ff_part = figoverlay(f3,f2,'clone',1,'yright',1);

% Finally, we overlay the previous result with the background taken from figure #1
ff_final = figoverlay(ff_part,f1,'clone',0,'scaling','linmap');


%% Ex post figure manipulation

% Prepare the previously generated figure for printing on A4
% -> Note: this could have been imposed already by plot(...,'A4','portrait/landscape');
fig2print(ff_final,'portrait');
fig2print(ff_final,'landscape');

% Change dimensions manually (this is standard Matlab syntax)
set(ff_final.fig1.handle,'position',[5 5 21 11]);% The units are now in centimeters

%<eof>