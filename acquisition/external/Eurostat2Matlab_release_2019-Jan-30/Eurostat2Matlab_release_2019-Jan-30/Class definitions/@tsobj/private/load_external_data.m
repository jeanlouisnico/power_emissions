function [tind,range,values,frequency,name,techname] = load_external_data(varargin)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input validation

if nargin==1
    args.filename = varargin{1};
    args.dateformat = 'auto';
    if ~isempty(strfind(args.filename,'.xls')) % .xlsx and alike also this way
        args.sheetname = '';% Option redundant if csvload()
    else
        % Delimited input options
        args.delimiter = '\t';
        args.maxrows = 2e4;
        args.addRows = 5e3;
    end

else
    p = inputParser;
    addRequired(p,'filename',@ischar);
   
    if dynammo.compatibility.isAddParameter
        fcn = @addParameter;
    else
        fcn = @addParamValue;
    end
    
    fcn(p,'dateformat','auto',@ischar);
    fcn(p,'delimiter','\t',@ischar);

    % XLS file, Windows machine only
    fcn(p,'sheetname','',@ischar);

    % CSV only
    fcn(p,'maxrows',2e4,@(x) isa(x,'double'));
    fcn(p,'addRows',5e3,@(x) isa(x,'double'));

    p.parse(varargin{:});
    args = p.Results;
    
end

%% Handle spreadsheet files
if ~isempty(strfind(args.filename,'.xls')) % .xlsx and alike also this way
    [tind,range,values,frequency,name,techname] = xlsload(args);
else
    [tind,range,values,frequency,name,techname] = csvload(args);    
end

end %<eof>