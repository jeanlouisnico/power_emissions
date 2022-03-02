function this = leadlag(this,shift)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% if shift~=floor(shift)
%    dynammo.error.tsobj('Lead/lag must be integer...'); 
% end -> handled in subsref

if strcmp(this.frequency,'Y')
    
    [this.tind,this.range] = dynammo.tsobj.tind_build('Y',eval(this.range{1}  )-shift, ...
                                                          eval(this.range{end})-shift);    
                                                      
    % Name suffix
    num_names = length(this.name);
    empty = cellfun('isempty',this.name);
    if any(~empty)
        suffix = repmat_cellstr_empty(num_names);
        suffix(~empty) = {sprintf('{%d}',shift)};
        this.name = strcat(this.name,suffix);
    end
    
    return
end

if strcmp(this.frequency,'Q') || strcmp(this.frequency,'M')
    if strcmp(this.frequency,'Q')
        fragmentation = 4;
        freq = 'Q';
    else
        fragmentation = 12;
        freq = 'M';
    end
    range_from = this.range{1};
    range_to   = this.range{end};
    years_over = floor(abs(shift)/fragmentation);
    excess_months = abs(shift) - years_over*fragmentation;
    
    year_from  = str2double(range_from(1:4));
    year_to    = str2double(range_to(1:4));
    month_from = str2double(range_from(6:end));
    month_to   = str2double(range_to(6:end));
    if shift > 0 % lead
        year_from = year_from - years_over;
        year_to   = year_to   - years_over;
        month_from = month_from - excess_months;
        month_to   = month_to   - excess_months;
        if month_from <= 0
            year_from = year_from - 1;
            month_from = month_from + fragmentation;
        end
        if month_to <= 0
            year_to = year_to - 1;
            month_to = month_to + fragmentation;
        end
    elseif shift < 0 % lag
        year_from = year_from + years_over;
        year_to   = year_to   + years_over;
        month_from = month_from + excess_months;
        month_to   = month_to   + excess_months;
        if month_from > fragmentation
            year_from = year_from + 1;
            month_from = month_from - fragmentation;
        end
        if month_to > fragmentation
            year_to = year_to + 1;
            month_to = month_to - fragmentation;
        end
    end

    bounds = range2tind({sprintf('%d%s%d',year_from,freq,month_from);sprintf('%d%s%d',year_to,freq,month_to)});
    [this.tind,this.range] = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));                                                 
    
    % Name suffix
    num_names = length(this.name);
    empty = cellfun('isempty',this.name);
    if any(~empty)
        suffix = repmat_cellstr_empty(num_names);
        suffix(~empty) = {sprintf('{%.0f}',shift)};
        this.name = strcat(this.name,suffix);
    end
    
    return
end

if strcmp(this.frequency,'D')
    dynammo.error.tsobj('Daily data not supported...');
else
    dynammo.error.tsobj('Invalid data frequency...');
end

end %<eof>