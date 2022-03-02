function out = cell_dlm_explode(in,sep)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% ','/';'/... delimiter explosion

out = regexp(in,sep,'split');
out = cell_drop_empty(out,'direction','east');
        

end