function svg(fighandle,filepath,varargin)
%
% Image exporter into .SVG format (potentially with embedded font)
%
% INPUT: fighandle ...figure object (or a handle)
%        filepath  ...location and name to save new .svg file
%       [fontEmbedding] ...external font as .txt file
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Font embedding
if nargin==3
    fontEmbedding = varargin{1};
    if ~ischar(fontEmbedding)
        error_msg('SVG export','Embedded font has to be passed as ''.txt'' file name (string)...');
    end
    if isempty(fontEmbedding)
        fontEmbedding = 0;
        
    else
        if ~strncmp(fliplr(fontEmbedding),'txt.',4)
           fontEmbedding = [fontEmbedding '.txt']; 
        end
        myFont_base64 = which(fontEmbedding);
        if isempty(myFont_base64)
            error_msg('Embedded font allocation','Input font has not been found:',fontEmbedding);
        end
        fontEmbedding = 1;
        
    end
    
else
    fontEmbedding = 0;

end

%% Save name
% + append the correct extension if necessary
fullPath = FullFilePath(filepath);
if ~strncmp(fliplr(fullPath),'gvs.',4)
    fullPath = [fullPath '.svg'];
% else
%     error_msg('File name','File extension ''.svg'' should not be provided by the user - only the file name is needed due to ');
end

%% Figure handle
[han,nfigs] = dynammo.plot.getHandle(fighandle);
if nfigs>1
    error_msg('SVG export','Multiple input figures should be processed one by one...');
else
    han = han{1};
end

%% Correct font weight
% set(findobj(han,'fontweight','bold'),'fontweight','normal');

%% Create .SVG file
print(han,'-dsvg',fullPath);

%% PERL file manipulation

usePERL = 0; % Works but is slower on PC
if usePERL 
    % PERL executable
    perlCmd = sprintf('"%s"',fullfile(matlabroot, 'sys\perl\win32\bin\perl')); %#ok<*UNRCH>

    % [1] Override default font-family
    if ispc
        oneliner = sprintf('%s -i.bak -pe"s/Times New Roman/jaacFont/g" "%s"', perlCmd,fullPath);
        system(oneliner);
        delete([fullPath '.bak']);

    else
        % We use system PERL installation on Mac OS
        oneliner = ['perl -pi -w -e ''s/Times New Roman/jaacFont/g;'' "' fullPath '"'];
        eval(['!' oneliner]);
        
    end

    % [2] Embedded the font style
    % -> replacement happens just once!
    %    perl -i.bak -p -e '$i = s/old/new/ if !$i' filename
    %    perl -i.bak -p -e '$x++ if $x==0 && s/old/new/;' filename
    %    perl -i -pe '$done ||= s/old/new/' filename
    
    % First, delete last two lines from file
    % system([perlCmd ' -ni.bak -e "print unless /<\/svg/" "' fullPath '"'])
    perl('deleteLastLine.pl',fullPath);% #end
    perl('deleteLastLine.pl',fullPath);% #end-1

    % Next, append the font directly into .svg file 
    if ispc
        system(['>nul copy "' fullPath '"+"' myFont_base64 '" "' fullPath]);

    else
        oneliner = ['cat "' fullPath '" "' myFont_base64 '" >> "' fullPath '"'];
        eval(['!' oneliner]);

    end   
   
    return
    
end
   
%% Read in generated .svg
svg = dynammo.io.readFile(fullPath,'utf-8');

%% Text replacements
repl = {'%',       '%%'
        '\',       '\\';
        '>#</text','>&#215;</text'}; % '#' is the times symbol in vertical axes scaling

if fontEmbedding
    f = dynammo.io.readFile(myFont_base64);
    fontname = regexp(f,'(?<=font-family:).+?(?=;)','match','once');
    fontname = fontname(~isspace(fontname));
    
    repl = [repl;{'Calibri',fontname}]; % 'Calibri' chosen as default font
    if isempty(strfind(svg,'Calibri'))
        warning_msg('SVG export',['''Calibri'' font has not been found in ' ...
                                  'generated .SVG graphics, font embedding ' ...
                                  'is likely to malfunction...']);
    end
end

svg = regexprep(svg,repl(:,1),repl(:,2));
svg = regexprep(svg,'<\?xml version\="1\.0"\?>','<?xml version="1.0" encoding="UTF-8"?>','once');

% Embedding goes last, file size increases substantially
if fontEmbedding
    % -> replacement happens just once!
    svg = regexprep(svg,'(?<=<svg.*?)>',['>' f],'once');
end

% [3] Resave the result
dynammo.io.writeFile(svg,fullPath,'utf-8');

end %<eof>