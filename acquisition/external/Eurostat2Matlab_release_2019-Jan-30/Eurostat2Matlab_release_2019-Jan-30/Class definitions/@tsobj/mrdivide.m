function this = mrdivide(first,second)
%
% Division (/) operator if either of the operands is tsobj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

first_ts  = isa(first ,'tsobj');
second_ts = isa(second,'tsobj');

if first_ts
    if second_ts
        num_ts_first = size(first.values,2);
        num_ts_second= size(second.values,2);
%         if num_ts_first>1 || num_ts_second>1
%            dynammo.error.tsobj('(/) operator not defined for time series collection...');
%         end

        if num_ts_first==1 && num_ts_second==1 % Single tsobj divided by another single tsobj

            this = tsobj_div_tsobj(first,second);
            
        elseif num_ts_first>1 && num_ts_second==1 % TS collection
            first = explode(first);
            list = fieldnames(first);
            for iseries = 1:num_ts_first
                aux.result = tsobj_div_tsobj(first.(list{iseries}),second);
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
                aux.result = tsobj_div_tsobj(first.(list1{iseries}),second.(list2{iseries}));
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
            dynammo.error.tsobj(['(/) operator performs division of TS collections with ' ...
                            'compliant number of time series. ' ...
                            'If only single time series is supplied as second argument, all ' ...
                            'series from first collection will be divided by the second...']);
        end

        
    elseif isscalar(second) && isa(second,'double')
        if abs(second) > 1e-10
            first.values = first.values * (1/second);
            
            this = first;
            this.name = namechange_binary(first.name,char(247),second);
            %this.techname = repmat_cellstr_empty(length(this.name));
            return
        else
            dynammo.error.tsobj('Division by zero!');
        end
    else
        dynammo.error.tsobj('(/) operator defined for scalar/tsobj() arguments only...');
    end
    
elseif isscalar(first) && isa(first,'double')
    if second_ts
        
        % Division by zero
        vals_ = second.values;
        smallzero_ = abs(vals_) < 1e-10;
        
        second.values = first ./ second.values;
        second.values(smallzero_) = NaN;
       
        this = second;
        this.name = namechange_binary(first,char(247),second.name);
        %this.techname = repmat_cellstr_empty(length(this.name));
        return
    else
        disp('||| Dead end, this should never occur...');
        keyboard;
    end
    
else
    dynammo.error.tsobj('(/) operator defined for scalar/tsobj() arguments only...');
end

%% Subfunctions

    function this = tsobj_div_tsobj(first,second)
        % This function processes 2 single tsobj objs (tscoll get exploded before calling this fcn)
        
        % >>> Alignment of dimensions happens here (NaN padding) %%%%
        this = [first second];
        % <<< %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if isstruct(this)
           dynammo.error.tsobj('(/) operator: Frequency mismatch...');
        end
        
        % Division by zero
        values = this.values(:,2);
        smallzero = abs(values) < 1e-10;
        
        % Addition (horizontal)
        this.values = this.values(:,1)./this.values(:,2);%sum(this.values,2);
        this.values(smallzero) = NaN;
        
        % All NaN values can get dropped out
        this = dropnans(this);
        
        % Names
        if strcmp(first.techname,second.techname)
            this.name = first.name;
            this.techname = first.techname;
        else
            this.name = namechange_binary(first.name,char(247),second.name);
            %this.techname = {''};% Never more than 1 dimension
             this.techname = first.techname;
        end
        
    end %<tsobj_div_tsobj>

end %<eof>