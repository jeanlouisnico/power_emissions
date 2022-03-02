function out = subsasgn(this,subobj,values)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

if strcmpi(subobj(1).subs,'SOURCE')
    dynammo.error.dbobj('''source'' field is not to be changed by the user...');
end

if strcmp(subobj(1).type,'.')
%     keyboard;
    switch upper(subobj(1).subs)
        case {'TABLE'}
            if ~isstruct(values)
                dynammo.error.dbobj('''table'' must be a valid struct() from TOC() function...');
            else
                if ~isfield(values,'downloadLink')
                    dynammo.error.dbobj('''table'' must contain a ''downloadLink'' field...');
                end
                
                out = builtin('subsasgn',this,subobj,values);
                
                % Update the listeners
                subsnow = subobj(1);
                subsnow(1).subs = 'status';
                out = builtin('subsasgn',out,subsnow,'Empty filter: tsobj() call will give available filtering options...');
                subsnow(1).subs = 'filter';
                out = builtin('subsasgn',out,subsnow,'');% Empty filter, must be specified after table
                return
                
            end
        
        case {'ENGINE'}
            if ischar(values)
                if any(strcmpi(values,{'json';'bulk/sdmx'})) %strcmpi(values,'json') || strcmpi(values,'bulk/sdmx')
                    out = builtin('subsasgn',this,subobj,upper(values));
                    
                    % Update the listeners
                    if strcmpi(values,'bulk/sdmx') && ischar(this.filter) % CHAR filter results from JSON web query
                        subsnow = subobj(1);
    %                     if strcmpi(values,'json')
    %                         subsnow(1).subs = 'status';
    %                         out = builtin('subsasgn',out,subsnow,'...'); % -> Technically JSON web query builder can be used
    %                                                                           for a single time series extraction (multidim. not allowed)
    %                     end
                        subsnow(1).subs = 'filter';
                        out = builtin('subsasgn',out,subsnow,'');% Empty filter, must be specified after change of engine
                    end
                    return
                    
                end
            end
            
            dynammo.error.dbobj('''engine'' can take up only the following values:',{'JSON';'BULK/SDMX'});
            
        case {'FILTER'}
            if ischar(values) % Used for clearing the filtering criterion
                
                if isempty(values) || ...
                  ~isempty(strfind(values,'?')) % -> filter for JSON can originate in the query builder
                    out = builtin('subsasgn',this,subobj,values);

                    % Update the listeners
                    subsnow = subobj(1);
                    subsnow(1).subs = 'status';
                    if isempty(values)
                        out = builtin('subsasgn',out,subsnow,'Empty filter: Calling tsobj() will give available filtering options...');
                    else
                        out = builtin('subsasgn',out,subsnow,'Ready to fetch data using tsobj() - JSON web query applied as filter...');
                    end
                    return
                    
                else
                    dynammo.error.dbobj(['To clear the ''filter'', an empty string must ' ...
                                 'be passed in. However, struct() object ' ...
                                 'usually expected on input...']);
                    
                end
                
            end
            
            if ~isstruct(values)
                dynammo.error.dbobj('''filter'' must be a valid struct() with fields corresponding to the Data Structure Definition (DSD)...');
            end
            
            out = builtin('subsasgn',this,subobj,values);

            % Update the listeners
            subsnow = subobj(1);
            subsnow(1).subs = 'status';
            out = builtin('subsasgn',out,subsnow,'Ready to fetch data using tsobj()...');
            return
            
        case {'OFFLINE'}
            
            if any(values==[0;1])
                out = builtin('subsasgn',this,subobj,values);
                
                subsnow = subobj(1);
                subsnow(1).subs = 'deleteSourceFiles';
                out = builtin('subsasgn',out,subsnow,0);% We should not delete any of the input files in 'offline' mode
                
                return
                
            end
        
            dynammo.error.dbobj('''offline'' property can take up only 0/1 values...');

        case {'DELETESOURCEFILES'}
            if any(values==[0;1])
                subobj(1).subs = 'deleteSourceFiles';
                out = builtin('subsasgn',this,subobj,values);
              
                return
                
            end
        
            dynammo.error.dbobj('''deleteSourceFiles'' property can take up only 0/1 values...');
            
        otherwise
            out = builtin('subsasgn',this,subobj,values);
            return
    end
end

end %<eof>