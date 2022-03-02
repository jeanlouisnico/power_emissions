function this = dropnans(this)
%
% Leading/trailing NaNs get dropped out (inner NaNs are retained)
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body <stolen trim()>

dropNaNs = 0;% Dependencies: tsobj/plus, mtimes, mrdivide -> if we end up with an empty tsobj(), horzcat() will process it correctly ()
             % 0 -> trimming may be applied to the result ex post
             
if dropNaNs
    values = this.values;
    drop_start = sum(cumsum(       all(isnan(values),2) )==(1:size(values,1))');
    drop_end   = sum(cumsum(flipud(all(isnan(values),2)))==(1:size(values,1))');
    values = values(drop_start+1:end-drop_end,:);

    % Update
    this.values = values;
    this.tind = this.tind(drop_start+1:end-drop_end,1);
    this.range = this.range(drop_start+1:end-drop_end,1);
end

end %<eof>