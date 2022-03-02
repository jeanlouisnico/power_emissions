function [xticks,xlabels] = figlabels(freq,xlims,maxlabels)
%
% Creates ticks+labels for a graph containing time series data
%
% INPUT: freq  ...frequency 'y'/'q'/'m'/'d'
%        xlims ...[start end] limit in 'tind' notation, e.g. [2001.75 2010.0] for Q data
%        maxlabels ...# of labels, 
%                           ==0   will trigger default setup, 
%                           ==Inf will generate all ticks according to the data frequency
%
% OUTPUT: xticks ...timing in 'tind' notation (axis positions)
%         xlabels...timing in user-friendly format (axis labels)
%
% See also: tsobj/timeline() ...used internally
%           tsobj/labels()   ...works on tsobj()

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input validation
if ~isa(xlims,'double')
   error_msg('Input type','2nd input to figlabels (xlims) must be a 1x2 matrix of time periods in ''tind'' format...'); 
end
if ~any(strcmpi(freq,{'y';'q';'m';'d'}))
   error_msg('Input type','1st input should correspond to the data frequency:',{'y';'q';'m';'d'}); 
end

%% Pick start/end

% Take all possible ticks between xlims given the frequency
[from_,to_] = dynammo.plot.ticksNearEdge(xlims,freq);
    
[tind,range] = dynammo.tsobj.tind_build(freq,from_,to_);

%% Create labels

this_as_struct = struct();
this_as_struct.tind = tind;
this_as_struct.range = range;
this_as_struct.frequency = freq;

[xticks,xlabels] = dynammo.tsobj.getLabels(this_as_struct,maxlabels);

end %<eof>