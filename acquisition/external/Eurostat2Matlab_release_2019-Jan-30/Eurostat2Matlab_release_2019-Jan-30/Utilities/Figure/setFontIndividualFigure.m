function setFontIndividualFigure(varargin)
%
% Sets font type & font size for all children of given figure
%
% INPUT: fighandle ...handle to a figure
%        size ...font size <scalar>
%        type ...font type <string>
% 
% OUTPUT: none
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

p = inputParser;

addRequired(p,'fighandle');

if dynammo.compatibility.isAddParameter

    addParameter(p,'size',0,@(x) isscalar(x) && isa(x,'double'));
    addParameter(p,'type','',@ischar);% Times, Helvetica
        
else
    addParamValue(p,'size',0,@(x) isscalar(x) && isa(x,'double'));
    addParamValue(p,'type','',@ischar);% Times, Helvetica
    
end

p.parse(varargin{:});
args = p.Results;

%% Body

if args.size>0
    set(findall(args.fighandle,'-property','FontSize'),'FontSize',args.size);
end

if ~isempty(args.type)
    set(findall(args.fighandle,'-property','FontName'),'FontName',args.type);
end

end %<eof>