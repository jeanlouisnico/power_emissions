function csvwrite(this,args)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

d = args.delimiter;

%% File prep

if args.append
    warning_msg('Data export','Option "append" is turned ON, ignored...');
end

fID = fopen(args.filename,'w');

% if cannot open the file
if fID == -1
    error_msg('Data export',['Cannot open the file for writing. Running ' ...
                             'the command fclose(''all'') might help.'],args.filename);
end

%% File filling (line by line)

% Technames
pattern = ['%s' repstr([d '%s'],length(this.techname)) '\n'];
fprintf(fID, pattern,'''''',this.techname{:});

% Names
pattern = ['%s' repstr([d '%s'],length(this.name)) '\n'];
fprintf(fID, pattern,'comment',this.name{:});

% Data
[r,c] = size(this.values);
pattern = ['%s' repstr([d '%.' sprintf('%.0f',args.precision) 'f'],c) '\n'];
for iline = 1:r
    
    % Range -> Weird Excel date formatting not an issue in CSV/TSV
    %linenow = strcat('''',this.range(iline));
     linenow =             this.range(iline);
     
    linenow = [linenow num2cell(this.values(iline,:))]; %#ok<AGROW>
    if iline~=r
        fprintf(fID, pattern,linenow{:});
    else
        fprintf(fID, pattern(1:end-2),linenow{:});% Last \n neglected from
    end
end

status = fclose(fID);

% if cannot close the file
if status~=0
    warning_msg('Data export','Closing the file after writing unsuccessful:',args.filename);    
end

end %<eof>