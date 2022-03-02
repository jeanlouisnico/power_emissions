function [filtglue,multipleSelection,multiwhere] = filter_resolution(dbobj)
%
% Filtering criteria transformed into a single string
%
% INPUT: dbobj ...EUROSTAT db object with non-empty 'filter'
%
% OUTPUT: filtglue ...filtering string in regexp() format
%         multipleSelection ... 0/1 indication of presence of 2 or more series
%         multiwhere ...# of criterion with a multiple selection
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Pre-allocation

multipleSelection = 0;
multiwhere = 0;

%% Body

filt = dbobj.filter;
f = fieldnames(filt);
filtglue = '';
for ifield = 1:length(f)
    fnow = filt.(f{ifield});
    if ischar(fnow)
        if strcmp(fnow,':')
            % 
            filtglue = [filtglue '.+?' ','];%#ok<AGROW> % Take everything regex part
            multipleSelection = 1;
            multiwhere = ifield;
        else
            filtglue = [filtglue fnow ',']; %#ok<AGROW>
        end
    else % Multiple selection as cell()

        multipleSelection = 1;
        multiwhere = ifield;

        cellglue = '(';
        for ic = 1:length(fnow)
            cellglue = [cellglue fnow{ic} '|']; %#ok<AGROW>
        end
        cellglue(end) = ')';
        filtglue = [filtglue cellglue ',']; %#ok<AGROW>

    end
end
filtglue = filtglue(1:end-1);


end %<eof>