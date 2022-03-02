function validate_sheetname(in)
%
% Excel sheet name convention 
% Forbidden characters are []*/\?:
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
if ~isempty(regexp(in,'(\[|\]|\*|\/|\\|\?|:)','once')) % Special characters in sheet name not allowed
%     testname = in(~isspace(in)); % Spaces ARE allowed
%     if ~isempty(regexp(testname,'([^\w*]|_)','once'))
        error_msg('Data export/import','Sheet name must not contain spaces or special characters:',in);
%     end
end

end %<eof>