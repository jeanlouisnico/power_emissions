function varargout = trimNaNs(varargin) %#ok<STOUT>
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

error_msg('Syntax',['Function trimNaNs() cannot be applied to Matlab structures. ' ...
                    'Use trim(structin,range) instead. If range is specified, all individual time series objects ' ...
                    'will be trimmed using trimNaNs() internally. Using trim(structin), i.e. without range specification, will ' ...
                    'throw away leading/trailing NaNs from all time series contained']);

end %<eof>