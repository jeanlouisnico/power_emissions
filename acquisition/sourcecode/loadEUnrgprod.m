function data4 = loadEUnrgprod(varargin)

 defaultcountry    = {'all'} ;

   p = inputParser;
%    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0) && (mod(x,1)==0);
%    
%    validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
%    addRequired(p,'width',validScalarPosNum);
%    addOptional(p,'height',defaultHeight,validScalarPosNum);
   addParameter(p,'country',defaultcountry,@iscell);

   parse(p, varargin{:});
   
results = p.Results ; 

data3 = jsondecode(fileread('grossprodEU.json'));


if strcmp(results.country,'all')
    allgeo = fieldnames(data3) ;
else
    allgeo = results.country ;
end
for igeo = 1:length(allgeo)
    geo = allgeo{igeo}.alpha2 ;   
    
    Timearray = cat(1, data3.(geo)(:).Time) ;
    Timearray = datetime(Timearray,'InputFormat','dd-MMM-uuuu') ;
    
    data3.(geo) = rmfield(data3.(geo),'Time') ;
    allfields = fieldnames(data3.(geo)) ;
    varnames = {} ;
    powerout = [] ;
    for ifield = 1:length(allfields)
        switch allfields{ifield}
            case {'Minutes5UTC' 'Minutes5DK' 'PriceArea'}
    
            otherwise
                datain = {data3.(geo)(:).(allfields{ifield})}';
                dataempty = cellfun(@(x) isempty(x), datain) ;
                datain(dataempty) = {NaN} ;
                powerout.(makevalidstring(allfields{ifield})) = cell2mat(datain) ;
                varnames = [varnames allfields(ifield)];
        end
    end
    data4.(geo) = array2timetable(struct2array(powerout), 'RowTimes', Timearray, 'VariableNames',varnames) ;
end