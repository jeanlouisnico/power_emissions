function out = implode(varargin)
% 
% Creates time series collections from a set of tsobj() on input
% Complement to explode() fcn., or tsobj.explode()
% 
% Call from workspace: 
%       out = implode() ...all workspace tsobj() taken
%                       ...out [struct]
% 
% Struct() object on input:
%       out = implode(s,freq) ...    s -> struct(), 
%                             ... freq -> char [optional]
%                             ... out [tsobj]
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if nargin==0 % Base workspace contents, all tsobj() to struct()
    contents = evalin('base','who');
    if ~isempty(contents)
        valid_tsobj = cellfun(@(x) ...
            evalin('base',['isa(' x ',''tsobj'')']),contents);
        contents = contents(valid_tsobj);
        contents = contents(~strcmp(contents,'ans'));

        if ~isempty(contents)
            for ii = 1:length(contents)
                out.(contents{ii}) = evalin('base',contents{ii});
            end
            
            return
            
        end
    end
    out = '<N/A>';
    return
    
elseif nargin==1 % struct() on input
    str = varargin{1};
    if ~isstruct(str)
       error_msg('Implode','Struct object expected on the input...'); 
    end
    
    contents = fieldnames(str);
    if ~isempty(contents)
      
        valid_tsobj = structfun(@(x) isa(x,'tsobj'),str) & ~structfun(@isempty,str);
        contents = contents(valid_tsobj);
        
        if ~isempty(contents)
            
            % Only tsobj() contents
            str = str * contents;
            
            freq_orig = cellstr(structfun(@(x) x.frequency,str));
            frequencies = unique(freq_orig);
         
            if length(frequencies)==1
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%    
                % ### CORE FUNCTIONALITY ###
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if strcmp(frequencies{1},'D')
                    % Daily data are processed old way (well tested, but slower)
                    % >>> techname inheritance
                    if size(str.(contents{1}).values,2)==1
                        str.(contents{1}).techname = contents{1};
                    end
                    % <<<
                    out = str.(contents{1});
                    for ii = 2:length(contents)
                       % >>> techname inheritance
                       if size(str.(contents{ii}).values,2)==1
                           str.(contents{ii}).techname = contents{ii};
                       end
                       % <<< 

                       % ! This is slow if # of series is large (range processed each time)
                       out = [out str.(contents{ii})];  %#ok<AGROW>
                    end
                    
                    return

                else % YQM frequencies are processed faster
                    
                    cellobj = struct2cell(str);
                    [~,where_min] = min( cell2mat( cellfun(@(x) x.tind(1),struct2cell(str),'UniformOutput',false) ) );
                    [~,where_max] = max( cell2mat( cellfun(@(x) x.tind(end),struct2cell(str),'UniformOutput',false) ) );
                    tind_min = cellobj{where_min}.tind(1);
                    tind_max = cellobj{where_max}.tind(end);

                    ncont = length(contents);
                    for ii = 1:ncont
                       % >>> techname inheritance
                       if size(str.(contents{ii}).values,2)==1
                           str.(contents{ii}).techname = contents{ii};
                       end
                       % <<< 
                    end

                    technames = cellfun(@(x) x.techname,struct2cell(str),'UniformOutput',false);
                    technames = cat(1,technames{:});% tscolls imply nested cells

                    names = cellfun(@(x) x.name,struct2cell(str),'UniformOutput',false);
                    names = cat(1,names{:});% tscolls imply nested cells

                    [global_tind,global_range] = dynammo.tsobj.tind_build(frequencies{1},tind_min,tind_max);
                    
                    values = nan(length(global_range),length(technames));
                    colstart = 1;
                    for ii = 1:length(contents)
                        valsnow = str.(contents{ii}).values;
                        [pers,cols] = size(valsnow);
                       %[~,where] = ismember(str.(contents{ii}).range{1},global_range);% !# ~4 digit range no longer issue?
                        where = ismembc2(str.(contents{ii}).tind(1),global_tind);
                        values(where:where+pers-1,colstart:colstart+cols-1) = valsnow;
                        colstart = colstart+cols;
                    end

                    % Object creation
                    out = tsobj();
                    out.frequency = frequencies{1};
                    out.tind = global_tind;
                    out.range = global_range;
                    out.values = values;
                    out.techname = technames;
                    out.name = names;

                    return

                end
                    
            else
                
                if length(freq_orig)==length(frequencies) 
                   % Each frequency is present only once, we do this in order not to alter the ordering
                   frequencies = freq_orig; 
                else
                   % Ordering will be altered, so the legend entries must also be altered on the input, otherwise difficult to implement
                   % This issue usually results in wrong legend mapping to actual plot objects
                end
                
                for ii = 1:length(frequencies)
                   out.([frequencies{ii} frequencies{ii}]) = implode(str,frequencies{ii});
                end

                 return
                 
            end
        end
    end
    out = '<N/A>';
    
    return
    
elseif nargin==2 && ischar(varargin{2})
    frequency_desired = varargin{2};
    if any(strcmpi(frequency_desired,{'D','M','Q','Y'}))
        str = varargin{1};
        
        if ~isstruct(str)
           error_msg('Implode','Struct object expected on the input...'); 
        end
    
        contents = fieldnames(str);
        if ~isempty(contents)
            valid_tsobj = false(length(contents),1);
            for ii = 1:length(contents)
                valid_tsobj(ii) = isa(eval(['str.' contents{ii}]),'tsobj');
            end

            contents = contents(valid_tsobj);
            if ~isempty(contents)
                
                frequencies = contents;
                for ii = 1:length(contents)
                    frequencies{ii} = eval(['str.' contents{ii} '.frequency']);
                end

                taken = strcmpi(frequencies,frequency_desired);
                if any(taken)
                    str = str * contents(taken);% struct/mtimes() needed here!
                    out = implode(str);
                    
                    return 
                    
                end
            end
        end
        out = '<N/A>';
        
        return
        
    else
        error_msg('Implode','Implosion works for "D"|"M"|"Q"|"Y" frequencies only...'); 
    end
else
    error_msg('Implode','Too many arguments/wrong format...');
end

end % <eof>