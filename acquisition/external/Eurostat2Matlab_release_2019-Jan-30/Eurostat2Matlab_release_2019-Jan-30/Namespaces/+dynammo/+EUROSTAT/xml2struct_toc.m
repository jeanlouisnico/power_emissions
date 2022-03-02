function tree = xml2struct_toc(args,TOClink)
%
% XML reader for EUROSTAT Table of contents
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

this = struct();

%% Options

lang = args.language;

%% XML parser

% Make sure we have enough memory
max_allocation = java.lang.Runtime.getRuntime.maxMemory;% -> maxMemory is close to Java Heap Allocation, weird
                                                        % -> totalMemory is even smaller :(
if (max_allocation/1e6)<350
    error_msg('Out of memory',['Allocation of JAVA heap memory is ' ...
                            'insufficient (currently ' sprintf('%.0f',floor((max_allocation/1e6))) ' MB). Click "Preferences" and navigate to ' ...
                            '"General/Java Heap Memory" and increase the memory allocation ' ...
                            'manually (500 MB should be enough). Do not forget to restart your Matlab ' ...
                            'session for the changes to take effect!']);    
end

try
    xml = xmlread(args.xmlfile);
catch
    error_msg('XML parser',['Problem with obtaining the Table of Contents. ' ...
                            'One source of problems might be insufficient JAVA ' ...
                            'Heap Memory allocation. Also, try the following link in ' ...
                            'your web browser to see what might be the ' ...
                            'cause of problems:'],TOClink);    
end

%% Stack control

st = length(dbstack());

%% Tree generation
mainnode = xml.getChildNodes.item(0);
tree = struct();

% Desired sub-tree
br1 = mainnode.getChildNodes;
nbranches = br1.getLength;
for ibranch = 1:nbranches
    subbr = br1.item(ibranch-1);% each nt:branch
                                % Some of these white space junk
    if ~strcmp(subbr.getNodeName,'#text')
        subbr2 = subbr.getChildNodes;
        nsubbr = subbr2.getLength;
        code = '';
        for isubbr = 1:nsubbr % Always nsubbr > 0
            subbr3 = subbr2.item(isubbr-1); % 3x title, code + children                                
            if ~strcmp(subbr3.getNodeName,'#text')
                txt = char(subbr3.getTextContent);
                switch char(subbr3.getNodeName)
                    case 'nt:title'
                        attrib = subbr3.getAttributes;
                        if strcmp(char(attrib.item(0).getValue),lang)
                           title = txt;
                        end
                    case 'nt:code'
%                         if any(strcmp(txt,wanted)) % User selection of data here!
                           code = txt;
%                         else
%                            break
%                         end
                    case 'nt:children'
                        kidsnow = subbr3.getChildNodes;
                    otherwise
                        error_msg('Database object','XML structure of EUROSTAT has changed, adjust the code accordingly...');
                end
            end
        end
        
        % User wanted this subtree
        if ~isempty(code)
            % Process each child + update the tree
            nlast = kidsnow.getLength;
            tree.(code).title = title;
            for ilast = 1:nlast
                itemnow = kidsnow.item(ilast-1);
                if ~strcmp(itemnow.getNodeName,'#text')
                    [tmp,~] = node2struct(itemnow,lang,st);
%                     keyboard;
                    tree.(code) = mergestruct(tree.(code),tmp);
                end
            end
%             keyboard;
        end
        
    end
end

% keyboard;

%% Generate TOC object
mainfields = fieldnames(tree);
for ifield = 1:length(mainfields)
   this.(mainfields{ifield}) = tree.(mainfields{ifield});
end

%% Creation Date
tree = this;
attrib = mainnode.getAttributes;
tree.creationDate = char(attrib.item(0).getValue);

%% Support functions

function [s,id] = node2struct(node,lang,st)

%     keyboard;
    
%     id = char(node.getNodeName);

    id =      node.getNodeName;
%     if ~ischar(id)
%        keyboard; 
%     end
%     switch id
%         case 'nt:branch'
	if equals(id,'nt:branch')
            % Set of children
            ch = node.getChildNodes;
            nch = ch.getLength;
            
            % Process each child
            res_title = '';
            for ich = 1:nch
                if ~equals(ch.item(ich-1).getNodeName,'#text') %~strncmp(ch.item(ich-1).getNodeName,'#text',5) %to_take(ich)
                   [res,is] = node2struct(ch.item(ich-1),lang,st);%, ...
                   
                   %switch is
                        %case '#text'
                   if equals(is,'#text')
                       
                           % ... no action
                       %case 'nt:title'
                   elseif equals(is,'nt:title')
                           if ~isempty(res)
                                res_title = res;
                                switch length(dbstack())
                                    case st+1
                                        disp(['<strong>' res '</strong>']);
                                    case st+3
                                        disp(['   -> ' res]);
%                                     case st+5
%                                         disp(res);
                                end
                           end
                       %case 'nt:code'
                   elseif equals(is,'nt:code')    
                           res_code = res;
                       %case 'nt:children'
                   elseif equals(is,'nt:children')
                           res_ch = res;
                       %otherwise
                   else
                           error_msg('EUROSTAT table of contents','Unknown XML identifier under "nt:branch"',is);
                   end
                end
            end
           
            % Output object
            try 
                res_code = strrep(res_code,'-','_');
                s.(res_code).title = res_title;
                try
                    % Labor market data were no longer available the other day
                    s.(res_code) = mergestruct(s.(res_code),res_ch);
                end
            end
            return
           
        %case 'nt:children'
        elseif equals(id,'nt:children')
            
            % Set of children
            ch = node.getChildNodes;
            nch = ch.getLength;
        
            % Process each child
            s = struct();
            for ich = 1:nch
                if ~equals(ch.item(ich-1).getNodeName,'#text') %~strncmp(ch.item(ich-1).getNodeName,'#text',5) %to_take(ich)
                   [res,is] = node2struct(ch.item(ich-1),lang,st);%, ...
                   %switch is
                       %case '#text'
                   if equals(is,'#text')    
                          % ...no action 
                       %case {'nt:branch';'nt:leaf'}
                   elseif equals(is,'nt:branch') || equals(is,'nt:leaf')
                          s = mergestruct(s,res); 
                       %otherwise
                   else
                           error_msg('EUROSTAT table of contents','Unknown XML identifier under "nt:branch"',is);
                   end
                end
            end
            return
            
        %case 'nt:leaf'
        elseif equals(id,'nt:leaf')
            
            % Set of children
            ch = node.getChildNodes;
            nch = ch.getLength;            
            
            % Process each child
            res_title = '';
            res_unit = '';
            res_sDesc = '';
            res_meta = '';
            res_link = '';
            res_link_sdmx = '';
            for ich = 1:nch
                if ~equals(ch.item(ich-1).getNodeName,'#text')
                   [res,is] = node2struct(ch.item(ich-1),lang,st);
                   
                       %case '#text'
                       if equals(is,'#text')
                           % ...no action
                           %case 'nt:title'
                       elseif equals(is,'nt:title')
                           if ~isempty(res)
                               res_title = res;
                           end
                           %case 'nt:code'
                       elseif equals(is,'nt:code')
                           res_code = res;
                           %case 'nt:lastUpdate'
                       elseif equals(is,'nt:lastUpdate')
                           res_lUp  = res;
                           %case 'nt:lastModified'
                       elseif equals(is,'nt:lastModified')
                           res_lMo  = res;
                           %case 'nt:dataStart'
                       elseif equals(is,'nt:dataStart')
                           res_dS   = res;
                           %case 'nt:dataEnd'
                       elseif equals(is,'nt:dataEnd')
                           res_dE   = res;
                           %case 'nt:values'
                       elseif equals(is,'nt:values')
                           res_val   = res;
                           %case 'nt:unit'
                       elseif equals(is,'nt:unit')
                           if ~isempty(res)
                               res_unit = res;
                           end
                           %case 'nt:shortDescription'
                       elseif equals(is,'nt:shortDescription')
                           if ~isempty(res)
                               res_sDesc = res;
                           end
                           %case 'nt:metadata'
                       elseif equals(is,'nt:metadata')
                           if ~isempty(res)
                               res_meta = strrep(res,'http://','https://');
                           end
                           %case 'nt:downloadLink'
                       elseif equals(is,'nt:downloadLink')
                           if strncmp(res,'@',1)
                               res_link_sdmx = res(2:end);
                           else
                               res_link = res;
                           end
                       else
                           error_msg('EUROSTAT table of contents','Unknown XML identifier under "nt:branch"',is);
                       end
                end
            end
            
            % Output object
            res_code = strrep(res_code,'-','_');
            s.(res_code).title = res_title;
            s.(res_code).lastUpdate = res_lUp;
            s.(res_code).lastModified = res_lMo;
            s.(res_code).dataStart = res_dS;
            s.(res_code).dataEnd = res_dE;
            s.(res_code).values = res_val;
            s.(res_code).unit = res_unit;
            s.(res_code).shortDescription = res_sDesc;
            s.(res_code).metadata = res_meta;
            s.(res_code).downloadLink.sdmx = res_link_sdmx;
            s.(res_code).downloadLink.bulk = res_link;
            return
            
        %case 'nt:title'
        elseif equals(id,'nt:title')
            
            attributes = node.getAttributes;
            %charval = char(attributes.item(0).getValue);
            %if ~strcmp(charval,lang)
            %    s = '';% Whole branch discarded
            %else
            %    s = char(node.getTextContent);% Only title string on output
            %end
            charval = attributes.item(0).getValue;
            if equals(charval,lang)
                s = char(node.getTextContent);% Only title string on output
                %disp(s);
            else
                s = '';% Whole branch discarded
            end
            return
            
        %case 'nt:code'
        elseif equals(id,'nt:code')
            
            s = char(node.getTextContent);
            return

        %case {'nt:unit';'nt:shortDescription'}
        elseif equals(id,'nt:unit') || equals(id,'nt:shortDescription')
            
            attributes = node.getAttributes;
            charval = attributes.item(0).getValue;
            if equals(charval,lang)
                s = char(node.getTextContent);% Only title string on output
            else
                s = '';% Whole branch discarded
            end
            return
        
        %case {,'nt:downloadLink'}
        elseif equals(id,'nt:downloadLink')
            attributes = node.getAttributes;
            s = char(node.getTextContent);
            charval = attributes.item(0).getValue;
            if equals(charval,'sdmx')
               s = ['@' s]; % Encoding
            else
               s = char(node.getTextContent); 
            end
            s = strrep(s,'http://','https://');
            return  
            
        %case '#text'
        elseif equals(id,'#text') 
            % No data here, but costly to remove (in terms of time)
            s = '';
            return
            
        %case {'nt:lastUpdate';'nt:lastModified';'nt:dataStart';'nt:dataEnd';'nt:values';'nt:metadata'}
        elseif equals(id,'nt:lastUpdate') || equals(id,'nt:lastModified') || ...
               equals(id,'nt:dataStart') || equals(id,'nt:dataEnd') || ...
               equals(id,'nt:values') || equals(id,'nt:metadata')
            s = char(node.getTextContent);
            return 
            
        %otherwise
        else
            error_msg('Database object','Unknown XML identifier: ',id);
	end
    
end %<node2struct>

end %<eof>