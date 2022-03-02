function [tind,varargout] = tind_build(freq,start_,finish_)
%
% Returns timeline and corresponding range array given the data
% frequency and borders
%
% INPUT: freq    ...time series frequency
%        start_  ...first tind (double)
%        finish_ ...last tind (double)
%
% OUTPUT: tind
%        [range] ...optional
% 
%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input validation
if start_ > finish_
    error_msg('Range processing','Last period must be strictly higher than the start period...');
end
    
%% Body

switch lower(freq)
    case 'y'
        tind = start_:1:finish_;
        tind = tind(:);
        if nargout==2
            varargout{1} = tind2range(tind,'Y');
        end
        
    case 'q'
        tind = start_:0.25:finish_;
        tind = tind(:);
        if nargout==2
            varargout{1}= tind2range(tind,'Q');
        end
        
    case 'm'
        tind = floor((round(start_*12):round(finish_*12))/12.*1e4)./1e4;
              %floor((start_:(1/12):finish_).*1e4)./1e4; % Bad rounding
        tind = tind(:);
        if nargout==2
            varargout{1}= tind2range(tind,'M');
        end
        
    case 'd'
        if nargout==2
            [tind,varargout{1}] = dynammo.tsobj.build_daily(start_,finish_);
        else
            tind = dynammo.tsobj.build_daily_tindONLY(start_,finish_);
        end
        
end

end %<eof>