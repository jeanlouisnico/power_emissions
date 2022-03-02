function [tind,range,values,freq,names,technames] = csvload(args)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% 
% Use: t = tsobj('../@tsobj/dbtemp.csv') -> '2006q1'/'2006m1'/'2006' date format
%      t = tsobj('../@tsobj/dbtemp.csv','yy.mm.dd') -> other formats
% 
% Input data format: 1st column reserved for 'date' clarification
%                    1st row reserved for 'technames' of the series (except for cell A1)
%                    2nd row reserved for 'names' of the series (except for cell B1)
%                    all expressions in 1st column are ignored (except for valid dates)

% keyboard;

%% Read data from file
cellfile = import_data(args.filename, ...
                       'delimiter',args.delimiter, ...
                       'maxrows',args.maxrows, ...
                       'addRows',args.addRows);

%% Data processing
[tind,range,values,freq,names,technames] = dynammo.tsobj.process_imported_data(cellfile,args.dateformat);

end %<eof>