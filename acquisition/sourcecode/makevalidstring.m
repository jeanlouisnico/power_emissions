function nameout = makevalidstring(bidname, varargin)

 defaultcapital    = true ;

   p = inputParser;
%    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0) && (mod(x,1)==0);
%    
%    validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
%    addRequired(p,'width',validScalarPosNum);
%    addOptional(p,'height',defaultHeight,validScalarPosNum);
   addParameter(p,'capitalise',defaultcapital,@islogical);

   parse(p, varargin{:});
   
results = p.Results ; 

if results.capitalise
    bidname = lower(bidname) ;
end
nameout = strrep(bidname,' ','_') ;
nameout = strrep(nameout, '/', '_') ;
nameout = strrep(nameout, '-', '_') ;
nameout = strrep(nameout, '...', '_') ;
nameout = strrep(nameout, '%', 'perc') ;
nameout = strrep(nameout, '>=', 'GE') ;
nameout = strrep(nameout, '<=', 'SE') ;
nameout = strrep(nameout, '>', 'G') ;
nameout = strrep(nameout, '<', 'S') ;
nameout = strrep(nameout, '=', 'E') ;
nameout = strrep(nameout, '.', '') ;
nameout = strrep(nameout, '(', '') ;
nameout = strrep(nameout, ')', '') ;
nameout = strrep(nameout, ',', '') ;
nameout = strrep(nameout, '+', '') ;