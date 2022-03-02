function out = trimNaNs(this,range)
% 
% The same functionality as tsobj/trim()...
% ...but range here is taken as granted, NaN padding is applied at missing data segments
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input validation
if nargin==1
   error_msg('Trimming','2nd argument specifying ''range'' is mandatory...');
end

%% Auxiliary NaN series 

nan_ts = tsobj();
nan_ts.name = this.name;
nan_ts.techname = this.techname;
nan_ts.frequency = this.frequency;
[nan_ts.tind,nan_ts.range] = ...
            tindrange(this.frequency,range);
nan_ts.values = nan(length(nan_ts.tind),size(this.values,2));

if nan_ts.tind(1)  >this.tind(end) || ...
   nan_ts.tind(end)<this.tind(1)
    out = nan_ts;
    return
end

%% Fill values

out = nan_ts;

if nan_ts.tind(1)<this.tind(1)
    
    % Start outside
    w1 = ismembc2(this.tind(1),nan_ts.tind);
    
    if nan_ts.tind(end)<=this.tind(end)
        % End inside
        w2 = ismembc2(nan_ts.tind(end),this.tind);
        out.values(w1:end,:) = this.values(1:w2,:);
    else
        % End outside
        w2 = ismembc2(this.tind(end),nan_ts.tind);
        out.values(w1:w2,:) = this.values;
    end
    
else
    % Start inside
	w1 = ismembc2(nan_ts.tind(1),this.tind);
    
    if nan_ts.tind(end)<=this.tind(end)
        % End inside
        w2 = ismembc2(nan_ts.tind(end),this.tind);
        out.values = this.values(w1:w2,:);
    else
        % End outside
        w2 = ismembc2(this.tind(end),nan_ts.tind);
        out.values(1:w2,:) = this.values(w1:end,:);
    end    
end

end %<eof>