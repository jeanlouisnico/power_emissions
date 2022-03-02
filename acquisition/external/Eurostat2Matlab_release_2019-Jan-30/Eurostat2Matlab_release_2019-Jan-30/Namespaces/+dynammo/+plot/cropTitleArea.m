function cropTitleArea(gobj,varargin)
%
% Manual cropping of top white space in figures
%
% INPUT: gobj ...graph object
%       [factor] ...by default 30% space cropped
%                   factor>1 will increase the white space
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if nargin==1
    factor = 0.3;
else
    factor = varargin{1};
    if factor<0
        error_msg('Cropping','Cropping factor must be >= 0');
    end
end

%% All axes objs
gobj = dynammo.plot.gobj_transform(gobj);
axs = findobj(gobj.fig1.handle,'type','axes');

%% Do not count legend (legendflex() results in axes object)
isLeg = strcmpi(get(axs,'Tag'),'legend');
if any(isLeg)
   axs = axs(~isLeg); 
end

%% Body
for ii = 1:length(axs)
    pos = get(axs(ii),'Position');
    pos(4) = (1-(1-pos(2)-pos(4))*factor)-pos(2);
    set(axs(ii),'Position',pos);
end

end %<eof>