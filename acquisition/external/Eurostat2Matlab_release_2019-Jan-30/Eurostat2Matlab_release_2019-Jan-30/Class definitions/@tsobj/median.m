function out = median(this,varargin)
% 
% Calculates the median value of tsobj()
% 
% INPUT: this ...tsobj()
%        [varargin] ...options (see the Options section below)
% 
% OUTPUT: Number, not a tsobj()
% 
% NOTE: If a collection of time series is on input, the output will be a vector
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
args = process_user_input(default_,varargin);

%% Body

values = this.values;
col = size(values,2);

out = zeros(1,col);

if args.allvals==0
    for ii = 1:col
        valnow = values(:,ii);
        out(1,ii) = median(valnow(~isnan(valnow)));% This should even work if all are nans (returns NaN)
    end
else
    for ii = 1:col
        valnow = values(:,ii);
        if any(isnan(valnow))
            out(1,ii) = NaN(1,1);
        else
            out(1,ii) = median(valnow);
        end
    end
end

end