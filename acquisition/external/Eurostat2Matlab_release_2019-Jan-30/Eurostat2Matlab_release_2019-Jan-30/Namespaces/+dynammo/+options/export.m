function varargout = export(varargin)
%
% Options handling for general export() function
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if nargin==1 && isstruct(varargin{1}) % options already processed in struct
    if nargout == 1
        varargout{1} = varargin{1};
    end
    return
end   

p = inputParser;
if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end

fcn(p,'filename','',@ischar);
fcn(p,'append',0,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'setReadOnly',1,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'overwrite_file',1,@(x) isscalar(x) && isa(x,'double'));

% Delimited file as output
fcn(p,'delimiter',',',@(x) any(validatestring(x,{',',';',':','\t','\|'})));
fcn(p,'precision',14,@(x) isscalar(x) && isa(x,'double'));    

% Excel options
fcn(p,'sheetname','',@ischar);% to make it different from Sheet1
fcn(p,'overwrite_sheet',1,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'freezePanes',1,@(x) isscalar(x) && isa(x,'double'));
fcn(p,'autoWidth',1,@(x) isscalar(x) && isa(x,'double'));

% Debugging mode
fcn(p,'debug',0,@(x) isscalar(x) && isa(x,'double'));

p.parse(varargin{:});
args = p.Results;

% keyboard;

%% Print options overview
if nargin==0 % overview of available options
    %execute = 0;
 
    dynammo.options.args_overview(definition(args));
    %args = 'Option set for general export function';
    return
end

%% Validation of 0/1 switches

% Make sure the options have 0/1 inputs only
if ~any(args.setReadOnly==[0;1])
   error_msg('Data export error','"setReadOnly" option expects 0/1 values on input only...',args.readonly); 
end
if ~any(args.overwrite_file==[0;1])
   error_msg('Data export error','"overwrite_file" option expects 0/1 values on input only...',args.overwrite_file); 
end
if ~any(args.append==[0;1])
   error_msg('Data export error','"append" option expects 0/1 values on input only...',args.append); 
end

%% Output file

if isempty(args.filename)
    error_msg('Data export','Output "filename" needs to be specified while exporting data...');
end

% Generate full path to the file
args.user_filename = args.filename;
args.filename = FullFilePath(args.filename);

% File extension
extlist = {'.xls';'.xlsb';'.xlsx';'.xlsm'};%;'.txt';'.csv';'.tsv'};% Do not alter the list, the ordering has dependencies

[foldername, ...
 args.file_nameonly, ...
 args.myext] = fileparts(args.filename);

found_XLSext = strcmpi(args.myext,extlist);
% if ~any(found_XLSext)
   %error_msg('Data export','Supported file extensions:',extlist);
if strcmp(args.myext,'.tsv')
    args.delimiter = '\t';% The name suggests this should always be tab delimited
end

% Folder must exist
if exist(foldername,'dir')~=7 % Already full path here
    error_msg('Data export','Folder does not exist, create & try again:',args.filename);
end

% XLS output options
args.XLS_trigger = 0;
if any(found_XLSext)
    if~ispc
        error_msg('Data export','XLS export for time series objects is supported on Windows machines only :(...');
    else
        args.XLS_trigger = 1;
        switch args.myext
            case '.xls' %xlExcel8 or xlWorkbookNormal
               args.xlFormat = -4143;
            case '.xlsb' %xlExcel12
               args.xlFormat = 50;
            case '.xlsx' %xlOpenXMLWorkbook
               args.xlFormat = 51;
            case '.xlsm' %xlOpenXMLWorkbookMacroEnabled 
               args.xlFormat = 52;
        end
    end
end

if args.XLS_trigger
    
    if ~any(args.overwrite_sheet==[0;1])
       error_msg('Data export error','File "overwrite_sheet" option expects 0/1 values on input only...',args.overwrite_sheet); 
    end

    % No spaces and special chars in the sheet name
    dynammo.io.validate_sheetname(args.sheetname);
    %if ~isempty(regexp(args.sheetname,'[^\w*]','once')) % Special characters in sheet name not allowed
    %    testname = args.sheetname(~isspace(args.sheetname)); % Spaces ARE allowed
    %    if ~isempty(regexp(testname,'[^\w*]','once'))
    %        error_msg('Data data export','Sheet name must not contain spaces or special characters:',usersheet);
    %    end
    %end
    
    if ~any(args.freezePanes==[0;1])
       error_msg('Data export error','File "freezePanes" option expects 0/1 values on input only...',args.freezePanes); 
    end
    
end

% CSV output options
args.CSV_trigger = 0;
if any(strcmpi(args.myext,{'.tsv';'.csv'}))
    args.CSV_trigger = 1;
    % We do not want .txt files to go with this trigger
end
    
% if strcmp(args.sheetname,'Sheet_1') && args.append==1
%     clocknow = clock();
%     args.sheetname = ['Sheet_1_' sprintf('%.0f',clocknow(4)) 'h' ...
%                                  sprintf('%.0f',clocknow(5)) 'm' ...
%                                  sprintf('%.0f',clocknow(6)) 's'];
% end

if nargout==1
   varargout{1} = args; 
end

%% Digit precision for text output
if args.XLS_trigger==0
   if floor(args.precision)~=args.precision
      error_msg('Data export','Digit precision must be integer:',args.precision) 
   end
end

%% Support functions

    function res = definition(args)
        
    to_print = cell(0,0);
    to_print{1,1} = 'OPTION';
    to_print{1,2} = 'DEFAULT VALUE';
    to_print{1,3} = 'COMMENT';
    to_print{2,1} = '#=line#';

    to_print(end+1,:) = {'filename:',args.filename,'... string indicating file name, possibly with partial or absolute path'};
    to_print(end+1,:) = {'append:',args.append,'... 1|0 switch; Data can be appended to an existing file'};
    to_print(end+1,:) = {'','',                '     (sheet to XLS, values to CSV/existing XLS sheet, not applicable if tsobj->CSV)'};
    to_print(end+1,:) = {'setReadOnly:',args.setReadOnly,'... 1|0 switch to make the output read-only'};
    to_print(end+1,:) = {'overwrite_file:',args.overwrite_file,'... 1|0 switch to allow/ban overwriting of an existing file;'};
    to_print(end+1,:) = {'','',                                '    turning off this option prevents manipulation of already existing file'};
    
    to_print{end+1,1} = '#>>> XLS OUTPUT FILE <<<#';% Category name
    to_print(end+1,:) = {'sheetname:',args.sheetname,'... any string free of special characters, spaces allowed'};
    to_print(end+1,:) = {'','',                      '    non-empty ''sheetname'' in conjunction with ''append''=true appends data to existing sheet,'};
    to_print(end+1,:) = {'','',                      '        empty ''sheetname'' in conjunction with ''append''=true appends data as a newly created sheet'};
    to_print(end+1,:) = {'overwrite_sheet:',args.overwrite_sheet,'... 1|0 switch to allow for sheet overwriting'};
    to_print(end+1,:) = {'freezePanes:',args.freezePanes,'... 1|0 switch to apply useful XLS property (applicable to time series output only)'};
    to_print(end+1,:) = {'autoWidth:',args.autoWidth,'... 1|0 switch to automatically adjust the column width'};

    to_print{end+1,1} = '#>>> non-XLS OUTPUT FILE <<<#';% Category name
    to_print(end+1,:) = {'delimiter:',args.delimiter,'... '',''|'';''|'':''|''\t''|''\|'''};
    to_print(end+1,:) = {'precision:',args.precision,'... number of digits to keep in the output'};

    to_print{end+1,1} = '#>>> DEBUGGING <<<#';% Category name
    to_print(end+1,:) = {'debug:',args.debug,'... 1|0 switch to allow activate the debugging mode (useful if something bad happens)'};

    res.to_print = to_print;
    res.opt_call = 'export(data,''filename'',''myFile.csv'',options)  -> file name may contain partial/absolute path';
    
    end %<definition>

end %<eof>