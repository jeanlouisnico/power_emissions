function this = log(this,varargin)
%
% Logarithm function for tsobj()
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

values = this.values;
not_logable = ~(values>0);
if any(not_logable(:))
   if ~all(isnan(values(not_logable)))
       dynammo.warning.tsobj(['Taking log() of nonpositive values - result ' ...
                    'to be replaced by NaNs...']); 
   end
end
values = log(values);
values(not_logable) = NaN;

this.values = values;

if args.rename
    this.name = namechange_unary(this.name,'log');
    % this.techname = repmat_cellstr_empty(length(this.name));
end
    
end %<eof>