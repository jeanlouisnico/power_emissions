function val = process_values(val)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~isa(val,'double')
    dynammo.error.tsobj('The values must be numeric...');
end

end