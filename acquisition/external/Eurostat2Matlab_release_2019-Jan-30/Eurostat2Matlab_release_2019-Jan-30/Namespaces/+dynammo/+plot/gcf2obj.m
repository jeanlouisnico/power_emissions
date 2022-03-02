function out = gcf2obj(f)
%
% Generates proper object structure of a plot in the following format:
% out.fig1.handle
% out.fig1.sub1.handle
%[out.fig1.sub1.legend] ...optional
%[out.fig1.suptitle]    ...optional
% 
% 'data' field is omitted (not needed for legend re-creation), other stuff, such as 'highlight'
% should be covered by its parent subplot, no extra field generated in the output structure
%
% INPUT: figure handle
%
% OUTPUT: structure of object handles 
%
% See also: dynammo.plot.gobj_transform()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Reveal the contents

out = struct();

out.fig1.handle = f;% This is 2014b+ compatible

ch = get(f,'children');
lg = [];
suptit = [];
counter = 1;
for ii = 1:length(ch)
    
    % Save the legend handle
    if strcmpi(get(ch(ii),'tag'),'legend')
       lg = ch(ii);
       
       % >>> M2014b+ fix
       usrdt = get(lg,'UserData');
       if isempty(usrdt)
          error_msg('Legend inheritance','Legend for standard Matlab plots must be generated using legend2() function...'); 
       end
       % <<<
       
       continue
       
    % Save the handle of super title   
    elseif strcmpi(get(ch(ii),'tag'),'suptitle')
       suptit = ch(ii);
       continue
       
    end
    
    % Regular subplots
    %out.fig1.(['sub' sprintf('%.0f',counter)]).handle = ch(ii);
     out.fig1.(sprintf('sub%.0f',counter)).handle = ch(ii);
    counter = counter + 1;
    
end

%% Legend + super title

if ~isempty(suptit)  
  out.fig1.suptitle = get(suptit,'children'); 
end
if ~isempty(lg)  
  out.fig1.sub1.legend = lg; 
end

end %<eof>