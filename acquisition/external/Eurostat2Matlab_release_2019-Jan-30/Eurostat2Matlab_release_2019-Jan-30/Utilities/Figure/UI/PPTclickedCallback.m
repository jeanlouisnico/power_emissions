function PPTclickedCallback(fhandle)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Output file name

outfile = dynammo.plot.outfilename('Figure export to PPT', ...
                                   'Enter PPT file name:', ...
                                   'slide_tmp', ...default suggestion
                                   '.pptx');

if isempty(outfile)
    return
end

%% Figure positioning
% set(fhandle,'Units','pixels');
% set(fhandle,'Position',[680 601 958 497/1]);
if ~any(strcmpi(get(fhandle,'Tag'),'figready_slide')) %{'figready_4:3';'figready_16:9'}
    fig2print(fhandle,'slide');
end

%% PPT template
file_template = [dynammoroot '\Utilities\Figure\UI\slide_prezentace.pptx'];
outfile = [cd filesep outfile];

% doTemplate = 0;
% if exist(outfile,'file')==0
    % Fetch PPT template
    [SUCCESS,MESSAGE,MESSAGEID] = copyfile(file_template,outfile);
%     doTemplate = 1;
    
% end

%% PowerPoint session
ppt = actxserver('PowerPoint.Application');
ppt.visible = 1;

try
    op = invoke(ppt.Presentations,'Open',outfile);%,[],[],0);
catch
    delete(ppt);
    error_msg('PPT export',['File "' outfile '" cannot be openned...']);
end

% if doTemplate
    % Work with slide #1
    slide = op.Slides.Item(1);
    invoke(slide,'Select');
%     slide.Duplicate;
    
% else
%     % Duplicate last slide
%     n = get(op.Slides,'Count');
%     slide = op.Slides.Item(n);
%     invoke(slide,'Select');
%     slide.Duplicate;
%   
% end

%% Copy image to clipboard

openGL_engine = 1;

if dynammo.compatibility.newGraphics
   
    % Test the Matlab version this way: <fhandle.Number only in later version>
    print('-dmeta',['-f' num2str(fhandle.Number)],'-r150','-painters');
 
else
    
    openGL_engine = 0;
    print('-dmeta',['-f' num2str(fhandle)],'-r0');
   
end

%% Paste image to .pptx and reposition

if openGL_engine % >>> 2014b graphics
    
    saveas(fhandle,'pic1.emf','emf');
    pic1_file=[pwd '\pic1.emf'];
    
    % Get height and width of slide:
    slide_H = op.PageSetup.SlideHeight;
    slide_W = op.PageSetup.SlideWidth;
    leftpos=0.05;
    toppos=0.10;
    metaWidth=0.85;
    metaHeight=0.7;
        
    pic1 = invoke(slide.Shapes,'AddPicture',pic1_file, ...
                'msoFalse','msoTrue', ...
                leftpos*slide_W, ...single(double(leftpos*slide_W)), ...
                toppos*slide_H, ...
                metaWidth*slide_W, ...
                metaHeight*slide_H); %'left, top, width, height
    delete(pic1_file);
    
else % >>> 2014a and older
    
    pic = invoke(slide.Shapes,'PasteSpecial',3);
    
    % Set position
    toppos = 80;
    leftpos = 0;
    metaWidth = 700;
    
    set(pic,'Left',leftpos,'Top',toppos,'Width',metaWidth);
    
end

%% Drop PPT session

% [1] PPT file will remain open + unsaved
delete(ppt);

% [2] Save + quit

end %<eof>