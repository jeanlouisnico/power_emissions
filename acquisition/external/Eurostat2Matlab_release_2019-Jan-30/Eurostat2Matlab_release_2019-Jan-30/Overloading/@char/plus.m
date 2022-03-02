function varargout = plus(varargin)
%
% [1] cell augmentation by a new char
% [2] Manual time series range manipulation
% INPUT: range, additive shift
% OUTPUT: range
% Suggested usage: [1] myCell = {'a';'b'}
%                      myCell+'c' -> {'a';'b';'c'}
%                  [2] '2010-05-23'+12:'2010-06-05' will give '2010-06-04:2010-06-05'
%                      '2001q1:2004q3'+1 will give '2001Q2:2004Q4'

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;
  
%% [Usage 1] Addition of a string into a cell
% -> varargin is always a cell of the original inputs
if (  any(cellfun(@ischar,varargin)) && any(cellfun(@iscell,varargin))  ) || all(cellfun(@ischar,varargin))
%     nrows = size(varargin(1),1);
%     if nrows==1
%         varargout{1} = [varargin(1),varargin(2)];
%     else
        varargout{1} = [varargin(1);varargin(2)];
%     end
    return
end

%% [Usage 2] Range manipulation for the tsobj()    
rangein = upper(varargin{1});% must be char

if length(rangein)<6 || ~all(isstrprop(rangein,'digit') | ...
                             isstrprop(rangein,'punct') | ...potential '-'/':' signs
                             rangein=='Q' | rangein=='M')
    varargout{:} = builtin('plus',varargin{:});
    return      
end
% try -> slower + dificult debugging last time
%     tsobj(rangein,1);
% catch
%     varargout{:} = builtin('plus',varargin{:});
%     return    
% end

if size(rangein,1)>1
    varargout{:} = builtin('plus',varargin{:});
    return
end

num = varargin{2};
if num==0
    varargout{1} = rangein;
    return
end

% Some argument is always 'char'
if ~isnumeric(num) || ~isscalar(num)
    error_msg('Plus operator',['...to be used for time series ' ...
                               'range processing only. ' ...
                               'Expected inputs: [char] range ' ...
                               'and [scalar] shift.']);
end

% Range bounds
bounds = regexp(rangein,':','split');
if length(bounds)>2
    error_msg('Plus operator','Range processing failed...',rangein); 
end
start_ = bounds{1};
finish_ = bounds{end};

% Data frequency
freq = unique(regexp(upper(rangein),'(-|M|Q)','match'));
if isempty(freq)
    if ~isempty(regexp(upper(rangein),'[A-Z]','match'))
            error_msg('Plus operator','Range processing failed...',rangein); 
    end

    % yearly
    if eval(start_) > eval(finish_)
        error_msg('Plus operator','Range processing failed...',rangein); 
    end

    start_ = sprintf('%.0f',eval(start_)+num);
    finish_ = sprintf('%.0f',eval(finish_)+num);
    if start_==finish_
        rangein = start_;
    else
        %rangein = [start_,':',finish_];
         rangein = sprintf('%s:%s',start_,finish_);
    end
    varargout{1} = rangein;

else

    if length(unique(freq))~=1
        error_msg('Plus operator','Range processing failed...',rangein); 
    end
    freq = freq{1};

    if any(strcmp(freq,{'Q';'M'}))
        year1 = eval(start_(1:4));
        part1 = eval(start_(6:end));
        year2 = eval(finish_(1:4));
        part2 = eval(finish_(6:end));

        if strcmp(freq,'Q')
            max_ = 4;
        elseif strcmp(freq,'M')
            max_ = 12;
        end

        year1 = year1 + floor(num/max_);
        year2 = year2 + floor(num/max_);

        part1 = part1 + mod(num,max_);
        if part1 > max_
           year1 = year1 + 1;
           part1 = part1 - max_; 
        end
        part2 = part2 + mod(num,max_);
        if part2 > max_
           year2 = year2 + 1;
           part2 = part2 - max_; 
        end

        if year1==year2 && part1==part2
            %rangein = [sprintf('%.0f',year1) freq sprintf('%.0f',part1)];
             rangein =  sprintf('%.0f%s%.0f',year1,freq,part1);
        else
            %rangein = [sprintf('%.0f',year1) freq sprintf('%.0f',part1) ':' sprintf('%.0f',year2) freq sprintf('%.0f',part2)];
             rangein =  sprintf('%.0f%s%.0f:%.0f%s%.0f',year1,freq,part1,year2,freq,part2);
        end
        varargout{1} = rangein;

    elseif strcmp(freq,'-')
        if strcmp(start_,finish_)
            year = eval(start_(1:4));
            month = eval(start_(6:7));
            day = eval(start_(9:10));
            
            if num>0
                undecided = true;
                days_ahead = day+num;
                while undecided
                    %cal = calendar(year,month);
                    %enddate = max(cal(:));
                    cal = mycalendar(year,month);
                    enddate = cal(end);
                    if days_ahead <= enddate
                       undecided = false;
                    else
                       if month==12
                          month = 1;
                          year = year+1;
                       else
                          month = inc(month); 
                       end
                       days_ahead = inc(days_ahead,-enddate);
                    end
                end
                if log10(month)<1
                    month = sprintf('0%.0f',month);
                else
                    month = sprintf('%.0f',month);
                end
                if log10(days_ahead)<1
                    days_ahead = sprintf('0%.0f',days_ahead);
                else
                    days_ahead = sprintf('%.0f',days_ahead);
                end
                %varargout{1} = [sprintf('%.0f',year) '-' month '-' days_ahead];
                 varargout{1} =  sprintf('%.0f-%s-%s',year,month,days_ahead);
                return
            else
                undecided = true;
                days_ahead = day+num;%num<0
                while undecided
                    %cal = calendar(year,month);
                    startdate = 1;
                    %enddate = max(cal(:));
                    if days_ahead >= startdate
                       undecided = false;
                    else
                       if month==1
                          month = 12;
                          year = year-1;
                       else
                          month = inc(month,-1); 
                       end
                       %cal = calendar(year,month);
                       %enddate = max(cal(:));
                       cal = mycalendar(year,month);
                       enddate = cal(end);
                       days_ahead = enddate + days_ahead;%days_ahead <0
                    end
                end
                if log10(month)<1
                    month = sprintf('0%.0f',month);
                else
                    month = sprintf('%.0f',month);
                end
                if log10(days_ahead)<1
                    days_ahead = sprintf('0%.0f',days_ahead);
                else
                    days_ahead = sprintf('%.0f',days_ahead);
                end
                %varargout{1} = [sprintf('%.0f',year) '-' month '-' days_ahead];
                 varargout{1} =  sprintf('%.0f-%s-%s',year,month,days_ahead);
                return
            end
            
        else % bounds different -> recursive call
            first = plus(start_,num);
            second = plus(finish_,num);
            varargout{1} = first:second;
        end

    else
        error_msg('Range processing','Frequency unrecognized...',varargin{1});
    end
end


end %<eof>