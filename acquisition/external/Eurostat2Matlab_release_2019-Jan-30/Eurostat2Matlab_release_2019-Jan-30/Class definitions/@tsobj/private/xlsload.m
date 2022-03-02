function [tind,range,values,freq,names,technames] = xlsload(args)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Read data from file
cellfile = import_data(args.filename,'sheetname', args.sheetname);
                      %'range' -> we always take entire used range 
                  
%% Replace all NaNs with an empty string
% COM interface to Excel reads empty cells as NaN values
% This is needed to make cellfile compatible with CSV input design
nan_ind = cellfun(@(x) isa(x,'double') && isnan(x),cellfile);
for icol = 1:size(cellfile,2)
    if any(nan_ind(:,icol))
        one_col = cellfile(:,icol);
        one_col(nan_ind(:,icol)) = repmat_cellstr_empty(sum(nan_ind(:,icol)));
        cellfile(:,icol) = one_col;
    end
end
% keyboard;
%% Data processing
[tind,range,values,freq,names,technames] = dynammo.tsobj.process_imported_data(cellfile,args.dateformat);

end %<eof>