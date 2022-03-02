function gobj = plotCall(this,varargin)
%
% Crossroads for predefined plot() calls
%
% INPUT: this ...tsobj()
%       [options]
%
% OUTPUT: gobj ...plot object structure
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body
switch this.plotCallMode
    case 'dbobj_var' % Plots an item (variable/shock) from the dbobj() 
        gobj = plot_dbobj_var(this,varargin{:});
    otherwise
        error_msg('Plotter','Requested plot mode unrecognized',this.plotCallMode);
end

end %<eof>