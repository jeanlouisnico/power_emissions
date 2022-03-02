function [tind,range,values,frequency,name,techname] = EUROSTAT_wrapper(varargin)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

out = dynammo.EUROSTAT.download(varargin{:});

if isempty(out)
    values = [];
    tind = [];
    name = {''};
    frequency = [];
    range = [];
    techname = {''};
else
    tind = out.tind;
    range = out.range;
    values = out.values;
    frequency = out.frequency;
    name = out.name;
    techname = out.techname;
end

end %<eof>