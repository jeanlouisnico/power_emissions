function out = sum(this,varargin)
%
% Summation for tsobj()
% 
% See also: tsobj/sum2()
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
nans = isnan(val);
val(nans) = 0;
out = builtin('sum',val,1);% !! dim 1 important
    
if args.allvals==0
    out(all(nans,1)) = nan;% Nothing to put under sumation => NaN
else
    out(any(nans,1)) = nan;% incomplete sumation => NaN
end

end %<eof>