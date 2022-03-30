function Tradecountry = Balance_Matrix(varargin)

warning('OFF', 'all' )

defaultcode         = 'FR'  ;      
defaultzone         = false ;   

p = inputParser;

validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0) && (mod(x,1)==0);
validVector = @(x) all(isnumeric(x)) && all(isvector(x)) ;
validstring = @(x) isstring(x) || ischar(x) ;

addParameter(p,'country',defaultcode, validstring);
addParameter(p,'zone',defaultzone, @islogical);

parse(p, varargin{:});

results = p.Results ; 

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

try
    val = jsondecode(fileread([fparts{1} filesep 'input' filesep 'general' filesep 'exchanges_corr.json']));
    [~, neworder] = sort(lower(fieldnames(val)));
    val = orderfields(val, neworder);
catch
    % Import the exchange of energy between countries
    val = jsondecode(fileread('exchanges.json'));
        
    % since some links are missing or not handled properly, go through each
    % zone and re-attribute the missing links to other zones
    allexch = cellfun(@(x) strsplit(x,'__') , fieldnames(val)  , 'UniformOutput' , false) ;
    allexch = cell2table(allexch) ;
    
    allzonesin = allexch.allexch(:,1) ; 
    allzonesout = allexch.allexch(:,1) ; 
    allzones = [allzonesin;allzonesout] ;
    allzones = unique(allzones) ;
    
    for izone = 1:length(allzones)
        zonecode = allzones{izone} ;
        Exportcountry = allexch.allexch(strcmp(zonecode, allexch.allexch(:,1)),2) ;
        if ~isempty(Exportcountry)
            for icountout = 1:length(Exportcountry)
                Exportcountrybis = allexch.allexch(strcmp(Exportcountry{icountout}, allexch.allexch(:,1)),2) ;
                if ~any(ismember(zonecode, Exportcountrybis)) 
                    % This means that the country is missing in the other
                    % directions. In this case, duplicate the original
                    % structure by inversing its name
                    code2retrieve = [zonecode '__' Exportcountry{icountout}] ;
                    valstruct = val.(code2retrieve) ;
                    code2add = [Exportcountry{icountout} '__' zonecode] ;
                    val.(code2add) = valstruct ;
                end
            end
        end
    end
    
    % Write back into the json file for missing links
    dlmwrite('exchanges_corr.json',jsonencode(val, "PrettyPrint", true),'delimiter','');
    val = jsondecode(fileread('exchanges_corr.json'));
end

allexch = cellfun(@(x) strsplit(x,'__') , fieldnames(val)  , 'UniformOutput' , false) ;

if results.zone
    % This means that we are looking for codes related to the current
    % input, not by country
    
else
    % This variable is to be used for zonal code retrieving
    [countryin, countryout] = retrievebycountry(allexch) ;
end



%% Search for country and subregions
newStr = split(results.country,'_') ;

if length(newStr) == 1
    Tradecountry = countryout(strcmp(newStr{1}, countryin(:,1)),:) ;
elseif length(newStr) == 2
    Tradecountry = countryout(strcmp(newStr{1}, countryin(:,1)) & ...
                               strcmp(newStr{2}, countryin(:,2)) ,:) ;
elseif length(newStr) == 3
    Tradecountry = countryout(strcmp(newStr{1}, countryin(:,1)) & ...
                               strcmp(newStr{2}, countryin(:,2)) & ...
                               strcmp(newStr{3}, countryin(:,3)) ,:) ;
end

warning('ON', 'all' )

    function retrievebyzone(allexch)
        for icells=1:length(allexch)
            a(icells,:) = allexch{icells} ;
        end
        a = cell2table(a,'VariableNames',['in' 'out']) ;
    end

    function [countryin, countryout] = retrievebycountry(allexch)
        allexch = cell2table(allexch) ;
        for icountry = 1:2
            country = cellfun(@(x) strsplit(x,'_') , allexch.allexch(:,icountry)  , 'UniformOutput' , false) ;
            country2 = repmat({''}, length(country), 3) ;
            for icell = 1:length(country)
                loopcol = size(country{icell},2) ;
                for iloop = 1:loopcol
                    country2(icell, iloop) = country{icell}(iloop) ;
                end
            end
            if icountry == 1
                countryin = country2 ;
            elseif icountry == 2
                countryout = country2 ;
            end 
            country2 = [] ;
        end
    end

end
