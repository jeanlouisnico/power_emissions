function this = QoQ(this,varargin)
% 
% Calculates quarter-on-quarter growth rate in percent for given tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

p = inputParser;

addRequired(p,'this');%, @isstruct || @(x) isa(x,'tsobj') || @iscell);

% mat_ver = ver('MATLAB');
% if str2double(mat_ver.Version) > 8 % Matlab 2012 and later   
if dynammo.compatibility.isAddParameter
    addParameter(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));
else
    addParamValue(p,'rename',1,@(x) isscalar(x) && isa(x,'double') || isa(x,'logical'));
end

p.parse(this,varargin{:});
args = p.Results;

% keyboard;

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
this = (this/subsref(this,subobj)-1)*100;
this.techname = techname;

if args.rename
    this.name = namechange_unary(name,'QoQ');
else
    this.name = name;
end
%this.techname = repmat_cellstr_empty(length(this.name));

end %<eof>