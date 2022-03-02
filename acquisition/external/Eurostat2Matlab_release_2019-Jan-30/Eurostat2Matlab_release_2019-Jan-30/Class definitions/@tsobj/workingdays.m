function this = workingdays(this)
%
% Skip week-end observations in given tsobj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~strcmpi(this.frequency,'D')
   dynammo.error.tsobj(['Working days trimming can be applied to ' ...
             'data with daily frequency only...']); 
end

this = skipnans(this);

end %<eof>