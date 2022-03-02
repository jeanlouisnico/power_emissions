function varargout = struct2values(structobj,varargin)
% 
% Convertor of a struct object into a vector of !!scalars!!
% For matrices use: cell2mat(struct2cell(struct()))

% IN:  struct obj,
%      msg  ...Message to be shown as warning in case of non-numeric input
% OUT: vector of scalars
%      [OPTIONAL] vector of ok_numeric fields (different length compared to values)
%		          <logical true/false values get converted to 1/0 numeric values>

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% >>> Handle function arguments:
default_ = struct( ... %field  %value    
                       'msg',  '', ... 
                       'stop', '' ...
                   );
args = process_user_input(default_,varargin);
% <<<

% keyboard;

names = fieldnames(structobj);
Pcell = struct2cell(structobj);

ok_numeric = (structfun(@isnumeric,structobj) & structfun(@isscalar,structobj)) ...
							| structfun(@islogical,structobj); % !!! true/false conversion !!!

% Stopping crit.
if ~isempty(args.stop) && any(~ok_numeric)
    error_msg('Struct2values()',args.stop,names(~ok_numeric));
end
% Warning crit.
if ~isempty(args.msg) && ~isempty(names(~ok_numeric))
	warning_msg('Struct2values()',args.msg,names(~ok_numeric));
end

varargout{1} = cellfun(@double,Pcell(ok_numeric));
varargout{2} = ok_numeric;


% try
% 	varargout{1} = structfun(@double,structobj); % @double also converts 'true'/'false' to 1/0 
% 	if nargout == 2
% 		varargout{2} = ones(length(fieldnames(structobj)),1)==1;
% 	end
% catch
% 	Pcell = struct2cell(structobj);
% 	ok_numeric = cellfun(@isnumeric,Pcell);
% 	val = Pcell(ok_numeric);
% 	
% 	varargout{1} = val;
% 	varargout{2} = ok_numeric;
% 	
% 	names = fieldnames(structobj);
% 	if ~isempty(args.msg)
% 		warning_msg('Struct2values()',args.msg,names(~ok_numeric));
% 	end
% 	
% end

end