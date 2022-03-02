function out = mtimes(in,sublist)
% 
% Usage: out = in * sublist
%
% Substruct from a struct() object achieved by applying '*' operator.
% Fields that are not found are skipped without any warning message.
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

	names = fieldnames(in);
	val_ = struct2cell(in);
	[~,ind_] = ismember(sublist,names);
	if ~all(ind_==0)
		out = cell2struct(val_(ind_(ind_~=0)),names(ind_(ind_~=0)),1);
	else
		out = struct();
	end
	
end %<eof>
