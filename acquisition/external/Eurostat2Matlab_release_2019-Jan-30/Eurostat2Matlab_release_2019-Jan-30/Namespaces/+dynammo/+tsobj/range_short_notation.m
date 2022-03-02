function [start_,finish_] = range_short_notation(freq,varargin)
%
% Range adjustment if the input is incomplete
% 
% INPUT: freq        ...data frequency
%        start range ...starting period (both char/double types allowed)
%       [end range]  ...if nargin==2, end range corresponds to start range
% 
% OUTPUT: start_+finish_ in proper char format
% 
% INTENDED USE: x('2010') will give values x('2010q1:2010q4'), 
%            or x('2010m1:2010m12') depending on frequency
% 
% Cell input is not allowed (!)
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input
start_ = upper(varargin{1});
if nargin==3
    finish_ = upper(varargin{2});
else
    finish_ = upper(start_);
end

%% Numeric input range 
if isa(start_,'double')
    %     dynammo.error.tsobj(['Range processing: Declare the date as ' ...
    %                'string, numeric format not supported here...']);
    start_ = sprintf('%d',start_);
    finish_ = sprintf('%d',finish_);
end

%% Yealy data ready to go
if strcmpi(freq,'Y')
   return 
end

%% Crossroads
switch upper(freq)
    case 'Q'
        if isempty(regexp(start_,'Q','once'))
            start_  = sprintf('%sQ1',start_);
            finish_ = sprintf('%sQ4',finish_);
        end
        
    case 'M'
        if isempty(regexp(start_,'M','once'))
            start_  = sprintf('%sM1',start_);
            finish_ = sprintf('%sM12',finish_);
        end
        
    case 'D'
        
        delims = regexp(start_,{'-';'M';'Q'});
        if length(delims{1})==2 % Standard daily data input
            return
        end
        
        delims = ~cellfun('isempty',delims);
        if ~any(delims) % Only year, e.g. 2010
            start_  = sprintf('%s-01-01',start_);
            finish_ = sprintf('%s-12-31',finish_);
            
        elseif delims(1) % year+month, e.g. 2010-05
            start_  = sprintf('%s-01',start_);
            finish_ = sprintf('%s-31',finish_);
            
        elseif delims(2) % year+month, e.g. 2010m5
            start_parts = regexp(start_,'M','split');
            start_ = sprintf('%s-%02g-01',start_parts{1},eval(start_parts{2}));
            finish_parts = regexp(finish_,'M','split');
            finish_ = sprintf('%s-%02g-31',finish_parts{1},eval(finish_parts{2}));
            
        elseif delims(3) % year+quarter, e.g. 2010q2
            start_parts = regexp(start_,'Q','split');
            start_ = sprintf('%s-%02g-01',start_parts{1},(eval(start_parts{2})-1)*3+1);
            finish_parts = regexp(finish_,'Q','split');
            finish_ = sprintf('%s-%02g-31',finish_parts{1},eval(finish_parts{2})*3);          
            
        end

end

end %<eof>