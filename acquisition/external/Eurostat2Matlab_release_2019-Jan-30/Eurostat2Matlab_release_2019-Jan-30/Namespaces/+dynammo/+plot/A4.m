function A4(fighandle,page_orient,scaling)
%
% Adjusts paper positioning for a given figure handle in order to make PDF export much easier
%
% INPUT: fighandle ...handle to an existing figure
%        page_orient ...page orientation (portrait/landscape/slide)
%        scaling     ...for rescaling the shape of figure, 
%                       by default scaling=[1 1], mainly useful in slide mode
% 
% CALLED BY: fig2print(), 
%            dynammo.plot.figInitialize(),
%            

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

switch page_orient % units in centimeters
    case 'portrait' % strcmp(page_orient,'portrait') 
        A4dims = [5 0 21*scaling(1) 29.7*scaling(min(end,2))];%portrait
    case 'landscape'
        A4dims = [5 5 29.7*scaling(1) 21*scaling(min(end,2))];%landscape
    case 'slide' %'16:9'
       %A4dims = [5 5 33.86666667 17.78];% presentation: standard 16:9 should be 13.333:7.5 inch        
       %A4dims = [5 5 33.86666667*0.9*0.9*scaling(1) 17.78*0.75*0.85*scaling(min(end,2))];
       % presentation: standard 16:9 should be 13.333:7.5 inch        
       
       % Windows 10 -> does not work in multi monitor environment as long as the dimensions are different from the base laptop screen
       A4dims = [5 5 17*scaling(1) 7*scaling(min(end,2))];
       
    case 'doc1' % Small picture in text document
        A4dims = [25 15 7*scaling(1) 4.95*0.75*scaling(min(end,2))];
    case 'pg_halfwidth' % Width +/- half of A4 paper counting on some margins
        A4dims = [25 15 7.69*scaling(1) 5.7*scaling(min(end,2))];
    case 'pg_fullwidth' % Width +/- full width of A4 paper (but larger margins)
        A4dims = [25 15 12.69*scaling(1) 6*scaling(min(end,2))];    
   
    % !!! On top of predefined sizes use args.scaling = [x y] to resize the figures properly
    % Always update dynammo.plot.A4types()
    %               dynammo.plot.yscale_size()
    
end

% Make changing paper type possible
set(fighandle,'PaperType','<custom>');
set(fighandle,'units','centimeters');
set(fighandle,'PaperUnits','centimeters');

% >>> Orientation causes bad rendering <<<
% set(fighandle,'PaperOrientation',orientation);
set(fighandle,'PaperSize',A4dims(3:4));
set(fighandle,'position',A4dims); 

%% Paper calibration
if any(strcmpi(page_orient,{'portrait','landscape'}))
    if ispc
        xpos   = 0.039  *A4dims(3);
        ypos   = 0.095  *A4dims(4);
        width  = 0.925  *A4dims(3);
        height = 0.853  *A4dims(4);
    else
        xpos   = 0.009  *A4dims(3);
        ypos   = 0.135  *A4dims(4);
        width  = 0.975  *A4dims(3);
        height = 0.825  *A4dims(4);
    end
    set(fighandle,'PaperPosition',[xpos ypos width height]);%A4dims);
   %set(fighandle,'PaperPositionMode','auto'); -> must be 'manual' !!!    
    
else
    set(fighandle,'PaperPositionMode','auto');
   
end


%% Mark the object
set(fighandle,'Tag',['figready_' page_orient]);

end %<eof>