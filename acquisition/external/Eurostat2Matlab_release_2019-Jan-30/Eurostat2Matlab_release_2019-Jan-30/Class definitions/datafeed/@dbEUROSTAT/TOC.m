function out = TOC(this,varargin)
%
% Fetches the table of contents for dbEUROSTAT() object
%   - to download the ToC can be costly in terms of time,
%     therefore it is stored locally inside Project folder
%   - user can always instruct to re-download a fresh version
%     of the ToC using the option 'refresh'==1
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%...

% keyboard;

%% Parsing the inputs

p = inputParser;

addRequired(p,'this');%, @isstruct || @(x) isa(x,'tsobj') || @iscell);

if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end

fcn(p,'refresh',0,@(x) isscalar(x) && isa(x,'double'));

% EUROSTAT options
fcn(p,'language','en',@(x) any(validatestring(x,{'en';'fr';'de'})));
% fcn(p,'subtree',{'data'}); % Validation is source specific (below)

p.parse(this,varargin{:});
args = p.Results;

%% TOC generator

out = EUROSTATtoc(this,args);

end %<eof>