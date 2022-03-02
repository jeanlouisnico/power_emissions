function fileSetReadOnly(args)
%
% If the user requested so, the file will be left in a read-only status
%
% INPUT: args ...options set from dynammo.options.export()
%
% OUTPUT: none
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Read only property

w = warning;
warning('off','MATLAB:FILEATTRIB:SyntaxWarning');
if args.setReadOnly
    % Activate read only mode
    fileattrib(args.filename,'-w','a');
else
    % Allow all users to rewrite the file
    fileattrib(args.filename,'+w','a');
end
warning(w);

end %<eof>