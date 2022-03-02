function out = subsasgn(this,subobj,values)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
if strcmp(subobj(1).type,'.')
    switch upper(subobj(1).subs)
        case {'NAME','TECHNAME'}
            
            % Input validation of technames
            % -> Assigned values must for a valid Matlab variable name,
            %    i.e. free of spaces and special characters, starting with a letter
            % -> 'name' property can take up any values
            if strcmpi(subobj(1).subs,'techname')
                % !!! we only test here that the first elements are letters
                if ischar(values)
                    test_val = {values};
                else
                    test_val = values;
                end
                
                validnames = cellfun(@isvarname,test_val);
                if ~all(validnames)
                    dynammo.error.tsobj(['The ''techname'' property must be assigned with valid Matlab ' ...
                                 'variable names, i.e. must start with a letter and can contain ' ...
                                 'alphanumeric entries, or underscores'],test_val(~validnames));                    
                end
                
            end
            
            if isa(values,'char')
                if isempty(this.values) % For empty object
                    dynammo.error.tsobj(['Empty time series object cannot be changed, ' ...
                                 'create a new object the usual way, i.e. tsobj(period,data,[name]), '...
                                 'techname and name properties can be assigned ex post']);
                end
                
                % The assignment itself
                if length(subobj)==1 % t.name = ... case
                    if size(this.values,2)==1
                        this = builtin('subsasgn',this,subobj,{values});
                    else
                       %this = builtin('subsasgn',this,subobj, values );
                        dynammo.error.tsobj(['Time series object has ' sprintf('%.0f',size(this.values,2)) ...
                                   ' individual time series. This # must match ' ...
                                   'the # of names/technames being assigned']);
                    end
                elseif length(subobj)==2 % t.name{#} = ... case
                    if subobj(2).subs{1}<=size(this.values,2) && subobj(2).subs{1}>=1
                        this = builtin('subsasgn',this,subobj,values);
                    else
                        dynammo.error.tsobj(['Time series object has ' sprintf('%.0f',size(this.values,2)) ...
                                   ' individual time series. Assignment position out of bounds:'],sprintf('%g',subobj(2).subs{1}));                        
                    end
                end

                out = this;
                return
                
            elseif isa(values,'cell')
                if size(this.values,2)==length(values)
                    this.(subobj(1).subs) = values(:);
                else
                    dynammo.error.tsobj(['Time series object has ' sprintf('%.0f',size(this.values,2)) ...
                               ' individual time series. This # must match ' ...
                               'the # of names being assigned ' ...
                               '(currently ' sprintf('%.0f',length(values)) ')...']);
                end
                out = this;
                return
            else
                dynammo.error.tsobj('Name of the series should be a string...');
            end  
        otherwise
            out = builtin('subsasgn',this,subobj,values);
            return
    end
end

%% Core operations
if strcmp(subobj.type,'()')
%     keyboard;
    if ~isa(values,'double')
        dynammo.error.tsobj('Non-numeric entry on assignment...');
    end

    freq = this.frequency;
    if ~isempty(freq)
        subtind = tindrange(freq,subobj.subs{1});
    else
        % Redefine currently empty tsobj() based on user supplied values
        [subtind,~,freq] = process_range(subobj.subs{1});
        
    end
    
    
    % Dimensions
    if ~isempty(this.values)
        
        if ~strcmpi(freq,this.frequency)
            dynammo.error.tsobj('Frequency mismatch...'); 
        end
    
        c = size(this.values,2);
        [rnow,cnow] = size(values);
    
        if rnow == 1
            if cnow == 1
                values = repmat(values,length(subtind),c);
            elseif cnow == c
                values = repmat(values,length(subtind),1);
            else
                dynammo.error.tsobj('Dimension mismatch on assignment...');
            end
        elseif rnow == length(subtind)
            if cnow == 1
                values = repmat(values,1,c);
            elseif cnow ~= c
                dynammo.error.tsobj('Dimension mismatch on assignment...');
            end
        else
            dynammo.error.tsobj('Dimension mismatch on assignment...');
        end
        
    else
        
        % creation of new tsobj()
        tsobj_from_scratch();
        out = this;
        return
       
    end
    
    if subtind(1) > this.tind(1) 
       start_new = this.tind(1);
    else
       start_new = subtind(1);
    end
    if subtind(end) < this.tind(end) 
       finish_new = this.tind(end);
    else
       finish_new = subtind(end);
    end

   [tind,range] = dynammo.tsobj.tind_build(freq,start_new,finish_new);
    
    % Fill back original values 
    valnew = nan(length(tind),c);
    where = ismembc2(this.tind,tind);
    valnew(where,:) = this.values;
    
    % Override with new values
    where = ismembc2(subtind,tind);
    valnew(where,:) = values;
    this.values = valnew;
    
    % Update
    this.tind = tind;
    this.range = range;
    out = this;
    return
    
end

if strcmp(subobj.type,'{}')
    
    dynammo.error.tsobj('Always use standard parentheses () for assignment...');
            
end

%% Subfunctions

function tsobj_from_scratch()
    
    % Fill values
    t = length(subtind);
    [n,col] = size(values);
    if t ~= n
        if n == 1
            values = repmat(values,t,1); 
        else
            dynammo.error.tsobj('Dimension mismatch on assignment...');
        end
    end
    
    this.frequency = freq;
    this.tind = subtind;
    this.range = tind2range(subtind,freq);
    this.values = values;
    this.name = repmat_cellstr_empty(col);
    this.techname = this.name;
    
end %<tsobj_from_scratch>

end %<eof>