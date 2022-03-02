function out = repmat_cell(in,n)
%
% Vertical concatenation of cell
%
% INPUT: in ...input cell (should be horizontally oriented)
%        n  ...# of input cell repetitions
%
% OUTPUT: out ...cell object repeated rows
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

len = 1;
out = in(len(:,ones(n,1)),:);

end %<eof>