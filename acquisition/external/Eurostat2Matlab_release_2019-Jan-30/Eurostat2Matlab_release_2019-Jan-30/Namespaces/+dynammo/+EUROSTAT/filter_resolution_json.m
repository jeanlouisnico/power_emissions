function [filtGlues,technames] = filter_resolution_json(dbobj)
%
% Filtering criteria transformed into single strings
%
% INPUT: dbobj ...EUROSTAT db object with non-empty 'filter'
%
% OUTPUT: filtGlues ...filtering strings for JSON queries
%         technames ...list of technical names for tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

f = fieldnames(dbobj.filter);

% Multiple user selection indication
mult_cand = structfun(@iscell,dbobj.filter);

% Filter string generation
filtGlue = '';
for iif = 1:length(f)
    if mult_cand(iif) % Multiple selection
       filtGlue = cat(2,filtGlue,'#multi#&');
    else
       filtGlue = cat(2,filtGlue,f{iif},'=');
       filtGlue = cat(2,filtGlue,dbobj.filter.(f{iif}),'&');
    end
end

% Cell of filtGlues on output
if any(mult_cand)
    multi_sel_var = f{mult_cand};
    multi_sel_entries = dbobj.filter.(multi_sel_var);
    nmulti =length(multi_sel_entries);
    filtGlues = cell(nmulti,1);
    for im = 1:nmulti
        filtGlues{im,1} = strrep(filtGlue(1:end-1),'#multi#',[multi_sel_var '=' multi_sel_entries{im}]);
    end
    technames = dbobj.filter.(f{mult_cand});
    
else
    filtGlues = {filtGlue(1:end-1)};
    technames = {''};% To be replaced by table name in the caller code
    
end

end %<eof>