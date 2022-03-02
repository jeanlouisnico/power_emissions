function this = mpower(first,second)
%
% (^) operator if the basis is tsobj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

first_ts  = isa(first ,'tsobj');
second_ts = isa(second,'tsobj'); %#ok<NASGU>

if first_ts
    if isscalar(second) && isa(second,'double')
        first.values = first.values .^ second;
        
        this = first;
        this.name = namechange_binary(this.name,'^',second);
        %this.techname = repmat_cellstr_empty(length(this.name));
        return
    else
        dynammo.error.tsobj('(^) operator defined for tsobj() base and scalar power only...');
    end
else
        dynammo.error.tsobj('(^) operator defined for tsobj() base and scalar power only...');
end

end %<eof>