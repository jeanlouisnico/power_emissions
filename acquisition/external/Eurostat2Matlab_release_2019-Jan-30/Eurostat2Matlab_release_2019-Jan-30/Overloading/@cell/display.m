function display(cellobj)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Char and cell objects supported only
chars = cellfun(@(x) isa(x,'char'),cellobj);
cells = cellfun(@(x) isa(x,'cell'),cellobj);
% structs = cellfun(@(x) isa(x,'struct'),cellobj);

content_check = all(chars(:)+cells(:));

%% Line by line loop
if size(cellobj,2)==1 && content_check
    fprintf(['\nCell object [' sprintf('%.0f',size(cellobj,1)) 'x1]\n\n']);
    cell_display_core(cellobj,1);
else
    fprintf('<Built-in call>\n');
%     builtin_call = cellobj;
    builtin('display',cellobj);
end

%% Subfunctions follow here

function cell_display_core(cellobj,level)
    dig = ceil(log10(length(cellobj)+1));
    zeropad = sprintf('%.0f',dig);
    for ii = 1:length(cellobj)
        if ischar(cellobj{ii})
            
            % Chars of more than 1 line cannot be processed with this function...
            try
                % fprintf() input/output compatibility
                cellobj{ii} = strrep(cellobj{ii},'\','\\');
                cellobj{ii} = strrep(cellobj{ii},'%','%%');
            catch
               builtin('display',cellobj);
               return
            end
            
            if ~isempty(cellobj{ii})
                if level==1
                    fprintf(['[CHAR #' ...
                        sprintf(['%0' zeropad '.f'],ii) ...
                                    ']: ''',cellobj{ii},'''\n']);
                elseif level==2
                    fprintf(['''' cellobj{ii},''' ']);
                else
                    fprintf(['''' cellobj{ii},''';']);
                end
            else
                if level==1
                    fprintf(['[CHAR #' ...
                        sprintf(['%0' zeropad '.f'],ii) ...
                                    ']: ''''\n']);
                elseif level==2
                    fprintf([''''' ']); %#ok<NBRAK>
                else
                    fprintf([''''';']); %#ok<NBRAK>
                end
            end
        elseif iscell(cellobj{ii})
            [r,c] = size(cellobj{ii});
            if level==1   
                fprintf(['[CELL #' ...
                     sprintf(['%0' zeropad '.f'],ii) ...
                                 ']: ']);
                if r==1
                    cell_display_core(cellobj{ii},2);
                elseif c==1
                    cell_display_core(cellobj{ii},3);
                else
                    fprintf(['[' sprintf('%.0f',r) 'x' sprintf('%.0f',c) ']\n']);
                end
            elseif level==2
                fprintf(['[' sprintf('%.0f',r) 'x' sprintf('%.0f',c) '] ']);
            else
                fprintf(['[' sprintf('%.0f',r) 'x' sprintf('%.0f',c) '];']);
            end
        else
            switch class(cellobj{ii})
                case 'struct'
                    c = length(fieldnames(cellobj{ii}));
                    if level==2
                        fprintf(['[struct ' sprintf('%.0f',c) 'x1] ']);
                    else
                        fprintf(['[struct ' sprintf('%.0f',c) 'x1];']);
                    end
                case 'tsobj'
                    now = cellobj{ii};
                    [r,c] = size(now.values);
                    if level==2
                        fprintf(['[tsobj ' sprintf('%.0f',r) 'x' sprintf('%.0f',c) '] ']);
                    else
                        fprintf(['[tsobj ' sprintf('%.0f',r) 'x' sprintf('%.0f',c) '];']);
                    end                    
                otherwise
                    if level==2
                        fprintf(['[' class(cellobj{ii}) '] ']);
                    else
                        fprintf(['[' class(cellobj{ii}) '];']);
                    end 
            end
        end
    end
    if level > 1
       fprintf('\n'); 
    end
end

end %<eof>