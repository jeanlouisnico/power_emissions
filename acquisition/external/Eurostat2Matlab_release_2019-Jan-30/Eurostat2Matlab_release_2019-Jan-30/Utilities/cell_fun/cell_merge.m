function out = cell_merge(in)
%
% Similar to built-in 'union' fcn, but cell_merge operates
% on cell objects with encapsulated cell lists

% INPUT: cell obj of cells having different # of elements (sub-cells)
% OUTPUT: pool of all elements (unique)

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Old setup
count_ = max(size(in));

if count_ == 1
%     keyboard;
    if isempty(in)
        out = in(:);
        return
    else
        in = cell_merge([in;in]); % Duplicities are removed anyway...
        out = in(:);
        return;
    end
end

if all(cellfun(@isempty,in))
    out = cell(0,0);
    return;
end

for ii = 2:count_
% 	if ~iscell(in(ii))
% 			temp_ = cell(1,1);
% 			temp{1,1} = in(ii);
% 			in(ii) = temp(1,1);
% 	end
		
    if ii == 2
% 		if ~iscell(in(ii-1))
% 			temp_ = cell(1,1);
% 			temp{1,1} = in(ii-1);
% 			in(ii-1) = temp(1,1);
% 		end
		out = union(in{ii-1},in{ii});
    else
%         keyboard;
        out = union(out,in{ii});
    end
end

%% Vectorize
out = out(:);

%% New setup

% for ii = 1:length(in)
%     out = 
% end

end %<eof>