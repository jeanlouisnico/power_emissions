function xlswrite(this,args,isfile)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% File/sheet preparation (Excel interface)
obj = dynammo.io.xls_new_session(args,isfile);

%% Paste values to prepared usersheet

if strcmpi(this.frequency,'d')
    to_store = strcat('''',this.range); 
else
    to_store = this.range;
end
to_store = [to_store num2cell(this.values)];
techname_line = ['aux' this.techname'];
techname_line{1} = '';% Perhaps '''''' would solve this redundant step
to_store = [techname_line;['comment' this.name'];to_store];

paste_area = ['a1:' dynammo.io.xlsColNum2Str(size(to_store,2)) sprintf('%.0f',size(to_store,1))];

sht = obj.ActiveSheet;
sht.Range(paste_area).Value = to_store;

% Freeze panes option
if args.freezePanes
    sht.Range('b3').Select;
    obj.ActiveWindow.FreezePanes = 1;
end

% Automatic column width
if args.autoWidth
    col_area = ['a:' dynammo.io.xlsColNum2Str(size(to_store,2))];
    sht.Range(col_area).cells.EntireColumn.AutoFit(); % Autofit column to contents
end

sht.Range('a1').Select;

%% Save the file and quit
dynammo.io.xls_drop_session(obj,args,isfile);


end %<eof>