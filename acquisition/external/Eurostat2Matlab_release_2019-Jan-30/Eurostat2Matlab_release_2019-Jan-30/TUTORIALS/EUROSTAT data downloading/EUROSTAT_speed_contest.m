%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

close all;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% In this tutorial we compare the time needed to download data
%%% using different methods of data collection
%%% 
%%% Available methods:
%%%   -> BULK downloading (in conjunction with occasional SDMX queries)
%%%   -> JSON format
%%% 
%%% Each method of data collection has its pros and cons (as discussed below)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fetch EUROSTAT table of contents
toc = TOC(dbEUROSTAT(),'refresh',0);

%% Database object initialization

% Create DB object
d = dbEUROSTAT();

% Select table ('toc' reference derived from picktable(d) user interface)
d.table = toc.data.economy.prc.prc_hicp.prc_hicp_ct.prc_hicp_cann;

% Filtering criteria (to be captured from tsobj(d) user interface)
filt = struct();
filt.unit = 'RCH_A'; % Annual rate of change
filt.coicop = 'CP00'; % All-items HICP
filt.geo = {'CZ';'DK';'DE'};
d.filter = filt;

%% Downloading speed contest

% >>> BULK downloading
    % Set the downloading method
    d.engine = 'bulk/sdmx';

    % Reset the stop watch
    tic();

    % Download and post-process data
    bulk_result = tsobj(d);

    fprintf(2,'\n%s\n',' -> BULK downloading (single query) ');
    elapsed_time();
% <<<

% >>> JSON format
    % Set the downloading method
    d.engine = 'json';

    % Reset the stop watch
    tic();

    % Download and post-process data
    json_result = tsobj(d);
    
    fprintf(2,'\n%s\n',' -> JSON format (single query) ');
    elapsed_time();
% <<<

% Results discussion:
%   Simple queries are usually processed faster using the JSON format
%   since we use the EUROSTAT web service to deliver the result directly
%   in the form that we asked for. 
%   
%   Using the 'bulk' method, we first download entire 
%   table from which we extract the required time series ex post locally. 
%   The fix cost of downloading entire table slows down the downloading 
%   process.
% 
%   However, from time to time it can happen that the EUROSTAT web services
%   are temporarily unavailable. In such situations the 'bulk' downloads
%   may represent the only option left.

%% Bulk downloads - repeated queries within a single table

% >>> standard BULK downloading calls
    % Set the downloading method
    d.engine = 'bulk/sdmx';

    % Reset the stop watch
    tic();
    
    % Query #1 - food prices
    filt.coicop = 'CP011'; % Food (UI for filter selection criteria can be opened by tsobj(d) with an empty d.filter='')
    bulk_result1 = tsobj(d);

    % Query #2 - Fruit prices
    filt.coicop = 'CP0116'; % Fruit
    bulk_result2 = tsobj(d);

    % Query #3 - Electricity prices
    filt.coicop = 'CP0451'; % Electricity
    bulk_result3 = tsobj(d);
    
    % Query #4 - Clothing prices
    filt.coicop = 'CP031'; % Clothing
    bulk_result4 = tsobj(d);
    
    fprintf(2,'\n%s\n',' -> Wrong way of using BULK downloads');
    elapsed_time();
% <<<

% >>> optimized BULK downloading calls
    % Set the downloading method
    d.engine = 'bulk/sdmx';

    % Reset the stop watch
    tic();
    
    % >>> !!! IMPORTANT to re-use the downloaded table multiple times <<<
    d.deleteSourceFiles = 0;
    
    % Query #1 - food prices
    filt.coicop = 'CP011'; % Food (UI for filter selection criteria can be opened by tsobj(d) with an empty d.filter='')
    bulk_result1 = tsobj(d);

    % Query #2 - Fruit prices
    filt.coicop = 'CP0116'; % Fruit
    bulk_result2 = tsobj(d);

    % Query #3 - Electricity prices
    filt.coicop = 'CP0451'; % Electricity
    bulk_result3 = tsobj(d);
    
    % >>> !!! IMPORTANT to delete the temporary files in the final call to tsobj() <<<
    d.deleteSourceFiles = 1;
    
    % Query #4 - Clothing prices
    filt.coicop = 'CP031'; % Clothing
    bulk_result4 = tsobj(d);
    
    fprintf(2,'\n%s\n',' -> Better way of using BULK downloads');
    elapsed_time();
% <<<

% Results discussion:
% -> 'bulk' downloading can be speeded up whenever the user needs to extract
%    various dimensions within a single table. In such situations the table
%    can be downloaded only once and processed multiple times.
% -> As a result, the fix cost of downloading the entire table becomes less 
%    relevant.

%<eof>