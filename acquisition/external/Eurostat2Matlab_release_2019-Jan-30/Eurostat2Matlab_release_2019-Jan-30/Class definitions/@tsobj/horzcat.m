function out = horzcat(varargin)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% out ...tsobj() / struct()

if nargin==1
   out = varargin{1};
   %out.techname = {inputname(1)};
   return
end

%% User/function call
% user_call = length(dbstack());

inputnames = {};
for ii = 1:nargin
   inputnames{ii,1} = inputname(ii);  %#ok<AGROW>
end

%% Empty tsobj() on input

if isempty(varargin{1}.tind)
    out = varargin{2};
    return
end

%% Case 1

tsobj_now = varargin{1};
start_min = tsobj_now.range(1);
finish_max = tsobj_now.range(end);
freq = tsobj_now.frequency;
cols = size(tsobj_now.values,2);

names = tsobj_now.name;
technames = tsobj_now.techname;
if cols==1  && ~isempty(inputnames{1}) && isempty(technames{1}) % only 1st techname if cols==1
    technames = inputnames(1);%{inputnames{1}};  
end

%% Case 2+

empty_objs = [];
for ii = 2:length(varargin)
    tsobj_now = varargin{ii};
    
    % Check for emptiness
    if isempty(tsobj_now.tind)
        empty_objs = [empty_objs ii]; %#ok<AGROW>
        continue
    end

    % Frequency mismatch -> generate struct() 
    if ~strcmpi(freq,tsobj_now.frequency)
        generate_struct();
        return
    end
    
    if range2tind(start_min) > tsobj_now.tind(1) 
       start_min = tsobj_now.range(1); 
    end
    if range2tind(finish_max) < tsobj_now.tind(end) 
       finish_max = tsobj_now.range(end); 
    end

    cols_now = size(tsobj_now.values,2);
    cols = cols + cols_now;

    names = [names;tsobj_now.name]; %#ok<AGROW>
    technames = [technames;tsobj_now.techname]; %#ok<AGROW>
    if cols_now==1  && ~isempty(inputnames{ii}) && isempty(technames{end}) % Last techname relevant if cols_now==1
       technames(end) = inputnames(ii);
    end 

end

bounds = range2tind({start_min{:};finish_max{:}});
[tind,range] = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));
            
values = nan(length(tind),cols);
colpos = 1;

for ii = 1:nargin 
    if ~any(empty_objs==ii)
        tsobj_now = varargin{ii};
       %[~,where] = ismember(tsobj_now.tind,tind);
        where = ismembc2(tsobj_now.tind,tind);
        values(where,colpos:colpos+size(tsobj_now.values,2)-1) = tsobj_now.values;
        colpos = colpos + size(tsobj_now.values,2);
    end
end

%% Update
out = tsobj();
out.values = values;
out.tind = tind;
out.range = range;
out.frequency = freq;
out.name = names;
out.techname = technames;

% keyboard;

%% Support functions

    function generate_struct()
%         keyboard;
        counter = 0;
        fields = {};
        for jj = 1:length(varargin)
            tsobj_now = varargin{jj};
            if size(tsobj_now.values,2)==1
                if ~isempty(tsobj_now.techname{:})
                    new_field = tsobj_now.techname{:};
                    if counter > 0
                        if any(ismember(fields,new_field))
                            while true
                                new_field = [new_field '__dupl']; %#ok<AGROW>
                                if ~any(ismember(fields,new_field))
                                    break
                                end
                            end
                        end
                    end 
                    counter = inc(counter);
                    fields{counter,1} = new_field; %#ok<AGROW>
                    out.(new_field) = tsobj_now;
                elseif ~isempty(inputnames{jj})
                    out.(inputnames{jj}) = tsobj_now;
                    counter = inc(counter);
                    fields{counter,1} = inputnames{jj}; %#ok<AGROW>
                else
                    %out.(['aux_tsobj' sprintf('%.0f',jj)]) = tsobj_now;
                     out.(sprintf('aux_tsobj%d',jj)) = tsobj_now;
                end
            elseif size(tsobj_now.values,2)==0 % Empty object on input
                continue
            else
                aux_tsobj = explode(tsobj_now);% Duplicities resolved in explode()
                new_fields = fieldnames(aux_tsobj);
                old_fields = new_fields;
                if counter>0
                    duplicities = ismember(new_fields,fields);
                    if any(duplicities)
                        indices = find(duplicities);
                        for kk = indices(:)' % must be a row vector!
                           new_fields{kk} = [new_fields{kk} '__dupl']; 
                        end
                    end
                end

                for kk = 1:length(new_fields)
                    if ~isempty(new_fields{kk})
                        fields{counter+kk,1} = new_fields{kk}; %#ok<AGROW>
                        out.(new_fields{kk}) = aux_tsobj.(old_fields{kk});
                    else
                        out.(sprintf('aux_tsobj%d_%d',jj,kk)) = aux_tsobj.(new_fields{kk});
                    end
                end
                counter = inc(counter,length(new_fields));
            end
        end
        
        % Put stuff into a correct tscollection format
        out = implode(out);
        
    end %<generate_struct>

end %<eof>