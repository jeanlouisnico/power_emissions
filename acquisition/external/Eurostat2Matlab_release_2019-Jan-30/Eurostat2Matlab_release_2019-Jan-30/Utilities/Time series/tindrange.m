function [tind,varargout] = tindrange(freq,varargin)
%
% Returns timeline and corresponding range array given the data
% frequency and time indication (in whatever format)
%
% INPUT [nargin==3]: freq    ...time series frequency
%                    start_  ...first tind/range (char/double), 
%                    finish_ ...last tind/range (char/double)
% 
% INPUT [nargin==2]: freq   ...time series frequency
%                    timing ...cell of ranges, 
%                              or vector of tinds,
%                              or ':' delimited range definition (char)
% 
% OUTPUT: tind
%        [range]
% 
% SEE ALSO: [tind,freq] = range2tind(range) -> this function is useful to guess the input frequency, but it cannot be numeric!
%           range = tind2range(tind,freq)
%           [tind,range,freq] = process_range(range) -> gives data frequency even for numeric input
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Crossroads

switch nargin
    case 2
        input = varargin{1};
        if iscellstr(input) % Range cell array
            
            % The input must form a valid range (bounds matter only)
            bounds = range2tind({input{1};input{end}});
            if nargout==2
                [tind,varargout{1}] = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));
            else
                tind = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));
            end
            return
            
        elseif isa(input,'double') % tind array
            
            % Short notation
            if ~strcmpi(freq,'Y')
               [start_,finish_] = dynammo.tsobj.range_short_notation(freq,input(1),input(end));
               if nargout==2
                   [tind,varargout{1}] = tindrange(freq,start_,finish_);
               else
                   tind = tindrange(freq,start_,finish_);
               end
               return
               
            end
            
            % range/tind treated equally
            tind = input(:);
            if nargout==2
                varargout{1} = tind2range(input,freq);
            end
            return
            
        elseif ischar(input) 
            if ~isempty(strfind(input,':')) % delimiter found
                bounds = regexp(input,':','split');
                
                % Short notation
                [bounds{1},bounds{2}] = dynammo.tsobj.range_short_notation(freq,bounds{1},bounds{2});
                
                bounds = range2tind({bounds{1};bounds{2}});
                if nargout==2
                    [tind,varargout{1}] = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));
                else
                    tind = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));
                end
                return
                
            else
                
                % Short notation
                [start_,finish_] = dynammo.tsobj.range_short_notation(freq,input);
                if ~strcmp(start_,finish_)
                    if nargout==2
                        [tind,varargout{1}] = tindrange(freq,start_,finish_);
                    else
                        tind = tindrange(freq,start_,finish_);
                    end
                    return 
                end
                
                % Single input, single output
                range = {start_};
                tind = range2tind(range);
                if nargout==2
                    varargout{1} = range;
                end
                return
                
            end
            
        else
            dynammo.error.tsobj('Sick input...');
        end
        
    case 3
        
        start_ = varargin{1};
        finish_ = varargin{2};
        
        if ischar(start_) && ischar(finish_)
            
            % Short notation
            [start_,finish_] = dynammo.tsobj.range_short_notation(freq,start_,finish_);
                
            bounds = range2tind({start_;finish_});
            if nargout==2
                [tind,varargout{1}] = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2));
            else
                tind = dynammo.tsobj.tind_build(freq,bounds(1),bounds(2)); 
            end
            return
           
        elseif isa(start_,'double') && isa(finish_,'double')
            
            % Short notation
            [start_,finish_] = dynammo.tsobj.range_short_notation(freq,start_,finish_);
            
            if ischar(start_) % due to short notation
                bounds = range2tind({start_;finish_});
                start_ = bounds(1);
                finish_= bounds(2);
            end
            
            if nargout==2
                [tind,varargout{1}] = dynammo.tsobj.tind_build(freq,start_,finish_);
            else
                tind = dynammo.tsobj.tind_build(freq,start_,finish_);
            end
            return

        else
            dynammo.error.tsobj('Inconsisten input types...');
        end
        
    otherwise
        dynammo.error.tsobj('Range processing - 2 or 3 input arguments are required, first being the data frequency...');
end

end %<eof>