function out = namechange_unary(name,fcn)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

tscoll = length(name);

if tscoll==1 % single time series
    if isempty(name{:})
        name  = {'#'};
    end
    out = strcat(fcn,'(',name,')');
    return

else % ts collection
    prefix = repmat_cellstr([fcn '('],tscoll);
    suffix = repmat_cellstr(')',tscoll);
    
    empties = cellfun('isempty',name );

    name(empties) = repmat_cellstr('#',sum(empties));
    out = strcat(prefix,name,suffix);
    return
end

end