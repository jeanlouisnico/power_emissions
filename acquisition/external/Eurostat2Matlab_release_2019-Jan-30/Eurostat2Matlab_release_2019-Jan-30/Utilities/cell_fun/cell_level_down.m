function out = cell_level_down(in)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% INPUT: cell of one-element cell objects 
%		  (if more elements -> only the first is retained from each cell)
% OUTPUT: cell of all elements
% 
% SIMILAR: cat(1,in{:}) -> all contents pooled
%          cat(2,in{:}) -> all contents pooled (original dimensions still in tact) 

if isempty(in)
	out = in;
else
%     keyboard; 
%     tic;
    out = cell(1,max(size(in)));

	for ii = 1:max(size(in))
		if ~isempty(in{ii})
			out{1,ii} = in{ii}{:};
% 		else
% 			out{1,ii} = '';
		end
    end
%     toc;
% -> slower !!
%     tic;
%     out = cellfun(@(x) x{:}, ...
%                    in(~cellfun(@isempty,in)), ...
%                   'UniformOutput',false);
% toc;
end

end