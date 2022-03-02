function this = mtimes(first,second)
%
% (*) operator if either of the operands is tsobj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

first_ts  = isa(first ,'tsobj');
second_ts = isa(second,'tsobj');

if first_ts
    if second_ts
        num_ts_first = size(first.values,2);
        num_ts_second= size(second.values,2);
%         if num_ts_first>1 || num_ts_second>1
%            dynammo.error.tsobj('(*) operator not defined for time series collection...');
%         end
        if num_ts_first==1 && num_ts_second==1 % Single tsobj divided by another single tsobj
            this = tsobj_times_tsobj(first,second);
            
        elseif num_ts_first>1 && num_ts_second==1 % TS collection
            first = explode(first);
            list = fieldnames(first);
            for iseries = 1:num_ts_first
                aux.result = tsobj_times_tsobj(first.(list{iseries}),second);
                if iseries==1
                   aux.this = aux.result; % 'aux' here to avoid techname inheritance in horzcat
                   %aux.this.techname = {''};
                else
                   aux.this = [aux.this aux.result];
                   %aux.this.techname{end} = '';
                end
            end
            this = aux.this;
        
        elseif num_ts_first==1 && num_ts_second>1 % TS collection <the same as above, but swap arguments>
            auxthird = second;
            second = first;
            first  = auxthird;
            
            first = explode(first);
            list = fieldnames(first);
            for iseries = 1:num_ts_first
                aux.result = tsobj_times_tsobj(first.(list{iseries}),second);
                if iseries==1
                   aux.this = aux.result; % 'aux' here to avoid techname inheritance in horzcat
                   %aux.this.techname = {''};
                else
                   aux.this = [aux.this aux.result];
                   %aux.this.techname{end} = '';
                end
            end
            this = aux.this;           
            
        elseif num_ts_first==num_ts_second % Time series collections of the same size
            first = explode(first);
            second = explode(second);
            
            list1 = fieldnames(first);
            list2 = fieldnames(second);
            for iseries = 1:num_ts_first
                aux.result = tsobj_times_tsobj(first.(list1{iseries}),second.(list2{iseries}));
                if iseries==1
                   aux.this = aux.result; % 'aux' here to avoid techname inheritance in horzcat
                   %aux.this.techname = {''};
                else
                   aux.this = [aux.this aux.result];
                   %aux.this.techname{end} = '';
                end
            end
            this = aux.this;
            
        else
            dynammo.error.tsobj(['(*) operator performs multiplication of TS collections with ' ...
                            'compliant number of time series. ' ...
                            'One object may even be single time series...']);
        end         

        
    elseif isscalar(second) && isa(second,'double')
        first.values = first.values * second;
        this = first;
        this.name = namechange_binary(first.name,char(215),second);
        %this.techname = repmat_cellstr_empty(length(this.name));
        return
        
    elseif ischar(second) || iscell(second)
        if any(cellfun('isempty',first.techname))
            dynammo.error.tsobj('All technames need to be specified for the (*) operator to work properly...');
        end
        if iscell(second)
            if ~all(cellfun(@ischar,second))
                dynammo.error.tsobj('(*) operator with cell object as 2nd argument must contain a list of strings...');
            end
        else
            second = {second};% Char on input
        end
        [~,ind_] = ismember(second,first.techname);
        if ~all(ind_==0)
            this = first;
            trueind = ind_(ind_~=0);
            this.values = this.values(:,trueind);
            this.name = this.name(trueind);
            this.techname = this.techname(trueind);
        else
            this = tsobj();
        end
        return
    else
        dynammo.error.tsobj(['(*) operator is primarily defined for scalar/tsobj() ' ...
                     'arguments only. Second argument may potentially be a cell ' ...
                     'object of strings...']);
    end
elseif isscalar(first) && isa(first,'double')
    if second_ts
        second.values = second.values * first;
        this = second;
        this.name = namechange_binary(first,char(215),second.name);
        %this.techname = repmat_cellstr_empty(length(this.name));
        return
    else
        disp('||| Dead end, this should never occur...');
        keyboard;
    end
else
    dynammo.error.tsobj('(*) operator defined for scalar/tsobj() arguments only...');
end

%% Subfunctions

    function this = tsobj_times_tsobj(first,second)
        
        % Alignment of dimensions happens here (NaN padding)
        this = [first second];
        
        % Multiplication (elementwise)
        this.values = this.values(:,1).*this.values(:,2);%sum(this.values,2);
        
        % All NaN values can get dropped out
        this = dropnans(this);
        
        % Names
        this.name = namechange_binary(first.name,char(215),second.name);
        %this.techname = {''};% Never more than 1 dimension
         this.techname = first.techname;
        
    end %<tsobj_times_tsobj>
                
end %<eof>