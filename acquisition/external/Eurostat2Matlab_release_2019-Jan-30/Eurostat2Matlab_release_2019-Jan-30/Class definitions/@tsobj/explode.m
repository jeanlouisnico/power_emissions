function out = explode(this)
%
% Collapses a collection of tsobj() into a struct() of individual time series
% - the struct() field names are determined according to the 'techname'
%   property of the input tsobj()
% - if the 'techname' property is empty for some (or all) of the time series,
%   an artificial name will be generated automatically
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Pre-check
[~,vars] = size(this.values);

%% Valid name space

names = this.name;

% Technames
counter_ = 1;
for ii = 1:vars
    namenow = this.techname{ii};
    if isempty(namenow)
        this.techname{ii} = sprintf('auxname_%.0f',counter_);
        counter_ = inc(counter_);
        continue
    end

    % Technames made unique
    found_where = find(strcmp(this.techname,namenow));
    if ~isscalar(found_where)
        count_ = length(this.techname);
        suffix_ = repmat_cellstr_empty(count_);
        temp_ = (counter_:counter_+length(found_where)-1);
        suffix_(found_where) = cellstr(strcat('_', ...
                                    cellfun(@(x) sprintf('%.0f',x),num2cell(temp_(:)),'UniformOutput',false)));
        this.techname = strcat(this.techname,suffix_);
        counter_ = inc(counter_,length(found_where));
    end
end

%% Struct() definition

for ii = 1:vars
    out.(this.techname{ii}) = tsobj();
    out.(this.techname{ii}).range = this.range;
    out.(this.techname{ii}).tind  = this.tind;
    out.(this.techname{ii}).frequency = this.frequency;
    out.(this.techname{ii}).values = this.values(:,ii);
    out.(this.techname{ii}).name = names(ii);
    out.(this.techname{ii}).techname = this.techname(ii);    
end

end %<eof>