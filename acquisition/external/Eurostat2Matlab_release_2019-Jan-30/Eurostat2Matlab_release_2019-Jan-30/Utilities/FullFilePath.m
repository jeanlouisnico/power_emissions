function out = FullFilePath(in)
%
% INPUT: File name with or without partial path
%        '..' <previous folder> notation allowed
%
% OUTPUT: Full path to the given filename
% 
% NOTE! Folder/file existence check must be carried out externally...
%       ...since different codes have different demands on overwriting etc.
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Complements to this function based on tsobj/export()

% [folderfullname, ...
%  file_nameonly, ...
%  myext] = fileparts(args.filename);% folder, filename, extension
% 
% % Folder must exist
% if exist(folderfullname,'dir')~=7 % Already full path here
%     error_msg('Data export','Folder does not exist, create & try again:',args.filename);
% end
% 
% % Try to delete existing file
% if exist(outputPDF,'file')
%     while true
%         try
%             delete(outputPDF);
%             break
%         catch
%             fprintf(2,['Cannot open ' outputPDF ' for writing (Close the file + hit F5 to continue)...']);
%             %fclose all;
%             keyboard;
%         end
%     end
% end

%% Body

% Correct separator
if ispc
    in = strrep(in,'/',filesep); 
else
    in = strrep(in,'\',filesep);
end

% Full path
if ispc
    if isempty(strfind(in,':'))
        makeFullPath();
    end
else
    if strncmp(in,'/Users',6)==0 && ...
       strncmp(in,'/Volumes',8)==0     
        makeFullPath();
    end
end
out = in;

if length(out) > 260
    out = ['\\?\', out];
end

%% Nested function

    function makeFullPath()
        
        dotNotation = strfind(in,'..');
        if ~isempty(dotNotation)
            path = cd;
            path_segm = regexp(path,filesep,'split');
            path_segm = path_segm(1:end-length(dotNotation));
            filename = in(dotNotation(end)+3:end);
            in = '';
            counter = 1;
            while true
                in = [in path_segm{counter} filesep];
                counter = counter + 1;
                if counter > length(path_segm)
                    break
                end
            end
            in = [in filename];
        else    
            in = [cd filesep in];
        end
        
    end %<makeFullPath>

end %<eof>