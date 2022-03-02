function st = defStyle(nobj,args)
%
% Definitions of default plot styling
%
% INPUT: nobj ...# of plotted objects
%        type ...plot object type (line/bar/...)
% 
% OUTPUT: st... style structure
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

type = args.type;

%% Default colormap <#case sensitive#>

st = struct();

colorset = [0.2863  0.5098  0.7608
            0.8667  0.1176  0.2235
            0.9843  0.6824  0.0941
            0.5076  0.8325  0.0610
            0.7216  0.3922  0
            0.1175  0.8669  0.7719
            0.9179  0.5430  0.8862
            0.8065  0.8896  0.1171
            0.4081  0.6682  0.4939
            0.9448  0.8281  0.5520];

% 0.9053    0.9316    0.2603 yellow
            
if nobj>10
    % Random colors assumed for the rest
    colorset = [colorset;rand(nobj-10,3)];
else
    % Only a subset of the above colors
    colorset = colorset(1:nobj,:);
end

%% Object properties <# case sensitive#>
if strcmpi(type,'line')
    % Line properties
    st.Color = colorset;
    if dynammo.compatibility.isAlphaChannel
        st.Color = [st.Color repmat(args.alpha,size(colorset,1),1)];% Including the alpha channel!
    end
    st.LineWidth = 6*ones(nobj,1);
    st.Marker = repmat_cellstr('none',nobj);
    % st.MarkerSize = repmat_value(6,nobj);% -> ineffective if marker='none'
    % st.MarkerFaceColor = zeros(nobj,3);  % -> ineffective if marker='none'
    
elseif strcmpi(type,'bar')
    % Bar properties
    st.BarWidth = 0.7;
    st.FaceColor = colorset;
    if dynammo.compatibility.isAlphaChannel
        st.FaceAlpha = args.alpha;
    end
    
elseif strcmpi(type,'fan')
    % Fan chart properties
    if dynammo.compatibility.newGraphics
        nobji = floor(nobj/2);% # of intervals
        st.FaceColor = repmat(colorset(1,:),nobji,1);
        if dynammo.compatibility.isAlphaChannel
            st.FaceAlpha = args.alpha;
        end
    else
        error_msg('Compatibility','Unfortunately fan charts are supported on Matlab versions 2014b+ (new graphics features needed)...');
    end
    
elseif strcmpi(type,'spaghetti')
    % Line properties
    st.Color = colorset;
    if dynammo.compatibility.isAlphaChannel
        st.Color = [st.Color repmat(args.alpha,size(colorset,1),1)];% Including the alpha channel!
        st.Color(1,4) = 1;% The data line should not be transparent
    end
    if nobj>2 % almost always the case
        bl = args.spaghetti_blocks;
        for iblock = size(bl,1):-1:2
            st.Color(bl(iblock,1):bl(iblock,2),:) = repmat(st.Color(iblock,:),bl(iblock,2)-bl(iblock,1)+1,1);
        end
    end
    st.LineWidth = [6;3*ones(nobj-1,1)];
    st.Marker = repmat_cellstr('none',nobj);    

else
    disp('to be implemented...');
    keyboard;
    
end

end %<eof>