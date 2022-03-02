function varargout = plot(structobj,varargin)
% 
% Plotter of collections of time series objects
% [*] series with mixed frequencies
% [*] spaghetti graphs (reality,tscoll()#1,tscoll()#2,...) -> data frequency assumed identical across entries
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Deal options

args = dynammo.options.plot(structobj,varargin{:});
args.aux_input = true;% Stack control

%% Retain tsobj() input only
%  possibly struct() input for mixed frequency data, overlaid

fields = fieldnames(structobj);
if isempty(fields - {'YY','QQ','MM','DD'}) % Mixed frequencies input (single plot, multiline)
    struct_ready.single_plot_multiline = structobj;
else
    %field_types = cell(length(fields),1);
    for ii = length(fields):-1:1
        now_ = structobj.(fields{ii});
        if ~isa(now_,'tsobj') && ~isstruct(now_)
           structobj = rmfield(structobj,fields{ii});
        end
    end
    struct_ready = structobj;
end

%% Possible built-in call
f = fieldnames(struct_ready);
if isempty(f)
    varargout{:} = builtin('plot',structobj,varargin{:});
    return 
end

%% Spaghetti graphs
if strcmpi(args.type,'spaghetti')
    
    % Block sizes
    spaghetti_blocks = structfun(@(x) size(x,2),struct_ready);
    if spaghetti_blocks(1)~=1
       error_msg('Spaghetti plotter',['The first input field must be a tsobj() ' ...
                                      'of actually realized data, next fields ' ...
                                      'can be collections of time series ' ...
                                      '(spaghetti hairs)...']); 
    end
    ends = cumsum(spaghetti_blocks(:));
    starts = ends+1;
    args.spaghetti_blocks = [[1;starts(1:end-1)] [1;ends(2:end)]];
    
    sc = struct2cell(struct_ready);
    struct_ready = horzcat(sc{:});
    
end

%% tsobj/plot call

outstr = plot(tsobj(),'aux_input',struct_ready, ...
                      'aux_options',args);

%% Output

if nargout==1
    varargout{1} = outstr;
else
    assignin('caller','gobj',outstr); 
end

end %<eof>