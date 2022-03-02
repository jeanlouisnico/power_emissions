function dsd_filter_validator(handles,filtering_sets,dsd)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

selection_hans = handles.selection_hans;

%% Body
fields = fieldnames(dsd);
nf = length(fields);

vals = cell(nf,1);
multicat = 0;
for ii = 1:nf
    fnow = dsd.(fields{ii});
    codesnow = fnow(:,1);
    val = get(selection_hans{ii},'Value');
%     if length(codesnow)>1
%         if any(val==1) % --- selected
%            count = '0';
%            return
%         end
%         val = val-1;% Skip ---
%     end
    if length(val)>1
        if multicat>0 % Multiple selection already made
%             val = 1;
%             set(selection_hans{ii},'Value',val);% Make it a single selection
            set(handles.statbar_text,'String',' !!! Multiple selection is allowed in one of the categories at most...');
            return
            
        end
        multicat = ii;
        valmulti = val(:);
        vals{ii,1} = codesnow(valmulti);
    else
        vals{ii,1} = codesnow{val};
    end
    
end

%% Validation one by one

filtnow = filtering_sets;

count = 1;% reinitialized again in 'multicat' case

% Only single selections
for ii = 1:nf    
    if ii~=multicat 
        where = find(strcmp(vals{ii,1},filtnow(:,ii)));
        if ~isempty(where)
            filtnow = filtnow(where,:);
        else
            count = '0';
            updateListener();
            return
        end
    end
end

% If multiple selection was made, process it now after the singles
if multicat>0 
    multi = vals{multicat,1};
    nmulti = length(multi);
    missing = zeros(nmulti,1);
    for ii = 1:nmulti
        if ~any(strcmp(multi{ii},filtnow(:,multicat)))
            missing(ii,1) = 1;
        end
    end
    count = nmulti - sum(missing);
    
    % Recheck if all selected items yield some data
    if any(missing==1) %selected_but_nonexistent>0
        warning_msg('Data selection', ...
                    'Data series non-existent for some of the chosen items:', ...
                                            multi(missing==1)); 

        % Non-existent data must be deselected
        % -> BUT make sure at least one item is selected
        if ~all(missing==1)
            set(selection_hans{multicat},'Value',valmulti(missing==0));
        else
            % Keep only the first one as selected
            set(selection_hans{multicat},'Value',valmulti(1));
        end
        
    end
    
    
end

%% Output
count = sprintf('%.0f',count);
updateListener();

%% Nested function

    function updateListener()
        %count = sprintf('%.0f',count);
        set(handles.statbar_text,'String',['# of selected datasets: ' count ' (out of ' sprintf('%.0f',size(filtering_sets,1)) ' available)']);
        
    end %<updateListener>

end %<eof>