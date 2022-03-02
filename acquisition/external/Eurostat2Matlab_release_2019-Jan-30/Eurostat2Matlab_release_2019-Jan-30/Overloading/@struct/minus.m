function out = minus(in,in2)
% 
% Usage: 
% 1] Drop some entries (defined by CHAR/CELL sublist) from the input struct() object
% 2] Compare 2 struct() objs with identical field names
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if isstruct(in2)
    f1 = fieldnames(in);
    f2 = fieldnames(in2);
    if isequal(f1,f2)
        out = values2struct(struct2values(in)-struct2values(in2),f1);
    elseif isempty(union(f1,f2)-intersect(f1,f2))
        in = orderfields(in);
        in2 = orderfields(in2);
        
        out = values2struct(struct2values(in)-struct2values(in2),fieldnames(in));
        
    else
        error_msg('struct() comparison',['All fields must be identical across ' ...
                                         'the input structures. Extras found:'],union(f1,f2)-intersect(f1,f2)); 
    end
    
else
    
    sublist = in2;
	names = fieldnames(in);
	val_ = struct2cell(in);
	[~,ind_] = ismember(sublist,names);
    
	if ~all(ind_==0)
        nz_ind = ind_(ind_~=0);
        val_(nz_ind) = [];
        names(nz_ind) = [];
		out = cell2struct(val_,names,1);
	else
		out = in;
	end
end

end %<eof>
