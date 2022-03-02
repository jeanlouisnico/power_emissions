function out = std(this,varargin)
%
% Computes standard deviation of given tsobj()
%   - if a collection of time series is on input, vector of STDs will be returned
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
default_ = struct( ... 
...				%field			 %value
			    'allvals',       0   ... 0 = NaNs will be just skipped and thus, will not have any influence on the calculations
                                     ... 1 = the result is going to be NaN whenever NaN value is encountered along with other numeric values
                   );	
	   
% Overlay the above default structure with the user-supplied values
args = process_user_input(default_,varargin);

%% Body

val = this.values;
n = size(val,2);
out = nan(1,n);

if args.allvals==0
    for ii = 1:n
        t = val(:,ii);
        t = t(~isnan(t));
        if ~isempty(t)
            out(ii) = std(t);
        end
    end
else
    for ii = 1:n
        t = val(:,ii);
        if ~any(isnan(t))
            out(ii) = std(t);
        end
    end    
end

end %<eof>