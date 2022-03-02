function n = numel(obj, varargin) %#ok<INUSD>
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% >>> M2015 way of doing this
% function n = numArgumentsFromSubscript(obj,~,indexingContext)
% %    switch indexingContext
% %       case matlab.mixin.util.IndexingContext.Statement
% %          n = ...; % nargout for indexed reference used as statement
% %       case matlab.mixin.util.IndexingContext.Expression
% %          n = ...; % nargout for indexed reference used as function argument
% %       case matlab.mixin.util.IndexingContext.Assignment
% %          n = ...; % nargin for indexed assignment
% %    end
% n = 1;
% end
% <<<
n = 1;

end