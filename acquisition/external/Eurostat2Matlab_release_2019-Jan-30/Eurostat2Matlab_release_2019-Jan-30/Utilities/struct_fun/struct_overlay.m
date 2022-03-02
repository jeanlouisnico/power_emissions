function out = struct_overlay(in_old,in_new,varargin)
% 
% Rewrites struct fields
% use 'append' option if new fields allowed

% COMPLEMENT: mergestruct.m for fieldnames(in_old) do not 
%                       overlap with fieldnames(in_new)

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% >>> Handle function arguments:
default_ = struct( ... %field   %value    
                       'append',  true, ...
					   'msg',     '' ...
                   );
args = process_user_input(default_,varargin);
% <<<

new_fields = fieldnames(in_new);
old_fields = fieldnames(in_old);
extra_fields = new_fields(~ismember(new_fields,old_fields));

 % new struct() names appended to the original
if ~args.append && ~isempty(extra_fields)
	error_msg('Struct_overlay()',args.msg,extra_fields);
end

% Override default values
for ii = 1:length(new_fields)
    in_old.(new_fields{ii}) = in_new.(new_fields{ii});
end
% >>> This cellfun used to work under M2014b-
%     cellfun(@(x) eval(['in_old.' x '=in_new.' x ';']),new_fields);

out = in_old;

end