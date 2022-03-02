function this = skipnans(this)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

filt_crit = ~all(isnan(this.values),2);

this.values = this.values(filt_crit,:);
this.tind   = this.tind(filt_crit);
this.range  = this.range(filt_crit);

end %<eof>