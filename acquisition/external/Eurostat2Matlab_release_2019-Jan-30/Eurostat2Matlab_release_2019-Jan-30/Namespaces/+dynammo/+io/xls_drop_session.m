function xls_drop_session(obj,args,isfile)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

try
    if isfile
        % Save
        obj.Workbooks.Item(1).Save();
    else
        % Save this workbook we just created.
        obj.Workbooks.Item(1).SaveAs(args.filename, args.xlFormat);
    end
catch
    %obj.Visible = 1;
    obj.Quit();
    delete(obj);
    error_msg('XLS data export','Cannot save the file:',args.filename);
end

obj.Workbooks.Item(1).Saved = 1;% Not to prompt the user to have to click OK to save
obj.Workbooks.Item([args.file_nameonly args.myext]).Close();
    
obj.Quit(); % Application quits
delete(obj);% obj discarded


end %<eof>