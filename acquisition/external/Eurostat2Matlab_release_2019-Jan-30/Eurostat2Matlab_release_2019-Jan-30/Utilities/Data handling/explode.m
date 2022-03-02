function explode(struct_in)
%
% Collapses a struct() of individual time series directly 
% into Matlab workspace
% - the variable names are determined according to the fieldnames
% - Base workspace contents get overwritten in case of name conflict
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~isstruct(struct_in)
   error_msg('explode','Explosion works on struct/tsobj objects only...'); 
end

basement = evalin('base','who');
contents = fieldnames(struct_in);

blacklist = contents(ismember(contents,basement));
if ~isempty(blacklist)
   warning_msg('explode','Base workspace contents overwritten...',blacklist); 
end

for ii = 1:length(contents)
   assignin('base',contents{ii},struct_in.(contents{ii})); 
end

end %<eof>