function out = EUROSTATtoc(this,args)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% TOC XML file download <if requested, or if needed>

% Personal EUROSTAT folder must exist (otherwise created)
myfolder = [dynammoroot filesep 'Utilities' filesep 'Data handling' filesep 'EUROSTAT' filesep 'TOCfiles'];
tocfile = [myfolder filesep 'table_of_contents.xml'];

if ~exist(myfolder,'dir')
    
    % Create EUROSTAT folder
    mkdir([dynammoroot filesep 'Utilities' filesep 'Data handling' filesep 'EUROSTAT'],['TOCfiles' filesep 'dic']);
    args.refresh = 1; % for XML download
    
elseif ~exist(tocfile,'file')
        args.refresh = 1; % for XML download
end

%% Fresh download of TOC
if args.refresh
    
    % Update the TOC itself
    reDownload_toc();
        
end

%% Processing the TOC XML file

if ~exist(strrep(tocfile,'.xml','.mat'),'file') || args.refresh % refresh XML must be complemented by refreshing .mat file as well!
    fprintf('%s\n','[Dyn:Ammo] XML to struct() conversion...');
    args.xmlfile = tocfile;
    TOClink = this.url.table_of_contents;
    matTOC = dynammo.EUROSTAT.xml2struct_toc(args,TOClink);
    
    % Save TOC in a .mat file
    save([myfolder filesep 'table_of_contents.mat'],'matTOC');
    fprintf('\nDone!\n\n');
else
    load([myfolder filesep 'table_of_contents.mat']);
    
end

out = matTOC;

%% Update of dictionaries/revision dates

if args.refresh
    
    % [2] Update all dictionaries (only those so far used, others will be downloaded when needed)
    dic_fldr = [dynammoroot filesep 'Utilities' filesep 'Data handling' filesep 'EUROSTAT' filesep 'TOCfiles' filesep 'dic'];
    if ispc
        alldics =  cellstr( ls([dic_fldr filesep '*.dic']));
    else
        contents = dir([dic_fldr filesep '*.dic']);
        if length(contents)>1
            alldics = cell(length(contents),1);
            for ii = 1:length(contents)
                alldics{ii,1} = contents(ii).name;
            end
        else
            alldics{1} = '';
        end
    end
    if ~isempty(alldics{1})
        %DIClink = 'https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&dir=dic%2Fen';

        fprintf('[Dyn:Ammo] Refreshing the EUROSTAT .dic files...');
        for ii = 1:length(alldics)
            linknow = strrep(this.url.DIClink,'#ToBeReplaced#',alldics{ii});%[DIClink '%2F' alldics{ii}];
            [~,status] = urlwrite(linknow,[dic_fldr filesep alldics{ii}]);  
            if status ~= 1
                dynammo.error.dbobj(['Downloading the dictionary file "' alldics{ii} '" from ' ...
                             'EUROSTAT did not succeed. Make sure following url link is correct:'], ...
                             linknow);
            end
        end
        fprintf('OK\n');
    end
    
    % [3] Update the table info, which includes dates of last revisions
    % >>> !!! Revisions get downloaded and save to .mat, but dbobj.table gives better information about tables <<<
    rev_fldr = [dynammoroot filesep 'Utilities' filesep 'Data handling' filesep 'EUROSTAT' filesep 'TOCfiles'];
    
    %revisions_link = 'https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=table_of_contents_en.txt';
    
    fprintf('[Dyn:Ammo] Downloading the EUROSTAT tables info (including "last update" dates)...');
        [~,status] = urlwrite(this.url.revisions_link,[rev_fldr filesep 'EUROSTATtable_info.txt']);  
        if status ~= 1
            dynammo.error.dbobj(['Downloading the table info file from ' ...
                         'EUROSTAT did not succeed. Make sure following url link is correct:'], ...
                         revisions_link);
        end
        % Postprocessing
        tmp = import_data([rev_fldr filesep 'EUROSTATtable_info.txt'],'delimiter','\t');
        picked = ~cellfun('isempty',regexprep(tmp(:,4),'("| )',''));% Pick tables only
        desc = strtrim(strrep(tmp(picked,1),'"',''));%Table description
        code =         strrep(tmp(picked,2),'"','');%Table code
        lastUpdate =   strrep(tmp(picked,4),'"','');%Table code
        dbobj_toc_lastUpdate = [code,desc,lastUpdate]; 
        dbobj_toc_lastUpdate(2:end,:) = sortrows(dbobj_toc_lastUpdate(2:end,:),1);%#ok<NASGU> % Sort it for easier processing
        save([rev_fldr filesep 'EUROSTATtable_info.mat'],'dbobj_toc_lastUpdate');
    fprintf('OK\n');
    
end

%% Support functions

    function reDownload_toc()
        fprintf('[Dyn:Ammo] Downloading the Table of contents from EUROSTAT...');
        [~,status] = urlwrite(this.url.table_of_contents,tocfile);
        if status ~= 1
            % Here the link should not be a problem,
            % more likely the user needs to set up the proxy settings properly
            if ispc
                dynammo.error.dbobj(['Downloading the Table of contents file from ' ...
                             'EUROSTAT did not succeed. If you are behind a proxy server, ' ...
                             'click "Preferences/Web" and set the internet connection accordingly. On Windows ' ...
                             'machines, the proxy settings can be taken from Internet Explorer settings...']); 
            else
                dynammo.error.dbobj(['Downloading the Table of contents file from ' ...
                             'EUROSTAT did not succeed. If you are behind a proxy server, ' ...
                             'click "Preferences/Web" and set the internet connection accordingly. On Mac OS X ' ...
                             'machines, the proxy settings can be taken from System preferences/Internet utility...']);                 
            end
            
        end
        fprintf('OK\n');
    end %<reDownload_toc>

end %<eof>