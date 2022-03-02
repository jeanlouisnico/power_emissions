function out = dictionary(varargin)
% function structobj = dictionary(structobj,dict,varargin)
%
% Translation among name lists
% Useful in DB comparison - makes fields aligned
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #1 - <struct input> modification of field names according to dict
% 
% INPUT: structobj ...original struct() with wrong names in it
%        dict      ...cell with translations (2 columns)
%       [to_remove]...optional argument, removes/retains old fields
% 
% OUTPUT: modified structobj with renamed fields
% 
% EXAMPLE: 
% dict = {'dot_x','dot_X'; 
%             'i',    'R'},    
%         'dot_x' from model #1 becomes 'dot_X' comparable to 'dot_X' from model #2
%         'i' becomes 'R'
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% #2 - <cell list input> multi-column cell converted to a single vector 
% 
% INPUT: cellobj ...original cell() dictionary
%        colnum  ...numbering of 
%       [to_remove] ...not applicable for cell input!
% 
% EXAMPLE: 
% dict = {'dot_x'
%         {'i','R'}
%         'b'} -> both models containdot_x and b, 1st model needs 'i', 2nd model needs 'R'
% colnum=1 yields
%          {'dot_x';'i';'b'}
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~any(nargin==[2;3])
    error_msg('Translation','Two input arguments are mandatory');
end

%% Body

if isstruct(varargin{1})
    structobj = varargin{1};
    dict = varargin{2};
    if nargin==3
        to_remove = varargin{3};
    else
        to_remove = 1;
    end
    
    % Dictionary

    nitems = size(dict,1);
    for ii = 1:nitems
       % struct1 taken as base
       structobj.(dict{ii,2}) = structobj.(dict{ii,1});
    end

    if to_remove
       structobj = rmfield(structobj,dict(:,1)); 
    end
    
    out = structobj;
    return
    
elseif iscell(varargin{1}) % -> cell list on input
    
    % All cell contents will be replaced with one of its elements
    cellobj = varargin{1};
    colselect = varargin{2};
    dict = cellfun(@iscell,cellobj);
    if any(dict)
        cellobj(dict) = cellfun(@(x) x{colselect},cellobj(dict),'UniformOutput',false);
        
    elseif colselect>1
        out = varargin{1};
        return
        %error_msg('Translation','Input dictionary contains only one column...');    
        
    end
    
    out = cellobj;
    return
    
else
    error_msg('Translation','The first argument must be a struct/cell object...');
    
end

end %<eof>