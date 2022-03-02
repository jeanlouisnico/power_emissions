function this = normalize(this)
%
% Normalizes the input series to <-1,+1> interval
% -> values greater than mean are in <0,+1> halfplane
% -> values smaller than mean are in <-1,0> halfplane
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

%% Demeaned series
this = demean(this);

%% Body

vals = this.values;
[r,c] = size(vals);

nans = isnan(vals);

mins = ones(r,1)*min(vals,[],1);
maxs = ones(r,1)*max(vals,[],1);

% Fields with constant value will be demeaned (zeroed)
to_be_demeaned = mins(1,:)==maxs(1,:);
if any(to_be_demeaned(:))
    vals(:,to_be_demeaned) = zeros(r,sum(to_be_demeaned(:),1));
end

vals_pos = vals>0;
tmp = vals./maxs;% (x-min)/(max-min), min=0 (demeaned data) -> x/max only
vals(vals_pos) = tmp(vals_pos);

vals_neg = vals<0;
tmp = (mins-vals)./mins-1;% (x-min)/(max-min), max=0 -> (x-min)/(-min) -> (min-x)/min only
                          % -1 here to make it inside <-1,0> interval
vals(vals_neg) = tmp(vals_neg);

vals(nans) = nan;

this.values = vals;

end %<eof>