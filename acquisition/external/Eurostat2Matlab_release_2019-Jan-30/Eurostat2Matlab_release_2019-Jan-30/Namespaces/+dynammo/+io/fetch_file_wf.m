function fetch_file_wf(origfile)
%
% Cloning driver files into the current working directory
%
% INPUT: origfile ...requested driver file 
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Cell call
% -> Fetch multiple files
if iscell(origfile)
   for ii = 1:length(origfile)
       dynammo.io.fetch_file_wf(origfile{ii});
   end
   return
   
end

%% Proper file extension
[~,~,ext] = fileparts(origfile);
if isempty(ext)
   % Mfile by default assumed
   origfile = [origfile '.m']; 
end

%% Replacing existing file
fileshere = dir(pwd);
fileshere = {fileshere.name};
fileshere = fileshere(:);

if any(ismember(origfile,fileshere))
   error_msg('File cloning','Requested driver file already exists in the current directory...'); 
end

%% Cloning step

trunk = which('wf.clone');
trunk = strrep(trunk,'clone.m','');

filenow = [trunk origfile];
clonefile = [pwd filesep origfile];
res = copyfile(filenow,clonefile);
if res~=1
    error_msg('File cloning','Cannot copy the requested driver file to current directory...'); 
end

%% Open file in editor
%if strcmpi(ext,'.m')
%    opentoline(clonefile,1,1);
%end

end %<eof>