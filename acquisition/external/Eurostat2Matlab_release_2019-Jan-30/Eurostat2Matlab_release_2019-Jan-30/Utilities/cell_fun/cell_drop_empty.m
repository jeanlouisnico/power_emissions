function cell_out = cell_drop_empty(cell_,varargin)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% >>> Handle function arguments:
default_ = struct( ... %field   %value    
                   'direction',  'south' ... 
                   );
args = process_user_input(default_,varargin);
% <<<


% >>> UPGRADE BELOW <<<
% keyboard; 
test_nested_cell = cellfun(@iscell,cell_);
empty_anyway  = cellfun(@isempty,cell_);
test_nested_cell = test_nested_cell.*~empty_anyway;
test_nested_cell = find(test_nested_cell==1);

if any(test_nested_cell)
	
	for ii = 1:length(test_nested_cell)
			cell_new = cell_drop_empty(cell_{test_nested_cell(ii)},'direction',args.direction);
			cell_{test_nested_cell(ii)} = cell_new;
	end
	
end
[row_, col_] = size(cell_); 
if strcmpi(args.direction,'south')
	ind_ = cellfun(@isempty,cell_(:,1));
	cell_ = cell_(~repmat(ind_,1,col_));
	cell_out = reshape(cell_,sum(ind_==0),col_);
elseif strcmpi(args.direction,'east')
	ind_ = cellfun(@isempty,cell_(1,:));
	cell_ = cell_(~repmat(ind_,row_,1));
	cell_out = reshape(cell_,row_,sum(ind_==0));
else 
	error_msg('Cell_drop_empty','Invalid user input, possible values "south/east":',args.direction);
end

end