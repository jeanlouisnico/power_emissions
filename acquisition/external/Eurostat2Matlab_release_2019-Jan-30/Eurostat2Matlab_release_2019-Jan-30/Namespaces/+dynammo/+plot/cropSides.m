function cropSides(gobj,varargin)
%
% Manual cropping of left/right white space in figures
%
% INPUT: gobj ...graph object
%       [factor] ...by default 1/2 space cropped
%                   factor>1 will increase the white space
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if nargin==1
    factor = 0.5;
else
    factor = varargin{1};
    if factor<0
        error_msg('Cropping','Cropping factor must lie within the interval <0,1>');
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
    
    buf_ = pos(1)*factor;
    width_addOn = 2*(pos(1)-pos(1)*factor);
    pos(1) = buf_;
    pos(3) = pos(3) + width_addOn;%2*(1-factor);
    set(axs(ii),'Position',pos);
end

end %<eof>