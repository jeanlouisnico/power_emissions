function titlesReplace(fig,newtits)
%
% Batch replacement of all titles within a figure, function works on 
% gobj.fig1 input object structure <gobj.fig> has only 1 subplot and
% thus its title can be replaced by the user manually by changing gobj.title
% properties.
%
% INPUT: fig ...handle to a figure in whatever format (standard Matlab figures NOT allowed)
%        newtits ...cell of new titles
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input validation
if ~isstruct(fig) || ~isfield(fig,'fig1')
   error_msg('Titles replacement',['<gobj.fig1> input format expected for ' ...
       'titles batch replacement. Use ''title'' option for single plots in <gobj.fig> format...']); 
end

%% Input figure
[~,nfigs] = dynammo.plot.getHandle(fig);
if nfigs>1
    error_msg('Titles replacement','Multiple input figures should be processed one by one...');
end

%% Body
subs = sublist(fieldnames(fig.fig1),'sub','<');
nsubs = length(subs);
if nsubs~=length(newtits)
   error_msg('Titles replacement',['The # of provided titles (' sprintf('%g',length(newtits)) ') ' ...
                                   'does not match the # of subplots (' sprintf('%g',nsubs) ')']); 
end
for isub = 1:nsubs
    set(fig.fig1.(['sub' sprintf('%g',isub)]).title,'String',newtits{isub});
end

end %<eof>