function display(numobj,varargin)
%
% Internal file: no help provided
%
% Test matrix: [randn(4,5);nan nan nan nan -Inf;zeros(1,5);1e-12 -1e-12 150 -1e-8 nan].'
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if nargin>1
    digits_to_print = varargin{1};
else
    digits_to_print = 8;
end

%% Stack control
% st = dbstack();
% keyboard;

%% Complex numbers
if ~isreal(numobj) || ...
  issparse(numobj) || ...
   isempty(numobj) %|| ...
    % (size(numobj,1)==1 && (max(abs(log10(numobj(:))))- ... 
    %                        min(abs(log10(numobj(:)))))<5)    
    fprintf('\n');
    if nargin>1 && ischar(varargin{1})
        builtin('display',numobj,varargin{:});
    else
        builtin('display',numobj); 
    end
    return
end

%% Real matrices
fprintf('\n');
fprintf(' [double %gx%g]',size(numobj)); 
fprintf('\n');
more_digits(numobj,digits_to_print);

end %<eof>