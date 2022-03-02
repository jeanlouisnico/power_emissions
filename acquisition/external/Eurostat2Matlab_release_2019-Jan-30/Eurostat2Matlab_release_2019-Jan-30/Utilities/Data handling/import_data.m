function varargout = import_data(varargin)
%
% Imports data from an external file (.csv, .xlsx),
% Note: Data from files containing data in time series format
%       use this function to import data to Matlab, but the data 
%       get consequently processed by dynammo.tsobj.process_imported_data()
%
% INPUT: Run dynammo.options.import_data() to get a complete list of available options
%
% OUTPUT: imported data
%
% SEE ALSO: dynammo.io.readFile()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options

args = dynammo.options.import_data(varargin{:});

% Input structure printout
if isempty(varargin)
    if nargout>0
        varargout{1} = {};
    end
    return
elseif nargout~=1
    error_msg('Data import','Output container not specified...');
end

%% File types

% Get file extension
[~,~,ext] = fileparts(args.filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(strfind(ext,'.xls')) % Read from xls -> also finds .xlsm, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        
    if ispc
        
        % Take the first sheet unless the user wants something specific
        if isempty(args.sheetname)
           args.sheetname = 1;% First sheet 
        end
        
        % Read data
        if isempty(args.range)
            [~,~,cellfile] = xlsread(args.filename, args.sheetname);
        else
            [~,~,cellfile] = xlsread(args.filename, args.sheetname, args.range);
        end
        
    else
        error_msg('Data import','Import from Excel file is possible on PC machines only...');
    end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
else % Raw text file on input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    
    
    % Open .csv file for reading
    fid = fopen(args.filename,'r');
    if fid == -1
        error_msg('csvload()','Cannot read from file:',args.filename);
    end
    
    % Intro
    delimiter = args.delimiter;%'\t'
    maxrows = args.maxrows;%2e4;
    addRows = args.addRows;%5e3;

    cellfile = cell(maxrows,1);
    nline = 1;
    line = fgets(fid);%line = fgetl(fid); -> better, but can be slow sometimes :(

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if length(args.filter)==1 % No filtering
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

        % File contents
%         counter = 0;
        while ischar(line)

            addBuffer();

            cellfile{nline,1} = line;
            nline = nline +1;
            line = fgets(fid);
%             if counter>100000
%                break 
%             end
%             counter = counter + 1;
%             if mod(counter,1e4)==0
%                 disp(counter);
%             end
        end

        fclose(fid);

        % Empty rows get thrown away
        emptyrows = all(cellfun('isempty',cellfile),2);
        cellfile = cellfile(~emptyrows,:);

        % Drop all leading/trailing white-space junk
        cellfile = strtrim(cellfile); %strrep(linenow,sprintf('\r\n'),'');  
        ns = size(cellfile,1);

        % Delimited explosion
        if strcmp(delimiter,'","')
            % Commas are inside comments, these have to be skipped
            for ii = 1:ns
                cellfile{ii} = commas_inside_quotes(cellfile{ii});
            end
            cellfile = regexp(cellfile,',','split');
        else
            cellfile = regexp(cellfile,delimiter,'split');
        end

        % Generate proper cell object
        lengths = cellfun('length',cellfile);
        outcell = cell(ns,max(lengths));
        for ii=1:ns
           outcell(ii,1:lengths(ii)) = cellfile{ii}; 
        end
        cellfile = outcell;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif length(args.filter)>1 && strcmp(delimiter,'","') % Non-empty filtering criterion + "," delimiter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if length(args.filter)==2
            assessment_fun = @strcmpi;
        else
            assessment_fun = args.filter{3};            
        end
        
        % Always take the first line (headers)
        try %#ok<TRYNC>
            line = commas_inside_quotes(line);
            linenow = regexp(line,',','split');
            cellfile(nline,1:length(linenow)) = linenow;
            nline = nline +1;
            line = fgets(fid);
        end
        
        % File contents
        while ischar(line)

            addBuffer();

            % Commas are inside comments, these have to be skipped
            line = commas_inside_quotes(line);
            
            %keyboard;
            linenow = regexp(line,',','split');
            to_test = linenow{args.filter{1}};
            if feval(assessment_fun,to_test,args.filter{2}) %strcmpi(to_test,args.filter{2})
                cellfile(nline,1:length(linenow)) = linenow;
                nline = nline +1;
            end
            line = fgets(fid);
  
        end

        fclose(fid);

        % Empty rows get thrown away
        emptyrows = all(cellfun('isempty',cellfile),2);
        cellfile = cellfile(~emptyrows,:);

        % Drop all leading/trailing white-space junk
        cellfile = strtrim(cellfile); %strrep(linenow,sprintf('\r\n'),'');  
%         ns = size(cellfile,1);

%         % Generate proper cell object
%         lengths = cellfun('length',cellfile);
%         outcell = cell(ns,max(lengths));
%         for ii=1:ns
%            outcell(ii,1:lengths(ii)) = cellfile{ii}; 
%         end
%         cellfile = outcell;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else % Non-empty filtering crit. + delimiter of all types except for '","'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if length(args.filter)==2
            assessment_fun = @strcmpi;
        else
            assessment_fun = args.filter{3};            
        end
        
        % Always keep the first line (headers)
        try %#ok<TRYNC>
            linenow = regexp(line,delimiter,'split');
            cellfile(nline,1:length(linenow)) = linenow;
            nline = nline +1;
            line = fgets(fid);
        end
        
        % File contents
        while ischar(line)

            addBuffer();

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % [1] ->regexp]
            linenow = regexp(line,delimiter,'split');
            to_test = linenow{args.filter{1}};
            if feval(assessment_fun,to_test,args.filter{2}) %strcmpi(to_test,args.filter{2})
                cellfile(nline,1:length(linenow)) = linenow;
                nline = nline +1;
            end
            % [2] ->cellfile as 1 column only, regexp later]
    %         cellfile{nline,1} = line;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            line = fgets(fid);
        end

        fclose(fid);

        % Empty rows get thrown away
        emptyrows = all(cellfun('isempty',cellfile),2);
        cellfile = cellfile(~emptyrows,:);

        % Drop all leading/trailing white-space junk
        cellfile = strtrim(cellfile); %strrep(linenow,sprintf('\r\n'),'');  
    %     ns = size(cellfile,1);

        % Generate proper cell object
    %     lengths = cellfun('length',cellfile);
    %     outcell = cell(ns,max(lengths));
    %     for ii=1:ns
    %        outcell(ii,1:lengths(ii)) = cellfile{ii}; 
    %     end
    %     cellfile = outcell;
    end

end

%% Output is mandatory

varargout{1} = cellfile;

%% Support functions
    function addBuffer()
        if nline>maxrows
            cellfile = [cellfile;cell(addRows,size(cellfile,2))]; 
            maxrows = maxrows + addRows;
        end
    end %<addBuffer>

    function linenow = commas_inside_quotes(linenow)
        % Replaces commas inside double quotes with a '+' character
        quotes = regexp(linenow,'"');%char(linenow)
        qStart = quotes(1:2:end-1);
        qEnd = quotes(2:2:end);
        commas = regexp(linenow,',');
        kk = zeros(size(linenow));
        kk(qStart) = 1;
        kk(qEnd) = -1;
        tmp = cumsum(kk)==1;
        where = commas(tmp(commas));
        linenow(where) = '+';
                
        % !!! this only matters for tsobj import -> range cannot contain "..." values, 
        %         but this is handled inside dynammo.tsobj.process_imported_data()
        %cellfile{ii} = strrep(linenow,'"','');% +20% in terms of run time :( - the user can do it himself
        % !!!
        
    end %<commas_inside_quotes>

end %<eof>