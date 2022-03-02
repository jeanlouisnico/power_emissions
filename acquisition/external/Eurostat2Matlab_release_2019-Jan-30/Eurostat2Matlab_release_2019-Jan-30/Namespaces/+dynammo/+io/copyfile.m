function copyfile(source,destination,varargin)
%
% File copying using system functions
% 
% INPUT: source and destination files (paths can be both absolute/relative)
%       [optional error message which apperas in case of failure]
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

source_orig = source;% can already contain full path :(
source      = FullFilePath(source);
destination = FullFilePath(destination);

%% Body
if ispc
   %flag = system(['copy "' source '" "'  destination '" 1>null']);% -> this creates null. file :( 
    flag = system(['copy "' source '" "'  destination '"']);% -> this prints the result into the command window :(
else
    flag = system(['cp -r "' source '" "' destination '"']);
end

%% Result
if flag~=0
   if nargin==2
       error_msg('I/O',['Cannot copy file"' source_orig '", check source/destination paths...']); 
   else
       error_msg('I/O',varargin{1}); 
   end
end

end %<eof>