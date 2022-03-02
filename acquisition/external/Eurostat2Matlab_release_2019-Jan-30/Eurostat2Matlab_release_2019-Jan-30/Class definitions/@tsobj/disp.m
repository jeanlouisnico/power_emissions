function disp(in,varargin)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~isempty(varargin)
    display(in,varargin{1});
else
    display(in);
end

end %<eof>