function out = download(dbobj)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input check

if isempty(dbobj.table)
    error_msg('EUROSTAT download',['Specify table from which data is to be downloaded' ...
                                   '- picktable() method of the dbEUROSTAT() ' ...
                                   'object can do that...']);
end


if isstruct(dbobj.filter)
    cells = structfun(@iscell,dbobj.filter);
    if sum(cells)>1
       error_msg('EUROSTAT download','Filtering criterion for the data must be specified more strictly, only 1 cell() allowed in the filter input...'); 
    end
end

%% Data feed

if isempty(dbobj.table.downloadLink.bulk) % -> missing data may also apply to json, to be checked
    error_msg('EUROSTAT download','Data in requested table probably exist, but cannot be fetched via the EUROSTAT downloading facility...'); 
end

% Table name (naked)
file_on_site = regexp(dbobj.table.downloadLink.bulk,'\w*\.tsv\.gz','match');
file_on_site = file_on_site{:};
table = strrep(file_on_site,'.tsv.gz','');  

% Where the zip archive will be temporarily stored
zipfile = [cd filesep file_on_site];
filename_out = strrep(file_on_site,'.gz','');
    
% Make sure we have the desired .tsv file in the current folder ('table')
if strcmpi(dbobj.engine,'Bulk/SDMX') || ...
  (strcmpi(dbobj.engine,'JSON') && isempty(dbobj.filter)) % In this case we need to download the file in order to identify filtering criteria

    if exist([cd filesep filename_out],'file')==0 && dbobj.offline==0

        % File download
        fprintf('\nDownloading table "%s"...',table);
        file_address = dbobj.table.downloadLink.bulk;

            % Give it several attempts to download the data
            attempt = 1;
            while true
                [~,status] = urlwrite(file_address, zipfile);
                if status==1
                    break
                end
                if attempt==9
                    error_msg('EUROSTAT download','Problem with downloading EUROSTAT table:',file_address);
                end
                attempt = attempt+1;
                pause(1+rand()); % This is important, otherwise EUROSTAT could cut us off!
            end

        fprintf('OK!\n');

        % File gunzip
        streamCopier = com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;
        gunzipwrite(zipfile, pwd, filename_out, streamCopier, file_address);

        % Delete temporary zip archive (keep the unzipped file only)
        delete(zipfile);
        
        fresh_download = 1;
        
    else
        

        % Re-use previously downloaded file
        fprintf('\nRe-using previously downloaded table "%s"...',table);
        fprintf('OK!\n');

        fresh_download = 0;

    end

end

%% JSON web based query needs further stage of parsing

check_filter = 0;

%% Data structure definition (DSD)
% -> used for filtering
% -> always downloaded using the SDMX standard, 
%    even if furthermore the data is fetched via bulk download
%    .tsv are more compact + faster to process locally

if isempty(dbobj.filter)
    
    USERsupplied = 0;
    
    % Look inside to see the structure of filtering categories
    file_to_process = [table '.tsv'];
    tmp = dynammo.EUROSTAT.parser(file_to_process,dbobj);
    filtering_pattern = tmp.crit_pattern;
    filtering_sets     = tmp.crit_sets;
    
    % SDMX query for DSD
    fprintf('\nDownloading Data Structure Definition (DSD) for table "%s"...',table);
    saveFileAs = [cd filesep table '_DSD.xml'];
    DSDlink = strrep(dbobj.url.DSD,'#ToBeReplaced#',table);
    if ~dbobj.offline
        urlwrite(DSDlink,saveFileAs);
    end
    fprintf('OK!\n');

    argsXML.language = 'en';
    argsXML.xmlfile = saveFileAs;
    argsXML.filtering = filtering_pattern;
    
    % XML processing of the DSD file
    dsd = dynammo.EUROSTAT.xml2struct_dsd(argsXML,DSDlink);
    
    % Open up the selection window for time series
    f = dynammo.EUROSTAT.applyFilter(dsd,filtering_sets);
    
    % Do NOT proceed unless figure 'f' is closed
    % -> series selection must be finished first
    fprintf(2,'\n --> Pick your data in the selection panel, once you hit ''select'' the code execution will continue...\n\n');
    waitfor(f);
    
    % Stack control <part II>
    % In case the user closes the GUI, the function should quit
    if evalin('base','GUIshutdown')
        
       if dbobj.offline==0
           
           % Delete .tsv (table) + .xml (DSD)
           if fresh_download
                delete(filename_out);
           end

           % Delete XML DSD file
           try
               delete(saveFileAs);
           catch %#ok<CTCH>
               error_msg('EUROSTAT download','Cannot delete the XML DSD file...',saveFileAs);
           end
           
       end
       
       out = '';
       return
       
    end

    % Update the filtering criterion based on previous user selection
    dbobj.filter = evalin('base','dbobj_series_selection');
    
    % Fetch the suggested 'name/techname' properties of given time series
    % -> in case user knows the filter, the 'name/techname' properties will be taken from the respective .dic file
    name = evalin('base','dbobj_series_selection_name');
    techname = evalin('base','dbobj_series_selection_techname');% Needed to guarantee the proper ordering
    
    % Delete XML DSD file
    if dbobj.offline==0
        try
            delete(saveFileAs);
        catch %#ok<CTCH>
            error_msg('EUROSTAT download','Cannot delete the XML DSD file...',saveFileAs);
        end
    end
    
else
    
    % 'name' using .dic download if non-existent file
    % + if tscoll, use names from techname
    % + if single tsobj, use table name
    
    USERsupplied = 1;
    
    % Convert JSON web query to standard struct() format
    % -> Origination from: https://ec.europa.eu/eurostat/web/json-and-unicode-web-services/getting-started/query-builder
    if ischar(dbobj.filter)
        dbobj.filter = dynammo.EUROSTAT.web_json2struct(dbobj.filter);
        check_filter = 1;
    end
    
    % Folder with .dic files
    if dbobj.offline==0
        dic_fldr = [dynammoroot filesep 'Utilities' filesep 'Data handling' filesep 'EUROSTAT' filesep 'TOCfiles' filesep 'dic'];
    else
        % Educational/offline version will need the sample .dic from the current folder
        % downloading is then not necessary
        dic_fldr = cd();
    end
    
    f = fieldnames(dbobj.filter);
    for ii = 1:length(f)
       if exist([dic_fldr filesep f{ii} '.dic'],'file')~=2       
           % Download .dic file
           linknow = strrep(dbobj.url.DIClink,'#ToBeReplaced#',[f{ii} '.dic']);%[DIClink '%2F' alldics{ii}];
           [~,status] = urlwrite(linknow,[dic_fldr filesep f{ii} '.dic']);  
           if status ~= 1
               dynammo.error.dbobj(['Downloading the dictionary file "' f{ii} '" from ' ...
                            'EUROSTAT did not succeed. Make sure following url link is correct:'], ...
                            linknow);
           end
       end
    end
    
end

% Multiple selection allowed in 1 filtering criterion only
cells = structfun(@iscell,dbobj.filter);
if sum(cells)>1
   error_msg('EUROSTAT download','Only 1 multiple selection allowed for in the filtering criterion...');
end

%% Parse EUROSTAT input to tsobj()

if strcmpi(dbobj.engine,'JSON')
    out = dynammo.EUROSTAT.parser_json(table,dbobj,check_filter);
    
else
    file_to_process = [table '.tsv'];
    out = dynammo.EUROSTAT.parser(file_to_process,dbobj);
    
end

%% 'name' property
% -> dynammo.EUROSTAT.parser() always returns empty 'name', 'technames' are resolved
%       only if a single tsobj() is on input, the 'table' name/technames will be assigned here in this section
% -> When filter from GUI used, 'name' will be determined from the DSD above,
% -> if user knows what series he/she wants, the 'name' is taken from the respective .dic file

% keyboard;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(out.values,2)==1 % Single tsobj() - table name to be used as 'name' property
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    out.techname = regexp(dbobj.table.downloadLink.bulk,'(?<=data/).+?(?=\.tsv)','match');
    out.name = {dbobj.table.title};
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else % tscoll() - multi column used for both names/technames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if USERsupplied % .dic files to be used
                
        % Completeness check for filters on input
        % -> if the user does not provide a complete set of filtering criteria, the code would crash most likely here, if not earlier :(
        if ~any(cells)
            error_msg('Data validation',['Cannot process the data based on selected ' ...
                                         'filtering criteria, this message usually ' ...
                                         'pops up when downloading data in JSON format ' ...
                                         'with an ill-defined web based query setup...']);
        end
        
        multicol = f{cells};% Multi column name (this is the only relevant dimension for names/technames)
        
        % Reordering according to given techname sequence
        [~,where] = ismember(dbobj.filter.(multicol),out.techname);
        if any(where==0)
           error_msg('Data download','Requested entries were not found in the original source:',dbobj.filter.(multicol)(where==0)); 
        end
        out.values = out.values(:,where);
        out.techname = dbobj.filter.(multicol);
        
        % .dic import (previously checked for existence, or downloaded if not found)
        dic = import_data([dic_fldr filesep multicol '.dic'],'delimiter','\t');
        
        for itech = 1:length(out.techname)
            pos = strcmpi(out.techname{itech},dic(:,1));
            out.name{itech} = dic{pos,2};
        end
        
    else % based on GUI selection -> dropped time series resulted in wrong name vector
        
        % techname handled before, but needed here because of proper reordering
        [~,where] = ismember(techname,out.techname);
        if any(where==0)
           % However the GUI data picker checks automatically for the availability 
           % ...so this branch should never be visited
           error_msg('Data download','Requested entries were not found in the original source:',techname(where==0)); 
        end
        out.values = out.values(:,where);
        
        % Ordering guaranteed <?>
        out.techname = techname;
        out.name = name;
        
    end
    
end

%% Deletion
% The only case when the .tsv file does not exist is when we use JSON with user-supplied filters
if dbobj.deleteSourceFiles && exist([cd filesep filename_out],'file')~=0
    delete(filename_out);
end

%% Support functions follow

    function gunzipFilename = gunzipwrite(gzipFilename, outputDir, baseName, streamCopier, file_address)
    % GUNZIPWRITE Write a file in GNU zip format.
    %
    %   GUNZIPWRITE writes the file GZIPFILENAME in GNU zip format. 
    %   OUTPUTDIR is the name of the directory for the output file. 
    %   BASENAME is the base name of the output file.
    %   STREAMCOPIER is a Java copy stream object. 
    %
    %   The output GUNZIPFILENAME is the full filename of the GNU unzipped file.

    % Create the output filename from [outputDir baseName]
    gunzipFilename = fullfile(outputDir,baseName);

    % Create Java input stream from the gzipped filename.
    fileInStream = [];
    try
       fileInStream = java.io.FileInputStream(java.io.File(gzipFilename));
    catch exception
       % Unable to access the gzipped file.
       if ~isempty(fileInStream)
         fileInStream.close;
       end
       error(message('MATLAB:gunzip:javaOpenError', gzipFilename));
    end

    % Create a Java GZPIP input stream from the file input stream.
    try
       gzipInStream = java.util.zip.GZIPInputStream( fileInStream );
    catch exception
       
       disp('>>>'); 
       disp('Make sure the following address is ok:');
       disp(file_address);
       disp('<<<'); 
       
       % The file is not in gzip format.
       if ~isempty(fileInStream)
         fileInStream.close;
       end
       error(message('MATLAB:gunzip:notGzipFormat', gzipFilename));
    end

    % Create a Java output stream from the input GZIP stream.
    outStream = [];
    try
       javaFile  = java.io.File(gunzipFilename);
       outStream = java.io.FileOutputStream(javaFile);
    catch exception
       cleanup(gunzipFilename, outStream, gzipInStream, fileInStream);
       error(message('MATLAB:gunzip:javaOutputOpenError', gunzipFilename));
    end

    % Gunzip the file using the streamCopier.
    try   
       streamCopier.copyStream(gzipInStream,outStream);
    catch exception
       cleanup(gunzipFilename, outStream, gzipInStream, fileInStream);   
       error(message('MATLAB:gunzip:javaCopyStreamError', gunzipFilename));
    end

    % Cleanup and close the streams.
    outStream.close;
    gzipInStream.close;
    fileInStream.close;

%     end %<gunzipwrite>

    function cleanup(filename, varargin)
    % Close the Java streams in varargin and delete the filename.

    % Close the Java streams.
    for k=1:numel(varargin)
       if ~isempty(varargin{k})
          varargin{k}.close;
       end
    end

    % Delete the filename if it exists.
    w = warning;
    warning('off','MATLAB:DELETE:FileNotFound');
    delete(filename);
    warning(w);

%     end %<cleanup>

% end %<eof>