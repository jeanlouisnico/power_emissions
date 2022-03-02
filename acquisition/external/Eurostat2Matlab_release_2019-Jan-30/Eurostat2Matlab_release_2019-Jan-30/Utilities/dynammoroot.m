function path = dynammoroot()
%
% Similar to matlabroot() - gets the trunk directory of the Project Dyn:Ammo files
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

path = which('dynammoroot.m');
path = fileparts(path);
if ispc
    path = regexprep(path,'\\Utilities$','');%strrep(path,[filesep 'Utilities'],'');
else
    path = regexprep(path,'/Utilities$','');
end

end %<eof>