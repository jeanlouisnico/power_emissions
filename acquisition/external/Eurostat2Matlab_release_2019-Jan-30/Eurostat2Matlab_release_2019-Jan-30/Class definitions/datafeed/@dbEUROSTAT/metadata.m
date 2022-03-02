function metadata(this)
%
% Opens up web browser and shows metadata to a particular EUROSTAT table
%
% INPUT: this ...EUROSTAT database object with specified 'table' property
%
% OUTPUT: none, only the web browser shows some info
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Table definition
if strcmp(this.table,'')
   error_msg('Metadata initial','EUROSTAT table is still undefined (''table'' property must be non-empty)'); 
else
   table = this.table; 
end

%% Non-existent metadata
% -> only the Short description will be displayed (if it exists)

if strcmp(this.table.metadata,'')
    if ~strcmp(this.table.shortDescription,'')
        row_length = 50;% characters per row
        desc = [this.table.shortDescription ' '];% One extra space for the terminal condition
        fprintf('\n');
        fprintf(' <strong>Short description:</strong>');
        fprintf('\n');
        while true
            spaces = regexp(desc,' ');
            if ~isempty(spaces)                
                last_char = spaces(find(spaces<row_length,1,'last'));
                fprintf('%s\n',[repstr(' ',3) desc(1:last_char-1)]);
                if last_char==length(desc)
                   break 
                end
                desc = desc(last_char+1:end);
            else
                fprintf('%s\n',[repstr(' ',3) desc]);
                break
            end
        end
        fprintf('\n');
        error_msg('Metadata downloading','EUROSTAT only provides  short description for the selected table (see the above print-out)...'); 
        % return -> the above error_msg() will return
    else
        error_msg('Metadata downloading','EUROSTAT does not provide any metadata/description for the selected table :('); 
    end
    
end

%% Metadata web link

tmp = regexp(this.table.metadata,'\w*\.sdmx\.zip','match');
file_on_site = strrep(tmp{:},'.sdmx.zip','');

% https://ec.europa.eu/eurostat/cache/metadata/en/ert_bil_conv_esms.htm
link = ['https://ec.europa.eu/eurostat/cache/metadata/en/' file_on_site '.htm'];

if ispc
    try % Do not end up in error if bad rendering
        ie = actxserver('internetexplorer.application');
        Navigate(ie, link);
        ie.Visible = 1;
    end
else
    web(link,'-new','-notoolbar');
     
end

fprintf('%s\n\n',' -> A new web browser session should now be open...');


end %<eof>