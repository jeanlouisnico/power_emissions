function out = strpad(in,pos,what,varargin)
% 
% Replaces substring with another string of different length
% regexprep/strrep does similar thing, here 'pos' vector used
% to indicate string positions to be replaced
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% >>> Handle function arguments:
default_ = struct( ... %field   %value    
                       'padding',  false ... %false = replace, true = pad
                   );
args = process_user_input(default_,varargin);
% <<<

len = length(pos);

temp = in;
if iscell(temp)
    celltemp = temp;
    for jj = 1:size(celltemp,1)
        temp = celltemp{jj};
        applyPadding();
        celltemp{jj} = temp;
    end
    temp = celltemp;
else
    applyPadding();
end

out = temp;

%% Nested function
    function applyPadding()
        if args.padding == false
            for ii = len:-1:1
                temp = strcat(temp(1:pos(ii)-1),what,temp(pos(ii)+1:end));
            end
        else
            for ii = len:-1:1
                temp = strcat(temp(1:pos(ii)-1),what,temp(pos(ii):end));
            end
        end
    end %<applyPadding>

end