function [obj,appendType] = xls_new_session_cell(args,isfile)
%
% Internal file: no help provided
% 
% OPTIONAL OUTPUT: appendType ...flag indicating whether the requested sheet name already existed before this function call
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

appendType = 'new_sheet';

%% Append option
% if ~isfield(args,'append_values_to_sheet')
%     args.append_values_to_sheet = 0;
% end

%% Body

obj = actxserver('Excel.Application');

if args.debug
    obj.Visible = 1;
    keyboard;
else
    obj.Visible = 0;
end

obj.DisplayAlerts = 0; % Avoid excel warning popups

if isfile % [1] >>> File exists <<<

    % Open existing file <file was previously unlocked for writing>
    obj.Workbooks.Open(args.filename,  ...% Full path provided by the user
                       false,          ...% updatelinks=false 
                       false);            % readonly = false 
                                          %  ...didn't work sometimes if the file was open!
         
    if obj.Workbooks.Item([args.file_nameonly args.myext]).ReadOnly
        %obj.Visible = 1;
        obj.Quit();
        delete(obj);
        error_msg('XLS data export',['The Excel file is in read-only status, you ' ...
                                     'probably have it open, close and re-try again. It ' ...
                                     'is also possible that some program blocks the file, why don''t ' ...
                                     'you go with a different file name...'],args.filename);
    end
    
    wb = obj.Worksheets;
    
    % Get the sheet list
    sheetlist = dynammo.io.xls_allAvailableSheets(obj);
    
    % Change default (empty) sheet name to something meaningful
    if isempty(args.sheetname)    
        if args.append
            % Data will be appended as a new sheet
            clocknow = clock();
            args.sheetname = ['Sheet_1_' sprintf('%.0f',clocknow(4)) 'h' ...
                                         sprintf('%.0f',clocknow(5)) 'm' ...
                                         sprintf('%.0f',clocknow(6)) 's'];
        else
            % First sheet will be rewritten (depending on args.overwrite_sheet flag)
            args.sheetname = sheetlist{1}; 
        end
        
        % Check existence of requested sheet
        [~,where] = ismember(args.sheetname,sheetlist);        
        
    else
        
        % Check existence of requested sheet
        [~,where] = ismember(args.sheetname,sheetlist);  
        if where>0
            appendType = 'values';
        end
        
    end
    
    if where>0
        
        if args.overwrite_sheet
            
            wb.Item(where).Activate;
            
            if strcmp(appendType,'new_sheet')
                
                % Delete all contents from sheet
                wb.Item(where).Cells.Clear;
            
                % Only the new sheet will remain in the file
                if ~args.append 
                    for isheet = length(sheetlist):-1:1
                        if isheet~=where
                            wb.Item(isheet).Delete;
                        end
                    end
                end
                
            else
                % append values to existing sheet after existing data
                % i.e. do not clear contents of current sheet, leave existing sheets untouched
            end
            
        else
            %obj.Visible = 1;
            obj.Quit();
            delete(obj);
            error_msg('XLS data export',['Sheet with the same name already exists ' ...
                         'in the workbook and option "overwrite_sheet" is turned OFF...'],args.sheetname);             
        end
        
    else % args.sheetname is always non-empty!
        
        % Add one sheet
        count_before = wb.Count;
        wb.Add([],wb.Item(count_before),1);

        % Rename the new sheet
        wb.Item(count_before+1).Name = args.sheetname;

        % Only the new sheet will remain in the file
        if ~args.append 
            for isheet = count_before:-1:1
                wb.Item(isheet).Delete;
            end
        end

        wb.Item(args.sheetname).Activate;%count_before+1
            
    end
  
else % [1] >>> Create new file <<<

    % New workbook
    wb = obj.workbooks.Add;
    
    % Get the sheet list
    sheetlist = dynammo.io.xls_allAvailableSheets(obj);
    
    % By default we take the first sheet, if not specified by the user
    if isempty(args.sheetname)
        args.sheetname = sheetlist{1};
    end
    
    [~,where] = ismember(args.sheetname,sheetlist);
    if where > 0
        
        wb.worksheets.Item(where).Activate;
        
        % Delete all contents from sheet
        wb.worksheets.Item(where).Cells.Clear;
        
        % Delete the rest of sheets
        for isheet = wb.worksheets.Count:-1:1
            if isheet~=where
                wb.worksheets.Item(isheet).Delete;
            end
        end
        
    else
        % Add one sheet
        count_before = wb.worksheets.Count;
        wb.worksheets.Add([],wb.worksheets.Item(count_before),1);
        
        % Rename the new sheet
        wb.worksheets.Item(count_before+1).Name = args.sheetname;
        
        % Delete all automatically generated sheets
        for isheet = count_before:-1:1
            wb.worksheets.Item(isheet).Delete;
        end
        
        wb.worksheets.Item(args.sheetname).Activate;%count_before+1
        
    end
  
end

end %<eof>