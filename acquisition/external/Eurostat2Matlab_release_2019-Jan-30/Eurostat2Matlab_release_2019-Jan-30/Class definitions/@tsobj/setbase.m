function this = setbase(this,base)
%
% Creates index which equals 1 at specified time period
%
% INPUT: this ...tsobj() or tscoll()
%        base ...e.g. '2010' implies 2010=1 scaling
% 
% OUTPUT: this ...values get modified according to 
%
% NOTE: If the base spans through more than one period, mean value
%       is calculated when scaling
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Input validation
% -> we could as well check whether 'base' period is inside the sample, omitted for speed...
if ~ischar(base)
    error_msg('Base period','When setting new base (such as 2010=1) the range must be specified as string...');
end

%% Body

subobj = struct();
subobj.type = '{}';
subobj.subs = {base};

segm = subsref(this,subobj);
if ~isempty(segm)
    means = mean(segm,'allvals',1);
    means = ones(length(this.range),1)*means;
    this.values = this.values./means;
    
else
    error_msg('Base resetting','The base period is outside the available range...');
end

end %<eof>