function PDFclickedCallback(fhandle)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

drawnow;

%% Orientation
  
set(fhandle,'PaperOrientation','landscape');
%set(fighandle,'PaperSize',A4dims(3:4));
%set(fighandle,'position',A4dims); 
set(fhandle,'PaperUnits','normalized');
set(fhandle,'PaperPosition',[0 0 1 1]);

% >>> M2013b resulted in error last time, changed to cm
set(fhandle,'PaperUnits','centimeters');
% <<<

%fig2save = PDFfigname();
fig2save = outfilename('Figure export to PDF', ...
                       'Enter PDF file name:', ...
                       rand_str(), ...default suggestion
                       '.pdf');

if ~strcmp(fig2save,'')
    print(fhandle,'-dpdf',fig2save,'-r150');
    disp(['--- Figure printed to ' fig2save]);
end

end %<eof>