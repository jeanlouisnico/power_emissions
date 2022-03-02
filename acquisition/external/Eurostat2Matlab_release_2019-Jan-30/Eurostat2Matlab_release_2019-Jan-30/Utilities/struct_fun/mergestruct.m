function sout = mergestruct(varargin)
%MERGESTRUCT Merge structures with unique fields.
%
% See also struct_overlay()
% 
%   Copyright 2009 The MathWorks, Inc.

% Start with collecting fieldnames, checking implicitly
% that inputs are structures.
fn = [];
for k = 1:nargin
    try
        if ~iscell(varargin{k}) %skip empty object
            fn = [fn ; fieldnames(varargin{k})];
        end
    catch MEstruct
        throw(MEstruct)
    end
end

% Make sure the field names are unique.
if length(fn) ~= length(unique(fn))
    error('mergestruct:FieldsNotUnique',...
        'Field names must be unique');
end

% Now concatenate the data from each struct.  Can't use
% structfun since input structs may not be scalar.
c = [];
for k = 1:nargin
    try
        if ~iscell(varargin{k}) % skip empty cell objects
            c = [c ; struct2cell(varargin{k})];
        end
    catch MEdata
        throw(MEdata);
    end
end

% Construct the output.
sout = cell2struct(c, fn, 1);
