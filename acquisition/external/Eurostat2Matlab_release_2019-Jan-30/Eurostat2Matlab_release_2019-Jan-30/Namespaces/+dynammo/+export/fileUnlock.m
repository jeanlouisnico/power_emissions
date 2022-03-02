function [isfile,args] = fileUnlock(args)
%
% Unlocks file for writing
%
% INPUT: args ...options set of dynammo.options.export()
%
% OUTPUT: isfile ...existence of the file in args.filename
%         args   ...altered options
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% Check for existence
isfile = exist(args.filename,'file') > 0;

%% Options resolution

% Appending
if ~isfile && args.append
    args.append = 0;
end

% File overwriting
if args.overwrite_sheet
    args.overwrite_file = 1;
end
if isfile && ~args.overwrite_file
    error_msg('Data export','The file already exists and option "overwrite_file" is turned OFF...',args.filename);
end

%% Unlock the file if in read-only status

% Allow all users to rewrite the file
if isfile
    try
        w = warning;
        warning('off','MATLAB:FILEATTRIB:SyntaxWarning');
        fileattrib(args.filename,'+w','a');
        warning(w);
    catch %#ok<CTCH>
        error_msg('Data export','Problem with the output file, cannot make unset the read-only property...',args.filename);
    end
end

end %<eof>