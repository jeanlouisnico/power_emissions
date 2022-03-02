function export(in,varargin)
%
% Simple exporter of any kind of a cell object 
% (time series object exporter uses a different 
% overloaded export() function)
%
% INPUT: CELL object with general Matlab types in it (not time series objects)
%
% OUTPUT: none, data file generated instead
% 
% SEE ALSO: struct/export(), tsobj/export()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
args = dynammo.options.export(varargin{:});

%% Unlock file for writing
[isfile,args] = dynammo.export.fileUnlock(args);

%% Only proper value char/numeric scalar values retained
% this section is needed here, tsobj() always makes sure the values make sense

indchar = cellfun(@ischar,in);
if any(~indchar(:))
    for ic = 1:size(in,2)
        innow = in(:,ic);
        indcharnow = indchar(:,ic);
        where = find(~indcharnow);
        for iwhere = 1:length(where)
            to_test = innow{where(iwhere)};
            if isa(to_test,'double') && isscalar(to_test)
                innow{where(iwhere)} = sprintf('%g',to_test);
            else
                innow{where(iwhere)} = 'Some value...';
            end
        end
        in(:,ic) = innow;
    end
end

%% Write data to file
if args.XLS_trigger    
    xlswrite_cell(in,args,isfile);
else
    csvwrite_cell(in,args);
end

%% Read only property
dynammo.export.fileSetReadOnly(args);

%% Msg
if args.append
    disp(['File "' args.user_filename '" appended...']);
else
    disp(['File "' args.user_filename '" generated...']);
end

%% Support functions

    function xlswrite_cell(to_store,args,isfile)
        
        % File/sheet preparation (Excel interface)
        [obj,appendType] = dynammo.io.xls_new_session_cell(args,isfile);
        sht = obj.ActiveSheet;
        
        if args.append && strcmp(appendType,'values') % Data get appended to existing sheet after already existing data
        
            % Here we assume that the first 'A' column is always occupied
           %last_occupied_row = sht.Range('A1').End('xlDown').Row;
            rangeparts = regexp(sht.UsedRange.Address,'\$','split');
            last_occupied_row = eval(rangeparts{end});

            % Paste values to prepared usersheet
            append_area = ['a' sprintf('%g',last_occupied_row+1) ':' ...
                           dynammo.io.xlsColNum2Str(size(to_store,2)) sprintf('%g',last_occupied_row+size(to_store,1))];
            sht.Range(append_area).Value = to_store;          
     
        else
            
            % if args.append && strcmp(appendType,'new_sheet') 
            %             -> Sheet did not exist (is now created and is empty), so we put the data to the beginning
            % this branch works also for 'append'==0
            
            % Paste values to prepared usersheet
            sht.Range(['a1:' dynammo.io.xlsColNum2Str(size(to_store,2)) sprintf('%.0f',size(to_store,1))]).Value = to_store;
        
        end
        
        % Freeze panes option
        % ...here does not make sense

        % Automatic column width
        if args.autoWidth
            col_area = ['a:' dynammo.io.xlsColNum2Str(sht.Range('A1').End('xlToRight').Column)]; %dynammo.io.xlsColNum2Str(size(to_store,2))];
            sht.Range(col_area).cells.EntireColumn.AutoFit(); % Autofit column to contents
        end

        sht.Range('a1').Select;

        % Save the file and quit
        dynammo.io.xls_drop_session(obj,args,isfile);
        
    end %<xlswrite_cell>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function csvwrite_cell(in,args)
        
        d = args.delimiter;

        % File prep
        if args.append
            fID = fopen(args.filename,'a');% fclose('all')
        else
            fID = fopen(args.filename,'w');
        end
        
%         keyboard;
        
        % if cannot open the file
        if fID == -1
            error_msg('Data export',['Cannot open the file for writing. Running ' ...
                                     'the command fclose(''all'') might help.'],args.filename);
        end
        
        % New line if data is to be appended
        % -> needed in pure .txt
        if args.append && ~args.CSV_trigger % captures .tsv as well
            fprintf(fID,'\n');
        end
        
        % File filling (line by line)
        [r,c] = size(in);
        for iline = 1:r
            for icol = 1:c
                
                % Delimiter
                if icol~=1
                    if strcmp(d,'\t')
                        fprintf(fID,'\t');
                    else
                        fprintf(fID,'%s',d);
                    end
                end
                
                % Value
                todo = in{iline,icol};
                if ischar(todo)
                    pattern = '%s';
                elseif iscell(todo)
                    [d1,d2] = size(todo);
                    pattern = '%s';
                    todo = ['[CELL ' sprintf('%.0f',d1) 'x' sprintf('%.0f',d2) ']'];
                elseif isa(todo,'double')
                    if isscalar(todo)
                        pattern = ['%.' sprintf('%.0f',args.precision) 'f'];
                    else
                        pattern = '%s';
                        [d1,d2] = size(todo);
                        todo = ['[MAT ' sprintf('%.0f',d1) 'x' sprintf('%.0f',d2) ']'];
                    end
                else
                    pattern = '%s';
                    todo = 'Some values...';
                end
                
                % Print step
                fprintf(fID,pattern,todo);
            end
            
            % End of line char
            % -> .txt need end of line character as a line break (not after last line)
            % -> delimited files need end of line character even after the last line
            if iline~=r || args.CSV_trigger
                fprintf(fID,'\n');
            end
        end
      
        status = fclose(fID);

        % if cannot close the file
        if status~=0
            warning_msg('Data export','Closing the file after writing unsuccessful:',args.filename);    
        end   
        
    end %<csvwrite_cell>

end %<eof>