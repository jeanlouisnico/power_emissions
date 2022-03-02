function f = readFile(infile,varargin)
%
% Imports given text file (potentially using encoding specification)
%
% INPUT: infile    ...text file name
%       [encoding] ...unicode files usually need 'utf-8' flag
% 
% OUTPUT: f ...file contents as string
% 
% SEE ALSO: import_data()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

if nargin==2
    % Encoding specified
    fid = fopen(FullFilePath(infile),'r','n',lower(varargin{1}));
else
    fid = fopen(FullFilePath(infile),'r');
end

if fid==-1
   error_msg('File I/O','Cannot open file for reading:',FullFilePath(infile));
end

f = fread(fid,'*char')';
fclose(fid);

end %<eof>