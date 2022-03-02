function plotname = plotnames_struct(this,nametype)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

freqs = fieldnames(this);
num_freqs = length(freqs);

plotname = cell(0);

% Caption types to be used
if strcmpi(nametype,'techname')
    for tt = 1:num_freqs
        this_now = this.(freqs{tt});
        temp_ = this_now.techname;
        plotname = [plotname;temp_]; %#ok<AGROW>
    end
else % name
    for tt = 1:num_freqs
        this_now = this.(freqs{tt});
        temp_ = this_now.name;
        plotname = [plotname;temp_]; %#ok<AGROW>
    end
end

end %<eof>