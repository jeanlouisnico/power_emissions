function varargout = subsref(this,subobj)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if strcmp(subobj(1).type,'.')
    if strcmp(subobj(1).subs,'frequency') && nargout==0
        if ~isempty(this.frequency)
            switch upper(this.frequency)
                case 'D'
                    disp([sprintf('\n'),'Daily',sprintf('\n')]);
                case 'M'
                    disp([sprintf('\n'),'Monthly',sprintf('\n')]);    
                case 'Q'
                    disp([sprintf('\n'),'Quarterly',sprintf('\n')]);    
                case 'Y'
                    disp([sprintf('\n'),'Yearly',sprintf('\n')]);    
                otherwise
                    dynammo.error.tsobj('Unknown data frequency...');
            end
        else
            disp([sprintf('\n'),'Frequency unspecified...',sprintf('\n')]);  
        end
    elseif any(ismember(subobj(1).subs,this.techname))
        varargout{1} = this*subobj(1).subs;
        
    else
        varargout{1} = builtin('subsref',this,subobj);
    end
    return
end

% Get data by specified range
if strcmp(subobj.type,'()')
    
    % Numeric input (short range notation only)
    if isa(subobj.subs{1},'double')
        bounds = subobj.subs{1};
        subobj.subs = {sprintf('%d:%d',bounds(1),bounds(end))};        
    end
    
    if strcmp(subobj.subs{1},':')
       varargout{1} = this.values;
       return
    end
    freq = this.frequency;
    
    % >>> ismember by-pass
   %[~,subrange] = tindrange(freq,subobj.subs{1});    
   %start_  = subrange(1);
   %finish_ = subrange(end);
   %
   %[start_in, start_where]  = ismember(start_, this.range);
   %[finish_in,finish_where] = ismember(finish_,this.range);
   
    [subtind,subrange] = tindrange(freq,subobj.subs{1});    
    start_  = subtind(1);
    finish_ = subtind(end);
    
    % 1/0 if within tind bounds
    start_in  = ismembc(start_,this.tind);
    finish_in = ismembc(finish_,this.tind);
    
    % Position within tind bounds
    start_where  = ismembc2(start_,this.tind);
    finish_where = ismembc2(finish_,this.tind);
    % <<<
    
    cols = size(this.values,2);
    
    if start_in && finish_in
            if nargout == 1
               varargout{1} = this.values(start_where:finish_where,:);
            else
               display(this.values(start_where:finish_where,:));
            end
            
    elseif start_in && ~finish_in
           %[~,where] = ismember(this.range(end),subrange);
            where = ismembc2(this.tind(end),subtind);
            if nargout == 1
                varargout{1} = [this.values(start_where:end,:);nan(length(subrange)-where,cols)];
            else
                display([this.values(start_where:end,:);nan(length(subrange)-where,cols)]); 
            end
            
    elseif ~start_in && finish_in
           %[~,where] = ismember(this.range(1),subrange);
            where = ismembc2(this.tind(1),subtind);
            if nargout == 1
                varargout{1} = [nan(where-1,cols);this.values(1:finish_where,:)];
            else
                display([nan(where-1,cols);this.values(1:finish_where,:)]); 
            end
    elseif ~start_in && ~finish_in
            dynammo.error.tsobj('Indexing out of bounds...',subobj.subs);
    end
    
    return
    
end

% get tsobj()
if strcmp(subobj.type,'{}')
    
    % Numeric input (short range notation only)
    if isa(subobj.subs{1},'double')
        %if subobj.subs{1}(1) > 1900 % Lead/lag syntax must not end up here, only range referencing
        %    % This should be range specification
        %    bounds = subobj.subs{1};
        %    subobj.subs = {[sprintf('%.0f',bounds(1)) ':' sprintf('%.0f',bounds(end))]};
        %end
        if ~isscalar(subobj.subs{1}) % Lead/lag syntax must not end up here, only range referencing
                                     % Scalar range specification not allowed
            % This should be range specification
            bounds = subobj.subs{1};
            subobj.subs = {sprintf('%d:%d',bounds(1),bounds(end))};            
        end
    end
    
    if ischar(subobj.subs{1}) || iscell(subobj.subs{1})
        % Trimming
        if nargout == 1
            %this.techname = inputname(1);
            varargout{1} = trim(this,subobj.subs{:});
        else
            display(trim(this,subobj.subs{:})); 
        end
    elseif isscalar(subobj.subs{1})
        % Lead/lag
        if floor(subobj.subs{1})==subobj.subs{1} 
            if nargout == 1
                varargout{1} = leadlag(this,subobj.subs{1});
            else
                display(leadlag(this,subobj.subs{1})); 
            end
        else
            dynammo.error.tsobj('Lead/lag referencing must be integer...');
        end    
    else
        dynammo.error.tsobj('"{}" reference invalid...');
    end
    
    return
end

dynammo.error.tsobj('Unknown index referencing...');

end