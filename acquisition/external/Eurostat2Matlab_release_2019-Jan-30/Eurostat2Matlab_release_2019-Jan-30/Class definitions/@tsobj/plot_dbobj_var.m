function gobj = plot_dbobj_var(this,varargin)
%
% Predefined plotter for dbobj() items
%
% INPUT: this ...tsobj()
%        args ...parsed plot options
%
% OUTPUT: gobj ...plot object structure
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

this.plotCallMode = '';

%% Fonts
setFontName('Calibri');
setFontSize(12);

%% Line connecting all realized points
l = diag(this.values);
this.values = [this.values l(:)];
this.name = [this.name;'final'];
this.techname = [this.techname;'final'];

%% Predefined styling
nobj = size(this.values,2);

tit = strrep(this.secret,'_','\_');

this.name = regexprep(this.name,'({|})','\\$0');

st = struct();
st.marker = repmat({'o'},nobj,1);
st.marker{end} = 'none';
st.MarkerSize = repmat_value(3,nobj);

%% Options resolution

% Requested options
args = dynammo.options.plot(this,'style',st,'caption','name','suptitle',tit);
args = rmfield(args,'inputobj');

% Potential user overruling (w/o validation)
% args = process_user_input(args,varargin);
useropts = varargin(1:2:end-1);
uservals = varargin(2:2:end);
for ii = 1:length(useropts)
    args.(useropts{ii}) = uservals{ii};
end

%% Plot call
gobj = plot(tsobj(),'aux_input',this, ...
                    'aux_options',args);

end %<eof>