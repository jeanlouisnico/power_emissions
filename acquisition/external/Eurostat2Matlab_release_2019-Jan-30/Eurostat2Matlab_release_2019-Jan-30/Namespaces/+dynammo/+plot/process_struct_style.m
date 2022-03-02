function [out,st] = process_struct_style(st,nobj,args)
%
% Internal function, no help provided...
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

storig = st;

%% Struct input
if isstruct(st)
    
    f = fieldnames(st);
    s = struct2cell(st);
    
    % Transpose input row vectors
    for ii = 1:length(s)
        r = size(s{ii},1);
        if r==1
            if iscell(s{ii})
                s{ii} = s{ii}(:);% {'a','b'} input -> {'a';'b'}

            else % float, hopefully
                if ~all(s{ii}<=1 & s{ii}>=0) % RGB triplet input -> must stay horizontal
                    % Here we rely on the fact that anything like [0.5,0.6,0.7] is an RGB triplet, and should not be transposed
                    s{ii} = s{ii}(:);
                end
            end
        end
    end
    
    st=[f s].';
    st=st(:).';
else
    error_msg('Plot styling','User defined styling must be in struct() format...');
end

%% Missing styling

lengths = cellfun(@(x) size(x,1),st); 
nst = max(lengths);

% Each style property entered only once, or for each plotted object
if ~all(lengths==1 | lengths==nst)
	error_msg('Plot styling','Input styling structure does not have conformable dimensions...');
end
if strcmpi(args.type,'fan') 
    nobj = nst;% Only half interval boundaries needed, base line skipped in styling, by default black
end
if nst>1 && nst~=nobj
    error_msg('Plot styling','The # of plotted objects does not correspond to the dimension of the input styling structure...');
end

%% Cell output

cellin = find(cellfun(@iscell,st));
matin  = find(cellfun(@isfloat,st));

len = 1;
out = st(len(:,ones(nobj,1)),:);
lm = length(matin);
lc = length(cellin);
for ii = 1:nobj
    for jj = 1:lm
            out{ii,matin(jj)} = out{ii,matin(jj)}(min(ii,end),:);
    end
    for jj = 1:lc
            out{ii,cellin(jj)} = out{ii,cellin(jj)}{min(ii,end)};
    end
end

%% Struct styling version
for ii = 1:length(f)
    if ischar(out{1,2*ii})
        storig.(f{ii}) = out(:,2*ii);
    else
        storig.(f{ii}) = cell2mat(out(:,2*ii));
    end
end
st = storig;

end %<eof>