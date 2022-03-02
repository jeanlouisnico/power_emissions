function this = deflate(this,deflator,base)
%
% Conversion to real terms given deflator
%
% INPUT: this ...input tsobj()/tscoll()
%        deflator ...tsobj() used as price index
%        base ...all series are scaled to 1 at specific period
%
% OUTPUT: this ...series in real terms
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Scaling
this     = setbase(this,base);
deflator = setbase(deflator,base);

%% Real terms
this = trim(this/deflator);

end %<eof>