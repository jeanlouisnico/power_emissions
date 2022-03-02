function this = demean(this)
%
% Returns demeaned time series
%
% INPUT: tsobj()
%
% OUTPUT: tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

vals = this.values;
[r,c] = size(vals);

rrep = r*ones(1,c);

% NaNs treatment
nans = isnan(vals);
all_empty = all(nans,1);
nan_counts = sum(nans,1);
nan_counts(all_empty) = NaN;
vals(nans) = 0;

% Mean formula
sums = sum(vals,1);
means = sums./(rrep-nan_counts);

% Output
mean_vect = ones(r,1)*means;
this.values = this.values-mean_vect;


end %<eof>