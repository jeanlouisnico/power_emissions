classdef dbEUROSTAT
%     
% Constructor for the class dbEUROSTAT()
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

    properties(GetAccess = 'public', SetAccess = 'public')
        source
        url
        table
        filter
        engine
        deleteSourceFiles
        status
    end
    properties(Hidden = true)
        
        offline
        
    end    
    methods
        function this=dbEUROSTAT(varargin)
            % Class constructor
            % keyboard;

            % Empty tsobj
            if nargin==0
                
                this.source = 'EUROSTAT';% Keep this property - once the object is created, the source is worth knowing...
                
                this.url.table_of_contents = 'https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=table_of_contents.xml';
                this.url.DIClink           = 'https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=dic%2Fen%2F#ToBeReplaced#';%'geo.dic'
                this.url.revisions_link    = 'https://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&file=table_of_contents_en.txt';
                
                % Data structure definitions still on http:// (as of 03-09-2018)
                this.url.DSD               = 'http://ec.europa.eu/eurostat/SDMX/diss-web/rest/datastructure/ESTAT/DSD_#ToBeReplaced#';%'nama_gdp_c'
                
                this.table = '';
                this.filter = '';
                this.engine = 'BULK/SDMX';%'BULK/SDMX'|'JSON'
                this.deleteSourceFiles = 1;
                this.status = 'Table not specified - picktable() might help...';
                
                % Development option
                this.offline = 0;% For educational purposes we let the user show things even without full access to the Eurostat web services
                
                return   
                
            else
                error_msg('Database object creation','Unknown number of input arguments...');
            end
       
        end
        
        % Other methods follow
%         varargout = addToFavourites(varargin) % by default automatic?
%         varargout = get(varargin)
%         varargout = favourites(varargin)
%         varargout = refresh(varargin)
        varargout = metadata(varargin)
        varargout = picktable(varargin)
        varargout = subsasgn(varargin)
        varargout = TOC(varargin)
        
 
    end

end %<eof>