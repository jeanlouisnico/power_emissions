function writeFile(f,outfile,varargin)
%
% Saves given string (or cell of strings) into a file (potentially using UTF-8 encoding)
%
% INPUT: f         ...string/cell of strings to be written into a file
%        outfile   ...output file save name
%       [encoding] ...unicode strings usually need 'utf-8' flag

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
if nargin==3
    % Encoding specified
    fid = fopen(FullFilePath(outfile),'w+','n',lower(varargin{1}));
else
    fid = fopen(FullFilePath(outfile),'w+');
end

if fid==-1
   error_msg('File I/O','Cannot open file for writing:',FullFilePath(outfile));
end

if iscellstr(f)
    f = f(:).';
    fprintf(fid,'%s',f{:});
elseif ischar(f)
    fprintf(fid,f);
else
    fclose(fid);
    error_msg('File I/O',['Strings and cells of strings are the only Matlab types ' ...
                          'that can be saved into a file using UTF-8 encoding. ' ...
                          'Current input type:'],class(f));
end

fclose(fid);

end %<eof>