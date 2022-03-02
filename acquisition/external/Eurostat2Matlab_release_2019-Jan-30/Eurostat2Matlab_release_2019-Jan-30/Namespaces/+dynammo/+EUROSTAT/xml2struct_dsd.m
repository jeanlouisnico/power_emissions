function tree = xml2struct_dsd(args,DSDlink)
%
% XML reader for EUROSTAT Table of contents
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options

% lang = args.language;
filtering = args.filtering;

try
    xml = xmlread(args.xmlfile);
catch
    error_msg('XML parser',['Problem with obtaining the Data Structure ' ...
                            'Definition (DSD). Try the following link in ' ...
                            'your web browser to see what might be the ' ...
                            'cause of problems:'],DSDlink);
end

%% Stack control

% st = length(dbstack());

%% Tree generation
tree = struct();

mainnode = xml.getChildNodes.item(0);

% Find mes:Structures
nodenow = findNodes(mainnode,'mes:Structures',1);

% Find str:Codelists
nodenow = findNodes(nodenow,'str:Codelists',1);

% Find str:Codelist
CLs = findNodes(nodenow,'str:Codelist',0);

for ii = 1:length(CLs)
    CLnow = CLs{ii};
    
    % Find ID of current category
    id = findAttrib(CLnow,'id');
    id = strrep(lower(id),'cl_','');
    
    if any(strcmpi(id,filtering)) % Some categories are not in the .tsv file
        
        % List of available codes in current category
        Codes = findNodes(CLnow,'str:Code',0);
        nC = length(Codes);
        
        cellcontent = cell(nC,2);
        for iC = 1:nC
            
            % Find ID of current code
            cellcontent{iC,1} = findAttrib(Codes{iC},'id');
            
            % Explanation
            cellcontent{iC,2} = strtrim(char(Codes{iC}.getChildNodes.getTextContent));
            
        end
        
        % Update the tree structure
        tree.(id) = cellcontent;
        
    end
    
end

%% Order the fields according to the source .tsv table
if length(fieldnames(tree))==length(filtering)
    tree = orderfields(tree,filtering);
else
    error_msg('EUROSTAT download','Problem with timing allocation, some EUROSTAT tables are in an unsupported format :(...');
end
    
%% Make the DSD available from base workspace

assignin('base','dsd',tree);
% fprintf('\n -> Data structure definition generated (available in "dsd" variable)...\n');

%% Support functions

function wanted = findNodes(trunk,password,once)
    
    br= trunk.getChildNodes;
    nbr = br.getLength;
    wanted = cell(nbr,1);
    if once
        for ibr = 1:nbr
            subbr = br.item(ibr-1);
            if strcmpi(subbr.getNodeName,password) %equals() ??
               wanted = subbr;
               return
            end
        end
    else
        for ibr = 1:nbr
            subbr = br.item(ibr-1);
            if strcmpi(subbr.getNodeName,password) %equals() ??
               wanted(ibr,1) = subbr;
            end
        end
    end
    empties = cellfun('isempty',wanted);
    if all(empties)
        error_msg('DSD processing','Node name in XML source not found:',password);
    end
    wanted = wanted(~empties);
    
% end %<findNodes>

function out = findAttrib(CLnow,password)
    
    attr = CLnow.getAttributes;
    for iatt = 1:attr.getLength
        if strcmpi(attr.item(iatt-1).getName,password)
            out = char(attr.item(iatt-1).getValue);
            %out = out(4:end);% Drop "CL_"
            break 
        end
    end
    
% end %<findAttrib>

% end %<eof>