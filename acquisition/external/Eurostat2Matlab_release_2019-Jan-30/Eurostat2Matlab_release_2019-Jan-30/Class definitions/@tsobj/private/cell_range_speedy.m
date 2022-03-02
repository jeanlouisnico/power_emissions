function [tind,range,values,frequency,name,techname] = cell_range_speedy(varargin)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Range
% -> taken as given, no validation!
% -> Entire time indication (not just start+end) 
%    data provided on input as a column vector
range = varargin{1};
range = range(:);

%% Body
values = varargin{2};
if ~isa(values,'double')
    error_msg('Time series object generation',['In case the first argument is a cell object, ' ...
        'the second argument must be a matrix of values...']);
end

[r,n] = size(values);
nper = size(range,1);
if r==1
    values = repmat(values,nper,1);
elseif r~=nper
    error_msg('Time series object generation','Dimension mismatch on input...');
end

% Frequency determined using guinea pig
[bounds,frequency] = range2tind({range{1};range{end}});

tind = dynammo.tsobj.tind_build(frequency,bounds(1),bounds(2));

% repmat() bypass (still faster)
str = {''};
len = 1;
techname = str(len(:,ones(1,n)),1);

if nargin==2
    name = techname;
else
    name = process_name(varargin{3},n);
    
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