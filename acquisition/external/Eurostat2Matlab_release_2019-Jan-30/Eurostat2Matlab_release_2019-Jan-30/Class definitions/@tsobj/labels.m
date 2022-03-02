function [xticks,xlabels] = labels(this,maxlabels)
%
% ### tsobj() wrapper for internal dynammo.tsobj.getLabels() call ###
% Graph horizontal 'tick' and 'labels' generator (works on tsobj!)
% 
% INPUT: this ...tsobj()
%        maxlabels ...maximum # of labels in graph
% 
% OUTPUT: xticks ...vector of returned time positions
%         xlabels...corresponding cell() object containing the labels
% 
% See also: tsobj/timeline() ...used internally for table column names
%           figlabels()      ...utility function (data frequency on input requested)

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

this_as_struct = struct();
this_as_struct.frequency = this.frequency;
this_as_struct.tind = this.tind;
this_as_struct.range = this.range;

[xticks,xlabels] = dynammo.tsobj.getLabels(this_as_struct,maxlabels);

end %<eof>