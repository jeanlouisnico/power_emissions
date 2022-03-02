function [han,nfigs] = getHandle(fighandle)
%
% Get figure handle out of whatever input format
% (works also on regular Matlab figures)
%
% INPUT: ...reference to a figure in whatever format (gobj/handle)
%
% OUTPUT: han... cell of numeric figure handles
%
% SUGGESTED USE:
%                 [han,nfigs] = dynammo.plot.getHandle(fighandle);
%                 if nfigs>1
%                     error_msg('SVG export','Multiple input figures should be processed one by one...');
%                 else
%                     han = han{1};
%                 end
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

if isstruct(fighandle)
    if isfield(fighandle,'fig1')
        f = fieldnames(fighandle);
        nf = length(f);
        han = cell(nf,1);
        for ii = 1:nf
            han{ii} = fighandle.(['fig' sprintf('%g',ii)]).handle;
        end
        nfigs = nf;
        return
        
    else %if isfield(fighandle,'fig')
        han = {fighandle.fig};
    end
else % Regular Matlab figure
    if dynammo.compatibility.newGraphics
        if isa(fighandle,'double')
            han = {fighandle};
        else
            han = {fighandle.Number};
        end
    else
        han = {fighandle};
    end
end

nfigs = 1;
 
end %<eof>