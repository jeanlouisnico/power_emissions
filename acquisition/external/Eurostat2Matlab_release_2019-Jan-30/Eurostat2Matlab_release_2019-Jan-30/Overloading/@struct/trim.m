function out = trim(s,varargin)
% 
% Suggested usage:
% trim(s,2002:2005);     -> works for all frequencies, including daily data
% trim(s,2002q2:2005q1); -> quarterly data
% trim(s,2002m2:2005m1); -> monthly data
% 
% trim(s,'2002-02-01:2002-02-20'); -> daily data <"-" must be used as delimiter!!>
% trim(s,'2002-02'); -> entire February data set
% trim(s,'2002-02:2003-01');
% trim(s,2002:2005);
% 
% Frequency specification (3rd argument)
% trim(s,2002:2005,'q'); -> only quarterly series will be processed
%                        -> other frequencies will also be returned (though untrimmed)
% 
% !!!
% NOTE: trim() applied directly to a time series object trims all leading/trailing NaNs,
%       trim() applied to a structure of TS objects will use trimNaNs() internally, which
%              will result in aligned time spans of all TS objects
% !!!
% 
% INPUT: s       ...structure of time series objects 
%        [range] ...time window to be applied on each time series (other data types are ignored)
%        [freq]  ...time series frequency type specification ('all'|'y'|'q'|'m'|'d'|)
%
% OUTPUT: structure in which the specified time series objects have aligned time span

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;


switch nargin
    case 1
        % Still can trim away the NaNs of each struct field
        fields = fieldnames(s);
        for ifield = 1:length(fields)
            if isa(s.(fields{ifield}),'tsobj')
                s.(fields{ifield}) = trim(s.(fields{ifield}));
            end
        end
        out = s;
        return
        
    case 2
        range = varargin{1};
        freq_chosen = 'all';
        
    case 3
        range = varargin{1};
        freq_chosen = varargin{2};
        
    otherwise
        error_msg('Struct trimming','Too many input arguments...');
end

%%

out = s;
names = fieldnames(out);
if ~strcmp(freq_chosen,'all')
    for ii = 1:length(names)
        if isa(out.(names{ii}),'tsobj')
            if strcmpi(out.(names{ii}).frequency,freq_chosen)
                out.(names{ii}) = trimNaNs(out.(names{ii}),range);
            end
        end
    end
else
    for ii = 1:length(names)
        if isa(out.(names{ii}),'tsobj')
            out.(names{ii}) = trimNaNs(out.(names{ii}),range);
        end
    end
end

end %<eof>