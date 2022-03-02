function out = strjoin2(incell, delimiter)
incell = incell(:).';
if nargin==1
    delimiter = ' ';
end
out = sprintf([delimiter '%s'],incell{:});
out(1:length(sprintf(delimiter))) = [];