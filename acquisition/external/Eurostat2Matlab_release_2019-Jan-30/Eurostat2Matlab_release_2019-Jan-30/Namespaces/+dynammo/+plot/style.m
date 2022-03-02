function style = style(args,nobj)
% 
% Style resolution for line and bar graphs
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

userstyle = args.style;

%% Body
if isstruct(userstyle) % -> User-defined style
    
    % Default styling
    st = dynammo.plot.defStyle(nobj,args);
    
    % User-specific styling
    f = fieldnames(userstyle);
    for ii = 1:length(f)
       st.(f{ii}) = userstyle.(f{ii}); % User-defined 'Color' property disables 'alpha' property
                                       % Solution -> 4D color input (RGB+A)
    end
        
elseif userstyle==0 % -> Default styling
    
    st = dynammo.plot.defStyle(nobj,args);
        
else % -> Previously saved style, can be numeric/string
    st = mystyle(userstyle);
    
end

%% Counts validation
[stcell,st] = dynammo.plot.process_struct_style(st,nobj,args);

%% Output
style.struct = st;
style.cell = stcell;

end %<eof>