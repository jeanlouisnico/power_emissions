function varargout = export(in,varargin)
%
% Exporter for a struct() of time series objects
%
% SEE ALSO: tsobj/export(), cell/export()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
%args = dynammo.options.export(varargin{:});

%% Body

fields = fieldnames(in);
tsobjind = structfun(@(x) isa(x,'tsobj'),in);

if ~any(tsobjind)
   varargout{1} = builtin('export',in,varargin{:}); 
   return
end

% Retain tsobj() only
fields = fields(tsobjind);
in = in * fields;

% Check if univariate tsobj() only on input
for ii = 1:length(fields)
    if size(in.(fields{ii}).values,2) > 1
       error_msg('Data export','Collections of time series found in given struct fields, these should be processed individually...'); 
    end
end

in = implode(in);

if isstruct(in)
    error_msg('Data export',['Structure of time series objects contains data with mixed ' ...
                            'frequencies. The usual procedure would be to use the implode() ' ...
                            'function and then generate data file for each frequency separately...']);
else
    % This time tsobj/export() should be called
    %export(in,args);
     export(in,varargin{:});
                  
end

end %<eof>