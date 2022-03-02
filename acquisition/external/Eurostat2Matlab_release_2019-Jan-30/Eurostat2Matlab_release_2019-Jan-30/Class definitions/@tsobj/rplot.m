function varargout = rplot(this,varargin)
% 
% Same as tsobj/plot except this function creates figures in invisible mode
% - useful when creating automated PDF reports
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Process options

args = varargin;

names = args(1:2:end);

% Reporting options
args = dynammo.options.plot_reporting(names,args);
    
%% Standard plot with changed default options

outstr = plot(this,args{:});

%% Output
if nargout==1
    varargout{1} = outstr;
else
    assignin('caller','gobj',outstr); 
end

end %<eof>
