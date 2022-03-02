function export(this,varargin)
%
% Export tsobj() into a text file (using a delimiter),
% or into a Excel spreadsheet
%
% INPUT: this ...tsobj()
%        [varargin] ...options (see below the list of available options)
%
% SEE ALSO: struct/export(), cell/export()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Deal options
args = dynammo.options.export(varargin{:});
if ~isstruct(args)
   error_msg('Options resolution','This usually happens if you do not enter the function options properly...'); 
end

%% All time series must have specified techname option

if any(cellfun('isempty',this.techname))
    error_msg('Data export error','Time series to export must have declared "techname" option (the space-free name of the variable)'); 
elseif length(unique(this.techname))~=length(this.techname)
    error_msg('Data export error','Time series to export must have uniquely defined "techname" option (the space-free names of the variables)'); 
end

%% Unlock file for writing
[isfile,args] = dynammo.export.fileUnlock(args);

%% Write data to file
if args.XLS_trigger
    xlswrite(this,args,isfile);
else
    csvwrite(this,args);
end

%% Read only property
dynammo.export.fileSetReadOnly(args);

%% Msg

if args.append
    disp(['File "' args.user_filename '" appended...']);
else
    disp(['File "' args.user_filename '" generated...']);
end

end %<eof>