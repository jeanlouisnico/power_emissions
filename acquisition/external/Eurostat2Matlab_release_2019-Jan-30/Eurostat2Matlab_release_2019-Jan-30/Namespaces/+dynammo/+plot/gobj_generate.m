function gobj_clone = gobj_generate(gobj_orig,fhan_orig,fhan_clone,container)
% 
% When creating an identical copy of a figure, structure of the objects
% must be regenerated ex post. This fcn can be used to do that.
%
% INPUT: gobj_orig ...original gobj structure of a figure
%        fhan_orig ...handle to the original figure
%        fhan_clone...handle to the copied figure
%        container ...[nx2] matrix of corresponding handles
% 
% OUTPUT: structure of object handles to the new figure
%
% See also: dynammo.plot.gcf2obj(), dynammo.plot.gobj_transform()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Cloning

gobj_clone = gobj_orig;

if isstruct(gobj_orig)
    f = fieldnames(gobj_orig);
    for ii = 1:length(f)
        gobj_clone.(f{ii}) = dynammo.plot.gobj_generate(gobj_orig.(f{ii}),fhan_orig,fhan_clone,container);
    end
    
elseif iscell(gobj_orig)
    for ii = 1:length(gobj_orig)
        gobj_clone{ii} = dynammo.plot.gobj_generate(gobj_orig{ii},fhan_orig,fhan_clone,container);
    end

% elseif isa(gobj_orig,'double') && length(gobj_orig)>1 % This is important, otherwise we may end up in a infinite recursion
% %     keyboard;
%     for ii = 1:length(gobj_orig)
%         gobj_clone(ii) = dynammo.plot.gobj_generate(gobj_orig(ii),fhan_orig,fhan_clone,container);
%     end    
elseif length(gobj_orig)>1 % e.g. bar arrays inside legend half1/half2 objects    
    % Essentially the same code as above, except input is not of type 'double' now
%     keyboard;
    for ii = 1:length(gobj_orig)
        gobj_clone(ii) = dynammo.plot.gobj_generate(gobj_orig(ii),fhan_orig,fhan_clone,container);
    end       
else % 'double' but a single number here only
    
    try
        if ~any(size(gobj_orig)==0) % Non empty gobj_orig
            gobj_clone = container(gobj_orig==container(:,1),2);
        else
            gobj_clone = '<empty>';
        end
    catch
        keyboard;
    end
   
   % Update legend handles to correct lines/bars
   obj = get(gobj_orig);
   if isfield(obj,'Tag')
       if strcmpi(get(gobj_orig,'Tag'),'legend')
%            keyboard;
           tmp1 = get(gobj_orig,'UserData');
           tmp2 = get(gobj_clone,'UserData');
                      
           % !!!!! container has 'Labhandles' in M2014b-, these are skipped in M2014b+
           % !!!!! we for sure do not need 'Labhandles' inside UserData
           
           handles = tmp1.handles;
           
           if ~iscell(handles) % -> 'line' plots + 'bar' plots M2014b-
               clone_han = zeros(size(handles));
               for ihan = 1:length(clone_han)
                   clone_han(ihan) = container(handles(ihan)==container(:,1),2);
               end
               tmp2.handles = clone_han;
               tmp2.PlotHandle = container(tmp1.PlotHandle==container(:,1),2);
           
           else % -> 'bar' plots manually entered as cell() to be able to cope with both positive/negative bar values (in lgndItemClick)
               halfPlane = 1;
               clone_han = zeros(size(handles{halfPlane}));
               for ihan = 1:length(clone_han)
                   clone_han(ihan) = container(handles{halfPlane}(ihan)==container(:,1),2);
               end
               tmp2.handles = clone_han;
               tmp2.PlotHandle = container(tmp1.PlotHandle==container(:,1),2);               
           end

%            keyboard;
           set(gobj_clone,'UserData',tmp2);
       end
   end
   
end

end %<eof>