function varargout = inc(in,varargin)
%
% Simple incrementor with a maximum limit
% 
% INPUT: in ...value to start from
%       [step] ...incremental step size
%       [max_] ...upper limit for incrementation
% 
% OUTPUT: out ...incremented value
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~isempty(varargin)
    step = varargin{1};
    if max(size(varargin))==2
        max_ = varargin{2};
    else
        max_ = 999999;
    end
else
    step = 1;
    max_ = 999999;
end
out = in+step;
if out>max_
    error_msg('Incrementation','Maximum incrementation reached...Increase preallocated dimension!');
end
if nargout==1
    varargout{1} = out;
else
    assignin('base',inputname(1),out);% 'base' 'caller' would not work in disp(inc(ii))
end
 
end
