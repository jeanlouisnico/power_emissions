
%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

clear all;
close all;
clear classes;

%% Creating time series objects
% 'tsobj' is a general function for manipulating time series data. It can generate new time series
% objects, load data from a local text/csv/xls file, or even download data from an external source.

% This will create an empty time series object named "t"
t = tsobj() %#ok<*NOPTS>

% There is not much inside yet, but we can check its available properties
properties(t)
%   ...each time series object has following properties:
%           1] "values" - vector of data for each time period
%           2] "tind"   - vector of time periods as a fraction of given year
%                           (i.e. 2012.25 will correspond to the beginning of 2nd quarter 2012, 
%                                 of course yearly data have integer time indication)
%           3] "frequency" - this property can take up one of the following values:
%                               Y, Q, M, D for yearly, quarterly, monthly, or daily data
%           4] "range"  - vector of time periods written in a more human-friendly way (complement to "tind" property)
%                           (e.g. 2nd quarter 2012 will be abbreviated as 2012Q2)
%           5] "name"   - user-supplied name of the series (can contain special characters and spaces)
%           6] "techname" - name of the series used in Matlab referencing (must start with a letter, numbers allowed)

% Simple time series object creation
t = tsobj(2005:2012,[1;2;3;4;5;6;7;8])
% Object "t" is now specified from 2005 till 2012 
% To get what is inside the object, let's check the previously described properties
t.values % This gives us a vector of ones
t.tind   % Numeric time indication for each data point
t.range  % cell object of time span (for yearly data overlaps with "tind" content)
t.frequency % Yearly
t.name     % Empty
t.techname % Empty

%% Assignment of name/techname property

% [1] For an existing object we can use standard Matlab assignment to generate the "name" property
t.name = 'Some name'

% [2] While creating new object, the "name" property can be passed as 3rd argument
t = tsobj(2005:2012,[1;2;3;4;5;6;7;8],'Some name')

% "techname" property always has to be defined expost when the object has already been created
t.techname = 'name_with_no_spaces'

% Note: - Long technames are displayed in the command window in a compressed way 
%           ("name_w~" instead of "name_with_no_spaces")
%       - It is a good habit to define the techname property whenever new time series object has
%           been created since this property is inherited by many functions that manipulate
%           with time series objects

%% Collections of time series

% To define several time series at once, we can plug in a matrix of values:
t = tsobj('2005q1:2008q3',rand(15,3))

% This time "t" contains 2 columns of data for 15 quarters from 2005q1 till 2008q3
% The amounts of names and technames must correspond to the dimensions of the time series object
t.name = {'Name 1','Name 2','Name 3'}
t.techname = {'n1','n2','n3'}

% Standard Matlab assignment can be utilized when assigning only a subset of names/technames
t.techname{2} = 'something_else'

%% Frequency conversion

% Function 'convert' applied to the time series does the job
% To transform "t" into annual frequency:
convert(t,'freq','y')

% Besides "freq" option which specifies the desired frequency, there are other options 
% to be used while converting series into a different frequency, 
% such as "aggregation" type -> {'average','lastobs','lastavailable','sum'}
t = convert(t,'freq','y','aggregation','sum')
% ...this will take all quarters in a given year and sum them up to create the annual figure

%% Data assignment

% Put some numbers for the year 2012
t(2012) = [nan 3 nan]


%% Explosion/implosion of time series

% Function explode() is useful for splitting (exploding) a collection of time series objects 
% into a Matlab structure of individual time series, or further, to move all time series from
% a given Matlab structure directly to the workspace.
% Function implode() does the exact opposite (i.e workspace -> struct() -> tsobj() collection)


% Struct() of time series
tt = explode(t)

% Individual fieldnames are defined by "techname" property, auxiliary field name is generated
% whenever the techname is empty
t.techname{2} = '';
t = explode(t)

% To put both 'n1' and 'auxname_1' to workspace use explode() again
explode(t)

% Now the opposite - put all time series in the workspace into a container "u"
u = implode()

% To see the data next to each other in one object, 
% use implode() one more time on the previous result
uu = implode(u);

%% Range trimming

% We want only the data from 2005 till 2008
% -> Note that all-NaN rows get trimmed away from the result (year 2008)
trim(uu,2005:2008)

% Alternatively we can use {} indexing
uu{2005:2008}

%% Lead/lag operator

% {} brackets indicate a time shift. 

% Data lagged by 1 year
n1{-1}

% Data at t+2
n1{+2}

%% Concatenating time series

% As in standard Matlab syntax, [] brackets can horizontally concatenate 
% 2 or more time series objects

n = [n1 n1{-1}]

% Note that the name of lagged time series was automatically modified to keep track of what changes
% have been made to the object. This feature is sometimes unnecessary so we can always
% re-assign the correct name
n.name{2} = 'Name'


%% Extracting values from tsobj

% Entire matrix of values can be extracted using the "values" property of tsobj
n.values

% Should we need only data from a specific range, () indexation can be exploited
n(2007:2009)

%% Subsets of time series collections

% Subsets from both Matlab structures and tsobj() objects can be created using (*) operator
% The (*) operator uses the 'techname' property of the time series as a filtering criterion

% Only 'n1' field is retained:
u * 'n1' %...from struct()
uu* 'n1' %...from tsobj()

% If more fields are to be retained, cell object of field names is expected on input:
u * {'n1','n3'}
uu* {'n1','n3'}

% Fields with a name pattern can be retained using a "sublist" function
% ...all fields starting with 'n':
u * sublist(fieldnames(u),'n','<') % ...for struct()
uu* sublist(uu.techname,'n','<')   % ...for tsobj()

% ...all fields ending with '1':
u * sublist(fieldnames(u),'1','>')
uu* sublist(uu.techname,'1','>')

% ...all fields containing 'n':
u * sublist(fieldnames(u),'n','<>')
uu* sublist(uu.techname,'n','<>')

%% Loading time series data from an external CSV file

% Whenever the first argument of tsobj looks like a file name, the data gets imported
% In this case there is no need to specify the range since this information 
% should be contained in the file.
px = tsobj('px.csv','dateformat','dd.mm.yyyy','delimiter',',')
% "dateformat" option is important if daily data are imported
% "delimiter" can be any string character, if tabulator is used as delimiter, 
%               it should be indicated by '\t'

% Even though the data are daily, range trimming can be indicated by years
px = px{'2001:2010'};

%% Plotting the time series data

% Since the file 'px.csv' has already defined name/techname properties of all time series,
% plot() function can make use of it and generate automatically the legend/title entries 
plot(workingdays(px))

% To plot each series into an individual subplot, structure of time series 
% must be on input to the plot function, explode() operation can be utilised
db = explode(workingdays(px));
plot(db,'maxticks',4)

% !!! There is a separate tutorial regarding the data visualization !!!

%% Hodrick-Prescott filtering

db = explode(px);
db = convert(db,'freq','m','aggregation','lastavailable');
hppx     = hp(db.PXindex,'output','trend','lambda',14400);
hppx.name = 'HP trend';
hppx_gap = hp(db.PXindex,'output','prcgap','lambda',14400);
hppx_gap.name = 'HP gap in %';

res.left = [db.PXindex hppx];
res.right = hppx_gap;

plot(res,'caption','name','maxticks',5);

%% Seasonal adjustment
% -> External binaries for X-12, or X-13 methods are needed
% -> Availability of external binaries can be checked
%     by running dynammo_config(); 
if false
    x1 = x13(h.avpc_u);
   %x1 = x12(h.avpc_u); -> works as well for older X-12 method
    x2 = x13(h.avpc_u,'mode','mult');
    x3 = x13(h.avpc_u,'verbose',false);
    x4 = x13(h.avpc_u,'instructions','outlier{types=all;critical=3.75}','deleteResults',false);
end

%<eof>