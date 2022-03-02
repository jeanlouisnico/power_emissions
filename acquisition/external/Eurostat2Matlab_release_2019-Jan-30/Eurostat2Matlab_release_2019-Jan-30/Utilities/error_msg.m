function error_msg(header_,explanation,varargin)
%
% Wrapper for the internal error() function with additional formating
% 
% INPUT: header_ ...Short description for the problem
%        explanation ...Longer description of the problem (what happened)
%       [varargin] ...Potential list of problematic items
% 
% OUTPUT: none, only the command window print out
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

col_width = 55;
		
%% Header line
if isunix
    header_ = strcat(header_,' error'); 
else
    header_ = strcat('<strong>',header_,' error</strong>'); 
end

%% Explanation lines
length_ = length(explanation);
if ischar(explanation)
    if length_ <= col_width
        expl_to_print = ['%%%     ' explanation sprintf('\n')];
    else
        expl_new = explanation;
        spaces_ = find(isspace(explanation));
        for ii = ceil(length_/col_width)-1:-1:1
            expl_new = strpad(expl_new,spaces_(max(find(spaces_<=col_width*ii))),'!@#$%^&*','padding=',false);
        end
        expl_new = cell_dlm_explode(expl_new,'\!\@\#\$\%\^\&\*');

        expl_to_print = [];
        for ii = 1:length(expl_new)
            expl_to_print = [expl_to_print '%%%     ' expl_new{ii} sprintf('\n')]; %#ok<AGROW>
        end
    end
else
    expl_cont = '';
    for isegm = 1:length_
        length_segm = length(explanation{isegm});
        if length_segm <= col_width
            if isegm~=1
                expl_to_print = ['%%% [' sprintf('%g',isegm-1) '] ' explanation{isegm} sprintf('\n')];
            else
                expl_to_print = ['%%% ' explanation{isegm} sprintf('\n')];
            end
        else
            expl_new = explanation{isegm};
            spaces_ = find(isspace(explanation{isegm}));
            for ii = ceil(length_segm/col_width)-1:-1:1
                expl_new = strpad(expl_new,spaces_(max(find(spaces_<=col_width*ii))),'!@#$%^&*','padding=',false);
            end
            expl_new = cell_dlm_explode(expl_new,'\!\@\#\$\%\^\&\*');

            expl_to_print = [];
            for ii = 1:length(expl_new)
                if ii==1 && isegm~=1
                    expl_to_print = [expl_to_print '%%% [' sprintf('%g',isegm-1) '] ' expl_new{ii} sprintf('\n')]; %#ok<AGROW>
                else
                    expl_to_print = [expl_to_print '%%%     ' expl_new{ii} sprintf('\n')]; %#ok<AGROW>
                end
            end
        end        
        expl_cont = [expl_cont expl_to_print]; %#ok<AGROW>
    end
    expl_to_print = expl_cont;
end

%% Stack control
% keyboard;
stack = dbstack('-completenames');
nstack = size(stack,1);
if nstack>1
    if isempty(strfind(stack(2).file,'error_'))
        msg.stack.file = stack(2).file;
        msg.stack.name= stack(2).name;
        msg.stack.line = stack(2).line;
    else
        msg.stack.file = stack(3).file;
        msg.stack.name= stack(3).name;
        msg.stack.line = stack(3).line;
    end

    % Command window print out
    dynammo_error_stack.nstack = nstack;
    dynammo_error_stack.entries = stack(2:nstack);
    assignin('base','dynammo_error_stack',dynammo_error_stack);
%     fprintf(2,'\n\n%s',' [+] <a href="matlab: dynammo.error.show_stack()">Stack explosion</a> ');                
    
else
    msg.stack.file = stack.file;
    msg.stack.name= stack.name;
    msg.stack.line = stack.line;    
end
fprintf('\n');

%% Message ending

if nstack>1
    msg_end =  [sprintf('\n\n') ...
                         sprintf('%s',' [+] <a href="matlab: dynammo.error.show_stack()">Stack explosion</a> ')];
else
    msg_end = '';
end

%% Throw error
if isempty(varargin)
    msg.message = [sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                         '%%% ||| ' header_ ': ' sprintf('\n') ...
                         expl_to_print ...
                         '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' msg_end];
    fprintf('\n');
    error(msg);
else
    list_ = varargin{:};
    
    % blacklist to base workspace
    assignin('base','dynammo_blacklist',list_);

    if iscell(list_)

		black_list_to_print = [];
		for ii = 1:length(list_)
            if isa(list_{ii},'double')
                list_{ii} = sprintf('%.5f',list_{ii});
            end
            black_list_to_print = [black_list_to_print '%%%     ' sprintf('\t\t"%s"\n',list_{ii})]; %#ok<AGROW>
		end
        msg.message = [sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| ' header_ ': ' sprintf('\n') ...
                             expl_to_print ...
                             black_list_to_print ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' msg_end];
        fprintf('\n');
        error(msg);
    else
        if isa(list_,'double')
            list_ = sprintf('%.5f',list_);
        end
        msg.message = [sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| ' header_ ': ' sprintf('\n') ...
                             expl_to_print ...
                             '%%%     ' sprintf('\t\t"%s"\n',list_) ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' msg_end];
        fprintf('\n');
        error(msg);
    end
end
 
end