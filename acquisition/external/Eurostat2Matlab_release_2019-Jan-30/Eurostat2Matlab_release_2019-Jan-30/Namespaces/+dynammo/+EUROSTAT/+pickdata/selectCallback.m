function selectCallback(handles,dsd)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

selection_hans = handles.selection_hans;

%% Check the selection status

statbar = handles.statbar_text;
val = get(statbar,'String');
if strcmp(val(1:4),' !!!')
      set(statbar,'String',' !!! Current selection does not yield any data sets...');
      return
else
    val = regexp(val,'(?<=datasets: ).+?(?= \()','match');
    if eval(val{:})==0
        set(statbar,'String',' !!! Current selection does not yield any data sets...');
        return
    end
end
 
%% Body
f = fieldnames(dsd);

% Name property of the time series can be extracted from the dictionary
% -> this works only for cell input (for which technames are given)
name = '';
techname = '';

filter = struct();
% filtstr = '';
fprintf('\n\n%%%%%%%%%% Filtering criterion: \n%%%%\nfilt = struct();\n');
for ii = 1:length(selection_hans)
    
    fnow = dsd.(f{ii});
    valnow = get(selection_hans{ii},'Value');
    
    % Code generation for future use
    if length(valnow)==1
        filter.(f{ii}) = fnow{valnow}; % Single click saved in char format
        %filtstr = [filtstr 'filt.' f{ii} ' = ''' fnow{valnow} ''';'];
        fprintf(['filt.' f{ii} ' = ''' fnow{valnow,1} '''; %% ' fnow{valnow,2} '\n']);
    else
        cellnow = fnow(valnow(:),1);
        name = fnow(valnow(:),2);
        techname = fnow(valnow(:),1);
        
        %cellnow = cellnow(:);
        filter.(f{ii}) = cellnow; % Multiple selection as cell
        filtcell = '{';
        ncl = length(cellnow);
        for jj = 1:ncl
            filtcell = [filtcell '''' cellnow{jj} ''';']; %#ok<AGROW>
        end
        filtcell(end) = '}';
        %filtstr = [filtstr 'filt.' f{ii} ' = ' filtcell ';'];
        fprintf(['filt.' f{ii} ' = ' filtcell ';\n']);
    end
    
end
fprintf('%%%%\n');
fprintf('%%%%%%%%%%\n\n');

assignin('base','dbobj_series_selection',filter);
assignin('base','dbobj_series_selection_name',name);% Names need not be printed, .dic file will be ready when necessary
assignin('base','dbobj_series_selection_techname',techname);% Names need not be printed, .dic file will be ready when necessary
% fprintf(2,'\n -> .filter field updated + also "dbobj_series_selection" created in the base workspace...\n\n');
close(gcf);

%% Stack control <part II>
% In case the user closes the GUI, the function should quit
assignin('base','GUIshutdown',0);


end %<eof>