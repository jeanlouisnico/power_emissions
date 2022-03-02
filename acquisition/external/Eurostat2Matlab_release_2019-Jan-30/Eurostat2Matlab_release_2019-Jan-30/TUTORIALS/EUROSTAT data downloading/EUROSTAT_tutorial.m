
%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

close all;
clear all;

% In this tutorial we download some GDP data 
% In particular we:
%   -> ...create a database object for EUROSTAT connection
%   -> ...pick a table that contains GDP data
%   -> ...apply filtering criteria to throw away some of the data dimensions 
%               (in the end we want a 1D time series, or 2D matrix of time series)
%   -> ...download the desired data
%   -> ...plot the result

%% Fetch EUROSTAT table of contents

toc = TOC(dbEUROSTAT(),'refresh',0);% When running this command for the first time,
                                    % a fresh version of table-of-contents (TOC) 
                                    % gets downloaded. Executing this command in 
                                    % future with 'refresh' set to 0 only loads 
                                    % previously downloaded TOC

%% Create a database object
d = dbEUROSTAT() %#ok<*NOPTS>

%% Data specification [1] - Reference to a table listed in table-of-contents

d.table = toc.data.economy.na10.namq_10.namq_10_ma.namq_10_gdp;

% -> NOTE: If you do not know the exact reference to table-of-contents (toc. ...), 
%          use 
%               picktable(d)
% 
%          command to search for data in entire EUROSTAT DB - picktable() command
%          opens up a user interface the structure of which mirrors 
%          the EUROSTAT web page. Search field can process regex commands, 
%          or google-like "..." exact phrases. When a table gets selected, 
%          its TOC reference is to be found in the command window for future use.
%          The result in the command window may look like this:
% 
%                  %%% >>> Table definition <<< %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Use table at basic prices
%                     toc.data.economy.na10.naio_10.naio_10_cp.naio_10_cp1610
%                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%          Once some table is clicked, d.table field in the Matlab workspace will 
%          get updated automatically.

%% Information about selected data

% [1] Table information based on the above table selection can be checked by 
%     displaying the table-of-contents results directly into the command window
d.table

% [2] Another possibility is to open up a new session of Internet Explorer
%     with the original information provided by EUROSTAT
% >> metadata(d)

%% Data specification [2] - Filtering criteria
% -> Main GDP aggregates table still contains a lot of data, which must be filtered out
%    prior to importing them into Matlab, most likely the data will be multidimensional 
%    (time vs. country vs. GDP component, etc.)

% Applying filtering criteria
filt = struct();
filt.unit = 'CLV_PCH_SM'; % Chain linked volumes, percentage change compared to same period in previous year
filt.s_adj = 'SCA'; % Seasonally and calendar adjusted data
filt.na_item = 'B1GQ'; % Gross domestic product at market prices
filt.geo = {'CZ';'DE'};

d.filter = filt;

% -> NOTE: If you do not know a priori what filtering criteria to use, you can try 
%          to build a time series object:
%                                                   t = tsobj(d);
% 
%          Another UI window will pop up informing us that we still need to specify 
%          some filtering criteria. To select data in a convenient way, feel free to 
%          use both mouse and keyboard short-cuts (e.g. CTRL+A). Multiple selections 
%          can be achieved by pressing CTRL/SHIFT while clicking, as is common on 
%          Windows machines. Note, however, that only one of the table dimensions may
%          contain multiple selection.

%% Time series object generation
% -> There is a separate tutorial for time series manipulation, and for visualizing data

% Time series object creation (data get downloaded in this step)
gdp_yoy = tsobj(d)

% Visualizing the result
plot(gdp_yoy,'type','line','caption','name','suptitle','GDP (YoY, %)');
% -> legend is clickable
% -> axes are zoomable
% -> extra buttons in the toolbar - always-on-top switch, 
%                                   .PDF printer,
%                                   .PPT exporter (on Windows machines only)

%% Export to XLS
% -> Note: For obvious reasons, XLS exporting is supported on Win machines only
if ispc
    export(gdp_yoy,'filename','some_gdp_data.xlsx');
    disp('.XLSX file with GDP data can be found in the current folder...');        
end


%<eof>