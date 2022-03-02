function legendSpace(gobj,varargin)
%
% Creates some space for horizontal legend below graph
%
% INPUT: gobj ...graph object
%       [factor] ...by default extra 50% space plugged
%                   factor>1 will increase the white space
%       space = 'intra'/'extra' -> legend space can eat the space for graph,
%                                  or new stripe can be appended to the figure
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Deal margins
p = inputParser;
addRequired(p,'gobj');
addOptional(p,'factor',1.5);

if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end
fcn(p,'space','intra',@(x) any(strcmpi(x,{'intra','extra'})) );
    
p.parse(gobj,varargin{:});
args = p.Results;

space = args.space;
factor = args.factor;
gobj = args.gobj;

%%
% if nargin==1
%     factor = 1.5;
% elseif nargin==2
%     factor = varargin{1};
%     if factor<0
%         error_msg('Cropping','Cropping factor must lie within the interval <0,Inf>');
%     end
% end

%% All axes objs
gobj = dynammo.plot.gobj_transform(gobj);
axs = findobj(gobj.fig1.handle,'type','axes');

%% Do not count legend (legendflex() results in axes object)
isLeg = strcmpi(get(axs,'Tag'),'legend');
if any(isLeg)
   axs = axs(~isLeg); 
end

%% Body
if strcmpi(space,'intra')
    for ii = 1:length(axs)
        pos = get(axs(ii),'Position');
        was = pos(2);
        pos(2) = pos(2)*factor;
        pos(4) = pos(4)-(pos(2)-was);
        set(axs(ii),'Position',pos);
    end
    
else % 'extra' case
    posax = cell(length(axs),1);
    for ii = 1:length(axs)
        set(axs(ii),'Units','centimeters');
        posax{ii} = get(axs(ii),'Position');
    end
    
    set(gobj.fig1.handle,'Units','centimeters');
    posfig = get(gobj.fig1.handle,'Position');
    
   %extra = posfig(4)*factor - posfig(4);
    extra = posax{1}(2)*factor - posax{1}(2);
    
   %posfig(4) = posfig(4)*factor;
    posfig(4) = posfig(4)+extra;
    
    posfig(2) = posfig(2)-extra;
    set(gobj.fig1.handle,'Position',posfig);
    for ii = 1:length(axs)
        posii = posax{ii};
        posii(2) = posii(2)+extra;
        set(axs(ii),'Position',posii);
        set(axs(ii),'Units','normalized');
    end
    
end

end %<eof>