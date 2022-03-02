function out = process_user_input(default_,input_)
%
% Options resolution for the function input - fcn NOT suitable for case sensitive option names
% 
% The piece of code from the below example can be placed
% at the beginning of a function to parse the input options
% against the default set of options
% 
% EXAMPLE:
% >>>
% %% Options
% default_ = struct( ... %field	 %value       
%                       'name',  'asdf',
%                       'steps',    5,
%                       'list',   {{'a' 'a'}},
%                    );	
% 			   
% % Overlay the above default structure with the user-supplied values
% args = process_user_input(default_,varargin);
% <<<
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

if ~isempty(input_)
    input_ = cell2struct(input_(2:2:end),strrep(lower(input_(1:2:end-1)),'=',''),2);
	
	% Lower case transformation of default options
    def_values = struct2cell(default_);
    
	default_ = cell2struct(def_values,lower(fieldnames(default_)),1);
	
    options_default = fieldnames(default_);
    options_user    = fieldnames(input_);
	
    unknown_opt = ismember(options_user,options_default);
    if ~all(unknown_opt)
		error_msg('User input', ...
				  'Following argument names not recognized:', ...
				  options_user(~unknown_opt));
	end
	
    % Override the default options
    for ii = 1:length(options_user)
        default_.(options_user{ii}) = input_.(options_user{ii});
    end
    % The following cellfun works in M2014b-
    % cellfun(@(x) eval(['default_.' x '=input_.' x ';']),options_user);

	out = default_; 
	
else
    out = default_; 
end    

end