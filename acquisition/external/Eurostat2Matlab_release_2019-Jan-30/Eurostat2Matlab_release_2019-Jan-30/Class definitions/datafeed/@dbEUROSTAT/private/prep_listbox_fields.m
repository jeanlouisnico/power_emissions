function [newfields,maxlength,nakedFields] = prep_listbox_fields(toclevel,buf1)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

fds = fieldnames(toclevel);
nfds = length(fds);

expl = cell(nfds,1); % with 1 empty field
codes = cell(nfds,1);% with 1 empty field
tab_ind = zeros(nfds,1);% with 1 empty field
linkReady = zeros(nfds,1);% with 1 empty field
for ii = 1:nfds%:-1:1
    fnow = toclevel.(fds{ii});
    if ~isstruct(fnow)
        % title is a string, but is not processed 
    else
        expl{ii} = fnow.title;
        codes{ii} = fds{ii};
        
        % Check if the next child is another subtree, or a table
        if isfield(fnow,'downloadLink')
            tab_ind(ii,1) = 1;
            %keyboard;
            if ~isempty(fnow.downloadLink.bulk)
                linkReady(ii,1) = 1;
            end
        end
    end
end

empties = cellfun('isempty',codes);
codes = codes(~empties);
expl = expl(~empties);
tab_ind = tab_ind(~empties,1);
linkReady = linkReady(~empties,1);

% Alignment
maxlength = max(cellfun('length',codes));
newfields = cell(length(codes),1);
nakedFields = cell(length(codes),1);
for jj = 1:length(codes)
        cand = codes{jj};
        diff_length = maxlength-length(cand) + buf1;% Buffer
        cand = [cand repstr('&nbsp;',diff_length)];  %#ok<AGROW>
        
        % >>> Space padding solved by HTML embedding <<<
        if tab_ind(jj,1) == 1
            if linkReady(jj,1)
                %newfields{jj} = sprintf('<HTML><BODY color="%s">%s</BODY></HTML>','blue', [cand expl{jj}]);%FF9900
                newfields{jj} = sprintf('<HTML><BODY>%s</BODY></HTML>', ['<a color="0099FF">[link ready]</a> ' cand expl{jj}]);%FF9900
            else
                %newfields{jj} = sprintf('<HTML><BODY color="%s">%s</BODY></HTML>','888888', [cand expl{jj}]);%FF9900
                newfields{jj} = sprintf('<HTML><BODY>%s</BODY></HTML>', ['<a color="FF0000">[link N/A]&nbsp;&nbsp;</a> ' cand expl{jj}]);%FF9900
            end
            nakedFields{jj} = codes{jj};
        else
            %newfields{jj} = sprintf('<HTML><BODY color="%s">%s</BODY></HTML>','black',[cand expl{jj}]);
            newfields{jj} = sprintf('<HTML><BODY>%s</BODY></HTML>',[cand expl{jj}]);
            nakedFields{jj} = codes{jj};
        end
        
end

end %<eof>