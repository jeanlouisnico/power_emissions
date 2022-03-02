function varargout = plot(cellobj,varargin)
% 
% CELL plotting to be used for DB comparison only, tscollections not allowed
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Deal options

args = dynammo.options.plot(cellobj,varargin{:});
args.aux_input = true;% Stack control

%% Legend must be user-supplied
if isempty(args.legend)
    nDBs = size(cellobj,1);
    args.legend = strcat('DB',sprintfc(' %g',(1:nDBs).'));
%     for ii = 1:nDBs
%         if ii==1
%            args.legend = {'DB 1'}; 
%         else
%            args.legend = [args.legend; ['DB ' sprintf('%.0f',ii)]]; 
%         end
%     end
end

%% tsobj/plot call

% Note: - Missing data are already balanced with NaNs, no need to do pre-processing here
%       - In case of a name mismatch, the dictionary should be used prior to calling the plot function
outstr = plot(tsobj(),'aux_input',cellobj, ...
                      'aux_options',args);

%% Output

if nargout==1
    varargout{1} = outstr;
else
    assignin('caller','gobj',outstr); 
end

end %<eof>