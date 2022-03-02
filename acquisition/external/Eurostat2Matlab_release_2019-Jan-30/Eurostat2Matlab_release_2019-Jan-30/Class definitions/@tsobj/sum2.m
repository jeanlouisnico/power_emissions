function res = sum2(this,varargin)
%
% Summation for tsobj()
% 
% See also: tsobj/sum()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
default_ = struct( ... 
...				%field			 %value
			    'allvals',          0   ... 0 = NaNs will be just skipped and thus, will not have any influence on the calculations
                                        ... 1 = the result is going to be NaN whenever NaN value is encountered along with other numeric values
                   );	
	   
% Overlay the above default structure with the user-supplied values
argsin = varargin;% >>> M2014b+ fix
args = process_user_input(default_,argsin);

%% Body

val = this.values;
if size(val,2)==1
    res = this;
    return
end

nans = isnan(val);
val(nans) = 0;
out = builtin('sum',val,2);% !! dim 2 important
    
if args.allvals==0
    out(all(nans,2)) = nan;% Nothing to put under sumation => NaN
else
    out(any(nans,2)) = nan;% incomplete sumation => NaN
end

res = this;
res.values = out;
res.techname = this.techname(1);
res.name = this.name(1);

end %<eof>