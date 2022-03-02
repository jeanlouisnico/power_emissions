function pdf2svg(varargin)
%
% pdf->svg converter (converts all pages from given file)
%
% INPUT: [infile] ...single .pdf file (can be even multipage)
% 
% USAGE: dynammo.io.pdf2svg()       ...all PDF files from current folder processed
%        dynammo.io.pdf2svg(infile) ...all pages from given PDF saved as a separate SVG
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
if nargin==0  % All PDF files processed
    f = dir('*.pdf');
    f = {f.name};

    for ii = 1:length(f)
        res = system(['pdf2svg "' f{ii} '" "' strrep(f{ii},'.pdf','.svg') '"']);
    end
    
else  % Given multipage .pdf file
    infile = varargin{1};
    res = system(['pdf2svg ' infile ' ' strrep(infile,'.pdf','_page%d.svg') ' all']);
    
end

end %<eof>