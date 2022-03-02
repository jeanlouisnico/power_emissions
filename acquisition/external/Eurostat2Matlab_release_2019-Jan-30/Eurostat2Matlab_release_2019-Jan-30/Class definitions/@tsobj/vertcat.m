function varargout = vertcat(varargin) %#ok<STOUT>
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

dynammo.error.tsobj(['Vertical concatenation of time series is not allowed. Appending ' ...
             'more data into an existing tsobj() can be done by standard assignment. ' ...
             't{range} = values, where range can be outside original range bounds.']);

end