function search_field_callback(src,evnt) %#ok<INUSL>
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Access to globals
% global dbobj_set;

%% ENTER pressed

if strcmpi(evnt.Key,'return')
    
    search_field_internal();
    
end
        
end %<eof>