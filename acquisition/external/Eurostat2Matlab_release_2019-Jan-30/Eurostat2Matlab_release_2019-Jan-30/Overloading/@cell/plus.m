function varargout = plus(varargin)
%
% Use1: DB comparison for multiple databases
%       d1+d2+d3 will first process d1+d2 via struct/plus
%       then d3 is appended to the previous result, which is now a cell
% 
% Use2: Cell of strings augmentation
%       {'a';'b'} + 'c' should yield {'a';'b';'c'}
%       Uniqueness is not checked!       
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;%

cellin = varargin{1};
structobj = varargin{2};

if ~isstruct(structobj)
    if ischar(varargin{1}) && iscell(varargin{2})
        varargout{1} = [varargin(1);varargin{2}];
    elseif ischar(varargin{2}) && iscell(varargin{1})
        varargout{1} = [varargin{1};varargin(2)];% just a swap of {} ()
    elseif iscellstr(varargin{1}) && isa(varargin{2},'double')
        % Cell range shift by a scalar
        varargout{1} = cellfun(@(x) x+varargin{2},varargin{1},'UniformOutput',false);
    else
        varargout{:} = builtin('plus',varargin{:});
    end
    
    return % Important!
    
end

%% DB comparison

struct_to_compare = cellin{1};% Take the first as guinea pig
cell_inter = struct_to_compare + structobj;% Using struct/plus call
varargout{1} = [cellin; cell_inter{2}];% Append converted cell

end %<eof>