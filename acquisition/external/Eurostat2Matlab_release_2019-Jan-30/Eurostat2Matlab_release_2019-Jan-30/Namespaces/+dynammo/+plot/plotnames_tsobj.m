function plotname = plotnames_tsobj(this,nametype)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

% -> plotname has multiple items all of which can be used for legend,
%    only the first one is to be used for the caption!! <ok to have more strings in plotname>

% Caption types to be used
if strcmpi(nametype,'techname')
    plotname = this.techname;
else % name
    plotname = this.name;
end
    
end %<eof>