function varargout = kalman(m,db,varargin)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input parser
p = inputParser;

% Stack control
st = dbstack();
nst = size(st,1)>1;
if nst
    addRequired(p,'m',@(x) isa(x,'mobj'));
    addRequired(p,'db',@(x) isstruct(x) || isa(x,'tsobj'));
end

if dynammo.compatibility.isAddParameter
    fcn = @addParameter;
else
    fcn = @addParamValue;
end

fcn(p,'status',true);
fcn(p,'range',Inf);
%fcn(p,'comprange',tsobj()); -> not needed, 'range' uses trimNaNs
fcn(p,'tv_covmat', tsobj()); % time-varying shock covariances
fcn(p,'tv_trends', '');      % time-varying stochastic trends

% Output format
fcn(p,'gaps',1,@(x) any(x==[0;1]));% Deviations from steady state (=1), or levels returned (=0)
fcn(p,'explodeOutput',0,@(x) any(x==[0;1]));
    % 1: final results as struct of individual tsobj()
    % 0: final results as one tsobj()  

% Initial condition
fcn(p,'ini_vec', []);   % user-supplied state vector
fcn(p,'ini_covar', []); % user-supplied covariance matrix of the prediction errors in the state vector
fcn(p,'kappa', Inf,@(x) isa(x,'double'));
    % Inf = Exact diffuse initial condition assumed (matters for the covariance matrix)
    % 0 = fixed initial condition assumed, numeric input assumed
fcn(p,'ini_obs', 'zero');% Fixed initial condition for the observables with trend
    % 'zero' - no deviation from the trend assumed at the beginning of the sample
    
% Lyapunov equation solver options
fcn(p,'lyapunov_tol', 1e-6);
fcn(p,'lyapunov_maxiter', 1e3);

% Threshold values
fcn(p,'stability_thresh', 1-1e-6);% cannot exceed 1
fcn(p,'singularity_thresh', 1e-6);% threshold for identification of dimensions of singularity
fcn(p,'kalman_tol', 1e-10); % maximum value deemed as zero

% Decomposition into observables
fcn(p,'decomp', 0);% Validated below

%
fcn(p,'sspruning', 0,@(x) any(x==[0;1]));
fcn(p,'sparsity',0,@(x) any(x==[0;1]));% sparsity+qr() for large models, this might be a way to go instead of sspace pruning
fcn(p,'triangularize', 0,@(x) any(x==[0;1]));
fcn(p,'sequential', 0,@(x) any(x==[0;1]));
fcn(p,'algo', 4,@(x) floor(x)==x); 
    % 1: standard
    % 2: sequential_processing
    % 3: fast smoother
    % 4: universal (combination of the above) - the only choice for exact diffuse initialization
    
if nst
    p.parse(m,db,varargin{:});% Cannot run in debug mode!
else
    p.parse(varargin{:});
end
args = p.Results;

%% Print options overview
if nargin==0 && nargout==0 % overview of available options
    dynammo.options.args_overview(definition(args));
    return
end

%% Options resolution
% Range potreba podle 'user range' otestovat vstup --> inside dynammo.kalman.options

if ~isempty(args.tv_trends)
    args.tv_trends = args.tv_trends(:);
    args.triangularize=0;
    
    % Model should have some trends
    if size(m.declaration.trends,1)==0
       error_msg('TV trends estimation',['The model should have at least one declared ' ...
                                         'trend, otherwise standard Kalman can be called...']); 
    end
    
    % Trends have to be defined symbolically
    trend_decl = m.declaration.trends(:,3);
    if any(cellfun('isempty',regexpi(trend_decl,'[a-z]*')))
       error_msg('TV trends estimation',['Trends have to be declared symbolically so ' ...
                                         'that they can be updated as the TV trends ' ...
                                         'estimation goes on...']); 
    end
    
end

% Algorithms versioning
if ~isempty(args.tv_trends) 
    args.algo = 21;
elseif ~args.triangularize % Use different set of algorithms for original/triangularized system
    args.algo = 1e1 + args.algo;
end

% Decomposition into observables
if ~isa(args.decomp,'double') && ~ischar(args.decomp)
   error_msg('Decomposition into observables input',['''decomp'' option ' ...
                'can be either a 0/1 switch (in that case we initiate the ' ...
                'decomposition from the 1st sample period), or the input ' ...
                'can directly be some period within the sample']); 
            
end

% Approximate diffuse initialization
if args.kappa==1
    warning_msg('Diffuse initialization','Much higher covariance scaling usually required (currently 1)...');
end

% alg_Universal specifics
% -> state space pruning is implemented only in this algo.
% -> triangularization is not allowed
if args.algo~=14
    args.sspruning = 0;
else
    args.triangularize = 0;
end

%% Helper options
args.isData = true;% To be overriden if only shocks are in the input DB

%% Output

if nargout>0
    varargout{1} = args;
end

%% Support functions

    function res = definition(args)
        
    to_print = cell(0,0);
    to_print{1,1} = 'OPTION';
    to_print{1,2} = 'DEFAULT VALUE';
    to_print{1,3} = 'COMMENT';
    to_print{2,1} = '#=line#';

    to_print(end+1,:) = {'status:',args.status,'... show/hide progress information in command window'};
    to_print(end+1,:) = {'range:',args.range,  '... time span of the plotted data, entire time series are plotted by default'};
    to_print(end+1,:) = {'tv_covmat:',args.tv_covmat,'... time-varying shock covariances'};
    to_print(end+1,:) = {'tv_trends:',args.tv_trends,'... time-varying stochastic trends'};
    
    to_print{end+1,1} = '#>>> Output format <<<#';% Category name
    to_print(end+1,:) = {'gaps:',args.gaps,'... Deviations from steady state (=1), or levels returned (=0)'};
    to_print(end+1,:) = {'explodeOutput:',args.explodeOutput,'... 1: final results as struct of individual tsobj()'};
    to_print(end+1,:) = {'','',                              '... 0: final results as one tsobj() '};
        
    to_print{end+1,1} = '#>>> Initial condition <<<#';% Category name
    to_print(end+1,:) = {'ini_vec:',args.ini_vec,    '... user-supplied initial state vector'};
    to_print(end+1,:) = {'ini_covar:',args.ini_covar,'... user-supplied covariance matrix of the prediction errors in the state vector'};
    to_print(end+1,:) = {'kappa:',args.kappa,'... variance scaling for the initial condition of nonstationary models'};
    to_print(end+1,:) = {'','',                      '... Inf: exact diffuse initial condition'};
    to_print(end+1,:) = {'','',                      '... within interval (0,Inf): approximate diffuse initial condition'};
    to_print(end+1,:) = {'','',                      '... 0: fixed initial condition'};
    to_print(end+1,:) = {'ini_obs:',args.ini_obs,'... Fixed initial condition for the observables with trend'};
    to_print(end+1,:) = {'','',                      '... ''zero'' - no deviation from the trend assumed at the beginning of the sample'};
    
    to_print{end+1,1} = '#>>> Lyapunov equation solver options <<<#';% Category name
    to_print(end+1,:) = {'lyapunov_tol:',args.lyapunov_tol,'... tolerance for residuals of P = F*P*F'' + G*Q*G'' equation'};
    to_print(end+1,:) = {'lyapunov_maxiter:',args.lyapunov_maxiter,'... maximum # of iterations'};
    
    to_print{end+1,1} = '#>>> Threshold values <<<#';% Category name
    to_print(end+1,:) = {'stability_thresh:',args.stability_thresh,'... unit root threshold'};
    to_print(end+1,:) = {'singularity_thresh:',args.singularity_thresh,'... threshold for identification of dimensions of singularity'};
    to_print(end+1,:) = {'','',            '       (used in computations of matrix inverses)'};
    to_print(end+1,:) = {'kalman_tol:',args.kalman_tol,'... maximum value deemed as zero'};
    
    to_print{end+1,1} = '#>>> Decomposition into observables <<<#';% Category name
    to_print(end+1,:) = {'decomp:',args.decomp,'... triggers computation of decomposition'};
    to_print(end+1,:) = {'','',              '       0/1 switch works, or a start period'};
    
    to_print{end+1,1} = '#>>> Algorithm selection <<<#';% Category name
    to_print(end+1,:) = {'algo:',args.algo,'... Kalman algorithm'};
    to_print(end+1,:) = {'','',            '       1: standard multivariate filter/smoother'};
    to_print(end+1,:) = {'','',            '       2: sequential processing'};
    to_print(end+1,:) = {'','',            '       3: fast smoother'};
    to_print(end+1,:) = {'','',            '       4: universal (combination of the above) - the only choice for exact diffuse initialization'};
    to_print(end+1,:) = {'sequential:',args.sequential,'... 0/1 switch forcing sequential processing of the observables [option compatible only with algo=4]'};
    to_print(end+1,:) = {'','',            '       otherwise algo=2 can be used; Sequential processing in general lasts longer but the results are very accurate'};
    to_print(end+1,:) = {'triangularize:',args.triangularize,'... 0/1 switch triggering system transformation which results in block-triangulatization of the transition matrix'};
    to_print(end+1,:) = {'sspruning:',args.sspruning,'... 0/1 state space pruning switch'};
    to_print(end+1,:) = {'','',            '       filtering/smoothing can be done on pruned version of the model w/o non-predetermined variables'};
    to_print(end+1,:) = {'sparsity:',args.sparsity,'... 0/1 switch; sparsity patterns can be exploited in large models'};
    
    res.to_print = to_print;
    res.opt_call = 'kalman(m,db,options)';
    
    end %<definition>

end %<eof>