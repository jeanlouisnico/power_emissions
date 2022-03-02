function this = sin(this,varargin)
%
% Sine function for tsobj()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

p = inputParser;

addRequired(p,'this');%, @isstruct || @(x) isa(x,'tsobj') || @iscell);
 
if dynammo.compatibility.isAddParameter
    addParameter(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));
else
    addParamValue(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));
end

p.parse(this,varargin{:});
args = p.Results;

% keyboard;

%% Body
this.values = sin(this.values);

if args.rename
    this.name = namechange_unary(this.name,'sin');
    % this.techname = repmat_cellstr_empty(length(this.name));
end

end %<eof>