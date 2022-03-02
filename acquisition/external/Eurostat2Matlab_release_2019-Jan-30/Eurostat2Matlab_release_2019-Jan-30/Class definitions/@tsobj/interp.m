function out = interp(this,varargin)
%
% Interpolation of tsobj() values
%
% INPUT: 1] tsobj()
%        2] options (run dynammo.options.interp() to see the list of available options)
%
% OUTPUT: interpolated tsobj()
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Options
args = dynammo.options.interp(varargin{:});
if ~isstruct(args)
   error_msg('Options resolution','This usually happens if you do not enter the function options properly...'); 
end

%% Body
values = this.values;

switch lower(args.type)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'clone' % 'clone' will repeat last observed value for all NaNs in future/history
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       goForward();
       goBackward();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'clone_forward' % Only future NaNs cloned
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        goForward();
        
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     case 'clone_backward' % Only NaNs on history get cloned
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         goBackward();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    otherwise % all interp1() types accepted
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(values,2)>1
            tmp_ = explode(this);
            tmp_ = structfun(@(x) interp(x,'type',args.type),tmp_,'UniformOutput',false);
            tmp_ = implode(tmp_);
            values = tmp_.values;
            
        else
           nans = isnan(values);
           xi = this.tind(~nans);
           yi = values(~nans);
           values = interp1(xi,yi,this.tind,args.type);
           
        end        
end
   
this.values = values;      
out = this;

%% Support functions
    function goForward()
       last_val = nan(1,size(values,2));
       for iline = 1:size(values,1)
           valnow = values(iline,:);
           values(iline,isnan(valnow)) = last_val(1,isnan(valnow));
           last_val(1,~isnan(valnow)) = values(iline,~isnan(valnow));    
       end        
    end %<goForward>

    function goBackward()
       last_val = nan(1,size(values,2));
       if any(isnan(values(:)))
           values = flipud(values);% Flip
           for iline = 1:size(values,1)
               valnow = values(iline,:);
               values(iline,isnan(valnow)) = last_val(1,isnan(valnow));
               last_val(1,~isnan(valnow)) = values(iline,~isnan(valnow));
           end
           values = flipud(values);% Flip back
       end
    end %<goBackward>

%     function goBackward_forw_middle()
%         
%     end %<goBackward>

end %<eof>