function varargout = import_data(varargin)
%
% Options handling for import_data function
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% Just to make it possible to call this fcn manually to show the options system
if nargin==0
    filename = '';
else
    filename = varargin{1};
end

p = inputParser;
if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end

fcn(p,'delimiter',',',@(x) any(validatestring(x,{',',';',':','\t','","','\|'})));% Use "," if commas inside some fields
fcn(p,'maxrows',2e4,@(x) isa(x,'double'));
fcn(p,'addRows',5e3,@(x) isa(x,'double'));
fcn(p,'sheetname','',@ischar);% To go with XLS only
fcn(p,'range','',@ischar);% To go with XLS only
fcn(p,'filter',{''},@iscell);

p.parse(varargin{2:end});
args = p.Results;

args.filename = filename;

% keyboard;

%% Print options overview

if nargin==0 % overview of available options
    
    dynammo.options.args_overview(definition(args));
    
    if nargout>0
       varargout{1} = {}; 
    end
    return
    
end

%% Output file

if isempty(args.filename)
    error_msg('Data import','Output "filename" needs to be specified while importing data...');
end
dynammo.io.validate_sheetname(args.sheetname);

% Generate full path to the file
%args.user_filename = args.filename;
args.filename = FullFilePath(args.filename);

% Check for existence
if exist(args.filename,'file')==0
    error_msg('Data import','File not found...',args.filename);
end

% % File extension
% extlist = {'.xls';'.xlsb';'.xlsx';'.xlsm';'.txt';'.csv';'.tsv'};
% 
% [foldername, ...
%  args.file_nameonly, ...
%  args.myext] = fileparts(args.filename);
% 
% found_ext = strcmp(args.myext,extlist);
% if ~any(found_ext)
%    error_msg('Data export','Supported file extensions:',extlist);
% elseif strcmp(args.myext,'.tsv')
%     args.delimiter = '\t';% The name suggests this should always be tab delimited
% end
% 
% % Folder must exist
% if exist(foldername,'dir')~=7 % Already full path here
%     error_msg('Data export','Folder does not exist, create & try again:',args.filename);
% end
% 
% % XLS output options
% args.XLS_trigger = 0;
% if find(found_ext)<=4
%     if~ispc
%         error_msg('Data export','XLS export for time series objects is supported on Windows machines only :(...');
%     else
%         args.XLS_trigger = 1;
%         switch args.myext
%             case '.xls' %xlExcel8 or xlWorkbookNormal
%                args.xlFormat = -4143;
%             case '.xlsb' %xlExcel12
%                args.xlFormat = 50;
%             case '.xlsx' %xlOpenXMLWorkbook
%                args.xlFormat = 51;
%             case '.xlsm' %xlOpenXMLWorkbookMacroEnabled 
%                args.xlFormat = 52;
%         end
%     end
% end

if nargout==1
   varargout{1} = args; 
end

%% Support functions

    function res = definition(args)
        
    to_print = cell(0,0);
    to_print{1,1} = 'OPTION';
    to_print{1,2} = 'DEFAULT VALUE';
    to_print{1,3} = 'COMMENT';
    to_print{2,1} = '#=line#';
    
    to_print{end+1,1} = '#>>> DELIMITED INPUT ONLY <<<#';% Category name
   %to_print(end+1,:) = {'filename:',args.filename,'... string indicating file name, possibly with partial or absolute path'};
    to_print(end+1,:) = {'delimiter:',args.delimiter,'... '',''|'';''|'':''|''\t'' (tabulator)|''","'' (commas in comments allowed)|''\|'' (vertical bar) '};
    to_print(end+1,:) = {'maxrows:',args.maxrows,'... Matlab storage pre-allocation (maximum # of rows in a cell object, this gets expanded by ''addRows'' when the limit is hit)'};
    to_print(end+1,:) = {'addRows:',args.addRows,'... Extra space pre-allocation if size of pre-allocated cell object has been exceeded'};
    to_print(end+1,:) = {'filter:',args.filter,'... {col# ''==string''}, by default strcmpi() is used for assessment;'};
    to_print(end+1,:) = {'','',                '... {col# ''==string'' @fun} -> assessment done by a specific function (regexpi(), contains(), startsWith(),...)'};
    
    to_print{end+1,1} = '#>>> EXCEL OPTIONS <<<#';% Category name    
    to_print(end+1,:) = {'sheetname:',args.sheetname,'... Sheet name'};
    to_print(end+1,:) = {'range:',args.range,'... Range, e.g. ''A1:C10'' -> hint: dynammo.io.xlsColNum2Str() converts column # into a proper letter'};
    
    res.to_print = to_print;
    res.opt_call = 'dt = import_data(''myFile.csv''[,options]) -> file name may contain partial/absolute path';
    
    end %<definition>

end %<eof>