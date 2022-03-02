function [plots_per_page,full_pages,remainder] = subplot_design(args,nsubplots)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body    
plots_per_page = args.subplot(1) * args.subplot(2);
full_pages = floor(nsubplots/plots_per_page);
remainder = nsubplots - plots_per_page*full_pages; 
    
end %<eof>