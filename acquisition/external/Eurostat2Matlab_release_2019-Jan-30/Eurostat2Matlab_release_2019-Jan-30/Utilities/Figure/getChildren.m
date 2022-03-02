function allch = getChildren(han)
%
% All children from a figure, including grand children, great grand children, etc.
%
% INPUT: figure handle
%
% OUTPUT: vector of children
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

allch = get(han,'children');

if isempty(allch)
    return
else
   for ii = 1:length(allch)
       
       % Recursion
       grand_kids = getChildren(allch(ii));
       
       % Appending is always after main allch objects through which we loop
       if ~isempty(grand_kids)
           allch = [allch(:);grand_kids(:)];
       end
       if strcmpi(get(allch(ii),'Type'),'axes')
           tit_cand = get(allch(ii),'title');
           if ishandle(tit_cand)
               allch = [allch(:);tit_cand(:)];
           end
       end
       
   end
end

end %<eof>