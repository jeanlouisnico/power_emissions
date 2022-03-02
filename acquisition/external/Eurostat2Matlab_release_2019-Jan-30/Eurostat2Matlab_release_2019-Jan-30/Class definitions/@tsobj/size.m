function varargout = size(this,varargin)
%
% Calculates the size of given tsobj()
%   - observations form the rows
%   - columns form individual time series in given tsobj() collection 
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Dimension
if nargin>1
    dim = varargin{1};
else
    dim = 1;
end

%% Body

if nargout<=1
    varargout{1} = size(this.values,dim);
elseif nargout==2
    [varargout{1}, varargout{2}] = size(this.values);
else
    dynammo.error.tsobj('size() function has at most 2 output values...');
end

end %<eof>