function [tind,range,values,frequency,name,techname] = generate_tsobj(varargin)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

values = process_values(varargin{2});
[tind,range,frequency] = process_range( varargin{1});
t = length(tind);
[n,c] = size(values);
if t ~= n
    if n == 1
        values = repmat(values,t,1);
    else
        dynammo.error.tsobj(['# of implied time periods (' sprintf('%d',t) ') does ' ...
            ' not match the data dimension (' ...
            sprintf('%d',n) ')...']);
    end
end

% Names/technames
% repmat() bypass (still faster)
str = {''};
len = 1;
techname = str(len(:,ones(1,c)),1);

if nargin==2
    name = techname;
else
    name = process_name(varargin{3},c);
    
    % Inheritance of valid variable names
    if dynammo.compatibility.M2014a
        techname = matlab.lang.makeValidName(name);
    else
        tmp_ = name;
        validnames = cellfun(@isvarname,name);
        tmp_(~validnames) = genvarname(repmat({'xvar'},sum(~validnames),1));
        techname = tmp_;
    end
   
end

end %<eof>