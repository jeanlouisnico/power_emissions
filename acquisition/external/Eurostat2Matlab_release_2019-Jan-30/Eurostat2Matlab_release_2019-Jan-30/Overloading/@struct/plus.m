function out = plus(struct1,struct2)
%
% DB comparison possible for struct() of tsobj() only, tscoll() not allowed
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~isstruct(struct1) || ~isstruct(struct2)
   error_msg('DB comparison','All databases on input must be struct() objects...'); 
end

%% Data types - tsobj() allowed only

fields1 = fieldnames(struct1);
fields2 = fieldnames(struct2);

    % Round 1
    for ii = length(fields1):-1:1
        if ~isa(struct1.(fields1{ii}),'tsobj')
            struct1 = rmfield(struct1,fields1{ii});
        else
            if size(struct1.(fields1{ii}).values,2) > 1
                struct1 = rmfield(struct1,fields1{ii});
                warning_msg('DB comparison','Ignoring time series collection in DB, use explode() command first...',fields1{ii});
            end
        end
    end
    if isempty(fieldnames(struct1))
        error_msg('DB comparison','There appears to be no tsobj() on input...');
    end
    
    % Round 2
    for ii = length(fields2):-1:1
        if ~isa(struct2.(fields2{ii}),'tsobj')
            struct2 = rmfield(struct2,fields2{ii});
        else
            if size(struct2.(fields2{ii}).values,2) > 1
                struct2 = rmfield(struct2,fields2{ii});
                warning_msg('DB comparison','Ignoring time series collection in DB, use explode() command first...',fields2{ii});
            end            
        end
    end
    if isempty(fieldnames(struct2))
        error_msg('DB comparison','There appears to be no tsobj() on input...');
    end    

% Update    
fields1 = fieldnames(struct1);
fields2 = fieldnames(struct2);

%% Missing fields treatment

diff1 = fields1 - fields2;
diff2 = fields2 - fields1;

struct1 = mergestruct(struct1,struct2 * diff2);
struct2 = mergestruct(struct2,struct1 * diff1);

    % Round 1
    for ii = 1:length(diff2)
        struct1.(diff2{ii}).values = nan(size(struct1.(diff2{ii}).values));
    end

    % Round 2
    for ii = 1:length(diff1)
        struct2.(diff1{ii}).values = nan(size(struct2.(diff1{ii}).values));
    end    
    
%% Construct a cell object
out = {struct1;struct2};

end %<eof>