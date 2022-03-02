function this = hp(this,varargin)
% 
% Hodrick-Prescott filter
% 
% INPUT: 1] time series object (collections of time series also allowed)
%        2] additional options (see below)
% 
% OUTPUT: filtered times series (trend/gap/percentage gap specified by the option)
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Process user input
parseOpt = 1;
if nargin==2
    if isstruct(varargin{1})
        args = varargin{1};
        parseOpt = 0;
    end
end
if parseOpt
    % Options
    args = dynammo.options.hp(varargin{:});
    if ~isstruct(args)
       error_msg('Options resolution','This usually happens if you do not enter the function options properly...'); 
    end   
    if args.lambda==0
        if ~strcmpi(args.output,'trend')
            this.values(:) = 0;
        end
        return
    end
end

% keyboard;

%% Multiple series on input
% -> process them one by one

[~,n] = size(this.values);
if n > 1
   % names = this.name;
   
   ts_indiv = explode(this);
   f = fieldnames(ts_indiv);
   %warning_lack_of_obs_thrown = 0;
   for ii = 1:n
       %tsnow = trim(ts_indiv.(f{ii}));
       tsnow = ts_indiv.(f{ii}); % -> trimming is performed in general case inside the function
      
       % Do not throw additional warnings from within the core hp() engine
       args.throw_warnings = 0;
       
       % Lack of observations
       % -> return the same series and throw a warning
       % -> 4 seems to be the minimum workable sample size for the function to work (tested)
       if sum(~isnan(tsnow.values))<4
            % No warning for tscolls!
            %if warning_lack_of_obs_thrown==0
            %    dynammo.warning.tsobj('HP filtering: Insufficient amount of data on input, at least 4 observations needed...');
            %    warning_lack_of_obs_thrown = 1;
            %end
            temp_obj = tsnow;
       else
            temp_obj = hp(tsnow,args);%'output',args.output,'lambda',args.lambda,'rename',args.rename,'missing');
       end
       
       if ii==1
          result_obj = temp_obj;         
       else
          result_obj = [result_obj temp_obj];  %#ok<AGROW>
       end
       
   end

   this = result_obj;
   return
end

%% Missing values treatment

% Save the original sample size including NaNs
rangein = this.range;

% Get rid of leading/trailing NaNs
this_orig = this;
this = trim(this);
m = length(this.tind);

% Lack of observations
% -> return the same series and throw a warning
% -> 4 seems to be the minimum workable sample size for the function to work (tested)
if length(this.tind)<4
    %if ~isfield(args,'throw_warnings')
    if args.throw_warnings==1   
        dynammo.warning.tsobj('HP filtering: Insufficient amount of data on input, at least 4 observations needed. Returning the input unaltered...');
    end
    this = this_orig;
    return
end

% Handle insample missing values
% -> linear interpolation between border points is assumed
vals = this.values;% Only single tsobj() allowed here, tscoll() calls x12() in a cycle
nanpos = isnan(vals);
if any(nanpos)
    
    %if ~isfield(args,'throw_warnings')
    if args.throw_warnings==1    
        dynammo.warning.tsobj(['Missing values found while performing HP filtering, ' ...
                       'linear interpolation between border periods assumed...']);
    end
    
    % Start/End positions of missing segments
	% -> Beginning/end always non-NaN as a result of trim()
    nanpos_diff = [0;nanpos(2:end,1)-nanpos(1:end-1,1)];
    starts = find(nanpos_diff==1);
    ends   = find(nanpos_diff==-1);
    
    for isegm = 1:length(starts)
        prevind = starts(isegm)-1;
        afterind = ends(isegm);
        vals_to_put = linspace(vals(prevind,1),vals(afterind,1),afterind-prevind+1);
        vals(prevind:afterind,1) = vals_to_put(:);
    end
    this.values = vals;
end

%% HP filter 
lambda = args.lambda;
y      = this.values;

a = zeros(m  ,1);
b = zeros(m-1,1);
c = zeros(m-2,1);

a(1)    =    lambda+1;
a(2)    =  5*lambda+1;
a(3:m-2)=  6*lambda+1;
a(m-1)  =  5*lambda+1;
a(m)    =    lambda+1;
b(1)    = -2*lambda;
b(2:m-2)= -4*lambda;
b(m-1)  = -2*lambda;
c(1:m-2)=    lambda;

y=penta2(y,a,b,c);
  
switch upper(args.output)
    case 'TREND'
        this.values = y;
    case 'GAP'
        this.values = this.values - y;
    case 'PRCGAP'
        this.values = (this.values - y)./y.*100;
end
% keyboard;
if args.rename
    this.name = namechange_unary(this.name,'hp');
% else
%     this.name = name;
    %this.techname = repmat_cellstr_empty(length(this.name));
end
% this.techname = techname;

%% Original range
% -> missing values treatment trims the object before the HP filtering is carried out

% Put back the NaNs
if any(nanpos) && args.missing==0
    this.values(nanpos) = nan;
end

% Resize
this = trimNaNs(this,[rangein{1} ':' rangein{end}]);

%% Subfunctions follow

    function y = penta2(y,a,b,c)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Author: Kurt Annen annen@web-reg.de
    % Date: 15/05/2004
    % Internet: www.web-reg.de
    %
    % Solves the problem Ax=b when A is pentadiagonal and strongly nonsingular. 
    % This is much faster than x=A\y for large matrices.  
    %
    % Reference: Sp?th, Helmuth "Numerik: Eine Einf?hrung f?r Mathematiker und Informatiker"
    %               S. 110 . Vieweg-Verlag Braunschweig/Wiesbaden (1994)
    %
    % a = main diagonal
    % b = 2. diagonal
    % c = 3. diagonal
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     if nargin == 4
%         dynammo.error.tsobj('HPfilter: penta(A,y) requires four arguments');
%     end

    n = length(a);
    m = length(y);
    %o = length(b);
    p = length(c);

    if m ~= n
        dynammo.error.tsobj('HPfilter: Inner matrix dimensions must agree');
    end
    c(m)=0;
    c(m-1)=0;
    b(m)=0;  

    if m ~= length(b) &&  m ~= length(c)
        dynammo.error.tsobj('HPfilter: a,b,c must have the same dimension');
    end    


    % An optimized algorithm

        h1=0;
        h2=0;
        h3=0;
        h4=0;
        h5=0;
        %hh1=0;
        hh2=0;
        hh3=0;
        %hh4=0;
        hh5=0;
        %z=0;
        %hb=0;
        %hc=0;

        for i=1:m
            z=a(i)-h4*h1-hh5*hh2;
            hb=b(i);
            hh1=h1;
            h1=(hb-h4*h2)/z;
            b(i)=h1;
            hc=c(i);
            hh2=h2;
            h2=hc/z;
            c(i)=h2;
            a(i)=(y(i)-hh3*hh5-h3*h4)/z;
            hh3=h3;
            h3=a(i);
            h4=hb-h5*hh1;
            hh5=h5;
            h5=hc;
        end
        h2=0;
        h1=a(m);
        y(m)=h1;
        for i=m:-1:1
            y(i)=a(i)-b(i)*h1-c(i)*h2;
            h2=h1;
            h1=y(i);
        end

    %x=y;
    
    end %<eof>

end %<eof>
