function this = x12(this,varargin)
% 
% 3rd party seasonal adjustment command line tool for tsobj()
% 
% Correct use of 'instructions' option:
%    See X-12-ARIMA Reference Manual (U.S. Census Bureau, 
%    https://www.census.gov/srd/www/winx12/) for all possible options. All x12 
%    settings should be declared here as one single string. Each line of
%    code should end with a ';' (semicolon).
% 
%    Example 1: ...,'instructions','outlier{types=all;critical=3.75}'
% 
%    Example 2: Series{} command contains the data input, which need not 
%               be declared by the user, thus declaring
%               ...,'instructions','series{precision=1}' will be automatically
%               extended to make sure the data input is set up.
% 
%    Example 3: Combinations of options are allowed:
%               ...,'instructions','outlier{type=all}series{precision=1}'

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
    
    % >>> Options <<<
    args = dynammo.options.x12(varargin{:});
    if ~isstruct(args)
       error_msg('Options resolution','This usually happens if you do not enter the function options properly...'); 
    end    
    
end

%% Initial data treatment

if strcmpi(this.frequency,'Y')
   dynammo.warning.tsobj(['Seasonal adjustment of yearly data does not make ' ...
                'sense. Returning the original series...']);
   return
end
if any(this.values(:)<=0) && any(strcmpi(args.mode,{'mult';'pseudoadd'})) %;'logadd'
   dynammo.error.tsobj('Multiplicative seasonality makes sense for strictly positive data only...');
end

%% Time series collections processing

nc = size(this.values,2);
if nc > 1
    res = tsobj();       
    for ii = 1:nc
%         keyboard;
        tmp = this;
        tmp.values = this.values(:,ii);
        tmp.name = this.name(ii);
        tmp.techname = this.techname(ii);
        if all(isnan(tmp.values))
            res = [res tmp];% Leave there only the NaNs
        else
            res = [res x12(tmp,args)]; %#ok<AGROW>
        end
        rehash;
    end
    this = res;
    return
end

%% Validate the data length

% Save the original sample size including NaNs
rangein = this.range;

% Get rid of leading/trailing NaNs
% -> however, trimming itself is not sufficient to capture all the seasonal factors,
%    e.g. for Q data we need at least 4 data points to start, not just the 1st one (as trimming guarantees)
% -> therefore we have HP filter as a measure of last resort...
this = trim(this);

try_HP_instead = 0;
switch upper(this.frequency)
    case 'Q'
        if size(this.values) < 12
           %dynammo.error.tsobj('Seasonal adjustment: Data length should be at least 3 complete years, hp() might be the action of last resort...'); 
           try_HP_instead = 1;
        end
        sa_period = 4;
    case 'M'
        if size(this.values) < 36
           %dynammo.error.tsobj('Seasonal adjustment: Data length should be at least 3 complete years, hp() might be the action of last resort...'); 
           try_HP_instead = 1;
        end
        sa_period = 12;
    otherwise
        dynammo.error.tsobj('Seasonal adjustment: Invalid data frequency...');
end

if try_HP_instead==1
    dynammo.warning.tsobj('Seasonal adjustment: Data length should be at least 3 complete years, performing HP filter (lambda=1) with interpolated missing values as an action of last resort...'); 
    this = hp(this,'lambda',1,'missing',1,'rename',0,'throw_warnings',0);
    return
end

%% Missing values treatment
% -> X12 does not support missing values at all, we must perform interpolation first
%    if the interpolation is not feasible at the edges of the sample, then HP filtering
%    is taken as a measure of last resort

% Handle insample missing values
% -> linear interpolation between corresponding quarters/months is assumed
% -> if the corresponding quarters/months values are known only before/after the missing 
%    data segment, then cloning of the first/last known value is NOT applied (would be dangerous if trends present)
nanpos = isnan(this.values);
if any(nanpos)
               
    vals = this.values;% Only single tsobj() allowed here, tscoll() calls x12() in a cycle
    for iper = 1:sa_period
        % !!! If there are more than 1 missing data segment, all are treated altogether, not one by one !!!
        indset = iper:sa_period:length(this.tind);
        nans = isnan(vals(indset(:)));
        if ~any(nans(:))
           continue 
        end
        nanswhere = find(nans);
        prevind = nanswhere(1)-1;
        if prevind==0
            dynammo.warning.tsobj('Seasonal adjustment: Impossible to interpolate the beginning of the sample, performing HP filter (lambda=1) with interpolated missing values as an action of last resort...'); 
            this = hp(this,'lambda',1,'missing',1,'rename',0,'throw_warnings',0);
            return
        end
        prevdata = indset(prevind);
        afterind = nanswhere(end)+1;
        if afterind>length(nans)
            dynammo.warning.tsobj('Seasonal adjustment: Impossible to interpolate the beginning of the sample, performing HP filter (lambda=1) with interpolated missing values as an action of last resort...'); 
            this = hp(this,'lambda',1,'missing',1,'rename',0,'throw_warnings',0);
            return
        end
        
        % Standard cases if the start and the ending of time series is populated (allows for interpolation in between)
        dynammo.warning.tsobj(['Missing values found while performing the seasonal adjustment, ' ...
                   'linear interpolation between corresponding periods assumed...']);
               
        afterdata = indset(afterind);
        indset = prevdata:sa_period:afterdata;
        vals_to_put = linspace(vals(prevdata,1),vals(afterdata,1),length(indset));
        vals(indset,1) = vals_to_put(:);
    end
    this.values = vals;
end

%% Build an external data file

DATfile = ['tsobj_x12_' rand_str() '.dat'];
fid = fopen(DATfile,'w');

for ii = 1:size(this.values(:),1)
    fprintf(fid,'%s\n',sprintf('%.8f',this.values(ii))); 
end

status = fclose(fid);

if status ~= 0
   dynammo.error.tsobj(['Seasonal adjustment: Building external ' ...
              'data file unsuccessful...']); 
end

rehash;

%% Driver function

series_str = ['series{period=' sprintf('%.0f',sa_period) ';' ...
                         'file="' DATfile '";' ...
                         'title="Dyn:Ammo X12/X13 interface";'];
x11_str = ['x11{save=( d12 );mode = ' args.mode ';'];

% User supplied options
instructions = args.instructions;

if ~isempty(instructions)
    option_tags = regexp(instructions,'[a-zA-Z]\w*\{','match');
    option_tags = strrep(option_tags,'{','')';
    
    if any(strcmp('series',option_tags))
        
        % Merge default series{} tag with user-supplied
        glue = regexp(instructions,'series\{(.*?)\}','tokens');
        if ~isempty(glue)
            series_str = horzcat(series_str,glue{1}{1});
        end
        
        % Delete already processed contents
        instructions = regexprep(instructions,'(series\{).*?(\})','');

    end
    series_str = [series_str '}'];
    
    if any(strcmp('x11',option_tags))

        % Merge default series{} tag with user-supplied
        glue = regexp(instructions,'x11\{(.*?)\}','tokens');
        if ~isempty(glue)
            x11_str = horzcat(x11_str,glue{1}{1});
        end
        
        % Delete already processed contents
        instructions = regexprep(instructions,'(x11\{).*?(\})','');
        
    end
    x11_str = [x11_str '}'];
    
    % In any case series{} and x11{} should be entered first
    instructions = horzcat(series_str,x11_str,instructions);
    instructions = regexprep(instructions,'\}','};');
    
else
    series_str = [series_str '}'];
    x11_str    = [x11_str '}'];
    instructions = regexprep([series_str x11_str],'\}','};');
end

feeder = regexp(instructions,';','split');
feeder = feeder(:);

rehash;
SPCfile = ['tsobj_x12_driver_' rand_str()];
fid = fopen([SPCfile  '.spc'],'w');
for ii = 1:length(feeder)
    fprintf(fid,'%s\n',feeder{ii,1});
end
status = fclose(fid);

%% Convert the specification file for use with X-13 method
if args.x13ConvertorNeeded
    
    rehash;
    
    SPCfile_old = SPCfile;
    SPCfile = ['tsobj_x12_driver_' rand_str()];
    
    if ispc
        system(['"cnvx13as.exe" ' SPCfile_old '.spc ' SPCfile '.spc']);        
    else
        system(['"cnvx13as" '     SPCfile_old '.spc ' SPCfile '.spc']);
    end
    
    % Compatibility issues
    f = dynammo.io.readFile([SPCfile '.spc']);
    f = flip(regexprep(flip(f),'}','','once'));
    dynammo.io.writeFile(f,[SPCfile '.spc']);
        
    appName = 'X-13';
    
else
    appName = 'X-12';
    
end

%% Call to external X-12-ARIMA function

rehash;

if ismac
    if args.x13ConvertorNeeded
        %<to do>
    else
        appCall = '"x12a"';
    end
else
    if args.x13ConvertorNeeded
        appCall = '"x13as.exe"';
    else
        appCall = '"x12a.exe"';
    end
end

if ~args.verbose
    appCall = [appCall ' -q -i'];%strrep(x12_path,'tsobj.m',['x12' filesep 'x12a -q -i']);
end

%shell_comm = [appCall ' tsobj_x12_driver'];
 shell_comm = [appCall ' ' SPCfile];

% System shell command 
system(shell_comm);

% Delete some unnecessary output
if args.x13ConvertorNeeded
    fprintf(repstr('\b',386+1+40));
else
    fprintf(repstr('\b',386+1));
end

%% Collect the results

rehash;

fid = fopen([SPCfile '.d12'],'r');
if fid==-1
    if isunix
        dynammo.error.tsobj(['Cannot open "' [SPCfile '.d12'] '" (' appName ' result file). External ' ...
                   'call to ' appName ' routine probably failed... Handling ' ...
                   'x12/x13 unix executables on non-unix machines is ' ...
                   'not recommended <see FAQ>...LIKELY REASON FOR X12/13 TO CRASH IS THE LACK OF OBSERVATIONS (all NaN series are allowed)!']);
    else
        dynammo.error.tsobj(['Cannot open "' [SPCfile '.d12'] '" (x12/x13 result file). External ' ...
                   'call to ' appName ' routine probably failed...LIKELY REASON FOR ' appName ' TO CRASH IS THE LACK OF OBSERVATIONS (all NaN series are allowed)!']);
    end
end

res = textscan(fid,'%s','delimiter','\n');
res = res{:};
fclose(fid);

out_values = zeros(length(res)-2,1);
for ii = 3:length(res)
    line_now = res{ii,:};
    start_pos = regexp(res{ii,:},'(+|-)','once');
    out_values(ii-2,1) = eval(line_now(start_pos:end));
end

this.values = out_values;

%% Names adjustment

if args.rename
    if args.x13ConvertorNeeded
        this.name = namechange_unary(this.name,'x13');
    else
        this.name = namechange_unary(this.name,'x12');
    end
end
% this.techname = repmat_cellstr_empty(length(this.name));

%% Original range
% -> missing values treatment trims the object before the seasonal adjustment is carried out

% Plug back NaNs instead of interpolated numbers (this action is "args.missing" dependent)
if any(nanpos) && args.missing==0
    this.values(nanpos) = nan;
end

% Resize
this = trimNaNs(this,[rangein{1} ':' rangein{end}]);

%% Deleting the result files

if args.deleteResults
    %driver_files = dir('tsobj_x12_driver.*');
     driver_files = dir('tsobj_x12*.*');
    for ii = 1:length(driver_files)
        delete(driver_files(ii).name);
    end
    
    %delete('tsobj_x12.dat');
end        
        

end %<eof>