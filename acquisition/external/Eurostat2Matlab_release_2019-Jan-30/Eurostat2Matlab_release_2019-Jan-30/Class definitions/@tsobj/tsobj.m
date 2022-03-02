classdef tsobj
% 
% Class constructor for time series objects
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

properties(GetAccess = 'public', SetAccess = 'public')
    values
    tind 
    frequency
    range
    name
    techname
end
properties(Hidden = true)
    plotCallMode % name of predefined plot call
    secret       % any type, initially an empty string
end    
methods
    function this=tsobj(varargin)
        %% Class constructor

        % Input combinations:
        % - nargin==0 ...empty tsobj
        % - 1 char    ...file read
        % - 2 char    ...file read with additional options
        % - 1 struct  ...Data download from external source ('table' field must exist)
        % - 2         ...tsobj generation from scratch (time+values given)
        %             ...time indication: char/double (from-to dates)
        %                                 cell list of all dates (values of corresponding length, no range validation)
        % - 3         ...tsobj generation from scratch (time+values+names given)
        %             ...time indication: char/double (from-to dates)
        %                                 cell list of all dates (values of corresponding length, no range validation)

        this.plotCallMode = '';
        this.secret = '';
        
        %% Empty tsobj
        if nargin==0
            this.values = [];
            this.tind = [];
            this.name = {''};
            this.frequency = [];
            this.range = [];
            this.techname = {''};
            return                
        end
        
        %% Load db from file
        if (nargin==1 && ischar(varargin{1})) || ...
           (ischar(varargin{1}) && ischar(varargin{2}))

            [this.tind,this.range,this.values,this.frequency, ...
               this.name,this.techname] = load_external_data(varargin{:});
           %this.plotCallMode = '';
            return

        end

        %% tsobj() + data download
        if nargin==1

            % Data download from external sources
            if isa(varargin{1},'dbEUROSTAT')
            
                [this.tind,this.range,this.values,this.frequency, ...
                   this.name,this.techname] = EUROSTAT_wrapper(varargin{1});
                if ~isempty(this.tind)
                    this = trim(this);
                end
               %this.plotCallMode = '';
                return

            else
                error_msg('Time series object generation','Unknown input combination...');
            end

        end

        %% Speedy tsobj() generation w/o range validation

        % Cell {range} on input
        if iscell(varargin{1}) && length(varargin{1})>1 %nargin==2

            % Range taken as given
            [this.tind,this.range,this.values,this.frequency, ...
               this.name,this.techname] = cell_range_speedy(varargin{:});
           %this.plotCallMode = '';
            return

        end

        %% Standard tsobj() class constructor

        if any(nargin==[2;3])

            [this.tind,this.range,this.values,this.frequency, ...
               this.name,this.techname] = generate_tsobj(varargin{:});
           %this.plotCallMode = '';
            return                

        else
            dynammo.error.tsobj('tsobj() can process 3 arguments at most (range | data | series name(s))');
        end

    end %<tsobj>

    %% Other methods follow
    varargout = convert(varargin)
    varargout = cos(varargin)
    varargout = csvload(varargin)
    varargout = cumprod(varargin)
    varargout = cumsum(varargin)
    varargout = deflate(varargin)
    varargout = demean(varargin)
    varargout = diff(varargin) % obsolete!
    varargout = disp(varargin)
    varargout = display(varargin)
    varargout = exp(varargin)
    varargout = explode(varargin) 
    varargout = export(varargin)
    %varargout = get(varargin)     % properties() and methods() do the same thing
    varargout = horzcat(varargin)
    varargout = hp(varargin)
    varargout = hpstudio(varargin)
    %varargout = implode(varargin) % external fcn() only
    varargout = interp(varargin)
    varargout = isempty(varargin)
    varargout = istsobj(varargin) % obsolete!
    varargout = labels(varargin)
    varargout = leadlag(varargin)
    varargout = log(varargin)
    varargout = markers(varargin)
    varargout = mean(varargin)
    varargout = median(varargin)
    varargout = minus(varargin)
    varargout = MoM(varargin) % in percentage terms
    varargout = MoMpa(varargin) % in percentage terms, annualized
    varargout = mpower(varargin)   
    varargout = mrdivide(varargin) 
    varargout = mtimes(varargin)  
    varargout = namechange_unary(varargin)
    varargout = namechange_binary(varargin)
    varargout = numel(varargin)
    varargout = overlay(varargin)
    varargout = plot(varargin)
    varargout = plotCall(varargin)
    varargout = plot_dbobj_var(varargin)
    varargout = plus(varargin)
    varargout = QoQ(varargin)   % in percentage terms
    varargout = QoQpa(varargin) % in percentage terms, annualized
    varargout = round(varargin)
    varargout = rplot(varargin) % Plot for reporting (invisible figures)
    varargout = setbase(varargin)
    varargout = sin(varargin)
    varargout = size(varargin)
    varargout = skipnans(varargin)
    varargout = spy(varargin)
    varargout = subsasgn(varargin)
    varargout = subsref(varargin)        
    varargout = sum(varargin)
    varargout = sum2(varargin)
    varargout = std(varargin)
    varargout = timeline(varargin)
    varargout = trim(varargin)
    varargout = trimNaNs(varargin)
    varargout = uminus(varargin)
    varargout = uplus(varargin)
    varargout = vertcat(varargin)
    varargout = workingdays(varargin)
    varargout = x12(varargin)
    varargout = x13(varargin)
    varargout = YoY(varargin) % in percentage terms 

end %<methods>
    
end %<eof>