function this = QoQpa(this,varargin)
% 
% Calculates annualized quarter-on-quarter growth rate in percent for given tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

p = inputParser;

addRequired(p,'this');%, @isstruct || @(x) isa(x,'tsobj') || @iscell);

if dynammo.compatibility.isAddParameter
    addParameter(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));
else
    addParamValue(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));   
end

p.parse(this,varargin{:});
args = p.Results;

%% Body

if ~strcmpi(this.frequency,'Q')
   dynammo.error.tsobj(['Quarter-on-quarter calculations make sense ' ...
          'in case of quarterly time series only...']); 
end

name = this.name;
techname = this.techname;

% subsref() indication
subobj.type = '{}';
subobj.subs = {[-1]}; %#ok<NBRAK>

% [%] change
this = (this/subsref(this,subobj)-1)*400;
this.techname = techname;

if args.rename
    this.name = namechange_unary(name,'QoQpa');
    % this.techname = repmat_cellstr_empty(length(this.name));
end

end %<eof>