function warning_msg(header_,explanation,varargin)
%
% Wrapper for the internal warning() function with additional formating
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
		
length_ = length(explanation);
if length_ <= col_width
	expl_to_print = ['%%%     ' explanation sprintf('\n')];
else
	expl_new = explanation;
	spaces_ = find(isspace(explanation));
	for ii = ceil(length_/col_width)-1:-1:1
		expl_new = strpad(expl_new,spaces_(max(find(spaces_<=col_width*ii))),'!@#$%^&*','padding=',false);
	end
	expl_new = cell_dlm_explode(expl_new,'\!\@\#\$\%\^\&\*');
% keyboard;
	expl_to_print = [];
	for ii = 1:length(expl_new)
		expl_to_print = [expl_to_print '%%%     ' expl_new{ii} sprintf('\n')];
	end
end

w = warning;
warning on;
if isempty(varargin)
%     dbstack
    if isunix
        warning([sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| ' header_ ' warning: ' sprintf('\n') ...
                             expl_to_print ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']); %#ok<WNTAG>
    else
        warning([sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| <strong>' header_ ' warning</strong>: ' sprintf('\n') ...
                             expl_to_print ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']); %#ok<WNTAG>
    end
else
    list_ = varargin{:};
%     dbstack
    if iscell(list_)

		black_list_to_print = [];
        for ii = 1:length(list_)
            if isa(list_{ii},'double')
                list_{ii} = sprintf('%.5f',list_{ii});
            end
			black_list_to_print = [black_list_to_print '%%%     ' sprintf('\t\t"%s"\n',list_{ii})]; %#ok<AGROW>
        end
        if isunix
            warning([sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| ' header_ ' warning: ' sprintf('\n') ...
                             expl_to_print ...
                             black_list_to_print ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']); %#ok<WNTAG>
        else
            warning([sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| <strong>' header_ ' warning</strong>: ' sprintf('\n') ...
                             expl_to_print ...
                             black_list_to_print ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']); %#ok<WNTAG>
        end
    else
        if isa(list_,'double')
            list_ = sprintf('%.5f',list_);
        end
        if isunix
            warning([sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| ' header_ ' warning: ' sprintf('\n') ...
                             expl_to_print ...
                             '%%%     ' sprintf('\t\t"%s"\n',list_) ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);  %#ok<WNTAG>
        else
            warning([sprintf('\n') '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' sprintf('\n') ...
                             '%%% ||| <strong>' header_ ' warning</strong>: ' sprintf('\n') ...
                             expl_to_print ...
                             '%%%     ' sprintf('\t\t"%s"\n',list_) ...
                             '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);  %#ok<WNTAG>
        end
    end
end
warning(w);
% '%%%     ' sprintf('\t\t"%s"\n',to_print) ...
end