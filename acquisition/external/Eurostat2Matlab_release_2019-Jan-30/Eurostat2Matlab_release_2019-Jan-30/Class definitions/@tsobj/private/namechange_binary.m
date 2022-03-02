function out = namechange_binary(core1,operator,core2)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% INPUT ...core1, core2 -> cell   for tsobj.names
%                       -> scalar for numeric entries

%% Scalar inputs

if isscalar(core1) && isa(core1,'double') 
    
    tscoll = length(core2);
    out = core2;
    for ii = 1:tscoll
        if isempty(core2{ii})
            core2{ii} = '#';
        end
        out{ii} = strcat('(',num2str(core1),'[',operator,']',core2{ii},')');
    end
    return

end

if isscalar(core2) && isa(core2,'double')
    
    tscoll = length(core1);

    out = core1;
    for ii = 1:tscoll
        if isempty(core1{ii})
            core1{ii} = '#';
        end
        out{ii} = strcat('(',core1{ii},'[',operator,']',num2str(core2),')');
    end
    return 

end

%% Both time series

if isa(core1,'cell') && isa(core2,'cell')
    
    if length(core1)==1 && length(core2)==1
        if isempty(core1{:})
            core1 = {'#'};
        end
        if isempty(core2{:})
            core2 = {'#'};
        end

        out = {['(',core1{:},'[',operator,']',core2{:},')']};
        return
    else
        % Let's not test the input, should be ok
        if any(cellfun('isempty',core1))
            core1{cellfun('isempty',core1)} = '#';
        end
        if any(cellfun('isempty',core2))
            core2{cellfun('isempty',core2)} = '#';
        end
        out = strcat('(',core1,'[',operator,']',core2,')');
        return
        %dynammo.error.tsobj('Time series collections allowed only in case of scalar binary operations!');
    end
end

%% Dead end
dynammo.error.tsobj('Binary assignment not supported...');

end % <eof>