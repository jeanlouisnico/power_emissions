function nms = process_name(nms,n)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ischar(nms) 
    nms = {nms};
end

if ~iscellstr(nms)
    dynammo.error.tsobj('Name of the time series must be a string or a cell of strings...');        
end

if length(nms)~=n
    dynammo.error.tsobj(['# of time series (' sprintf('%d',n) ') does ' ...
               ' not match the # of provided names (' sprintf('%d',length(nms)) ')...']);
end
                    
nms = nms(:);
    
end