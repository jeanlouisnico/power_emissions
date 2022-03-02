function varargout = call(pathfcn,varargin) %#ok<STOUT>
%
% Runs function from specific path
% 
% INPUT: pathfcn   ...absolute path to the requested function
%       [optional] ...function arguments
%
% OUTPUT: function output, if any
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Path navigation
startDir = cd();
cleaner = onCleanup(@() cd(startDir));

%% Body
[newpath,fcn] = fileparts(pathfcn);

cd(newpath);

if nargout==0
    feval(fcn,varargin{:});
else
    outargs = strcat('varargout{',sprintfc('%g',(1:nargout).'),'}');
    outargs = ['[' strjoin2(outargs,',') ']'];
    eval([outargs ' = feval(fcn,varargin{:});']);
    
end

delete(cleaner);

end %<eof>