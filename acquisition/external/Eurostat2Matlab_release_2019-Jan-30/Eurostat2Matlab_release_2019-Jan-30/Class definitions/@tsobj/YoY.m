function this = YoY(this,varargin)
% 
% Calculates year-on-year growth rate in percent for given tsobj()
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

% keyboard;

%% Body

% subsref() indication
switch upper(this.frequency)
    case 'M'
        subobj.type = '{}';
        subobj.subs = {[-12]}; %#ok<NBRAK>        
    case 'Q'
        subobj.type = '{}';
        subobj.subs = {[-4]}; %#ok<NBRAK>        
    case 'Y'
        subobj.type = '{}';
        subobj.subs = {[-1]}; %#ok<NBRAK>
    case 'D'
        dynammo.error.tsobj('You must first convert daily data into Y/Q/M frequency...');
    otherwise
        disp('||| Dead end, this should never happen...');
        keyboard;
end

name = this.name;
techname = this.techname;

% [%] change
this = (this/subsref(this,subobj)-1)*100;
this.techname = techname;

if args.rename
    this.name = namechange_unary(name,'YoY');
else
    this.name = name;
end
%this.techname = repmat_cellstr_empty(length(this.name));

end %<eof>