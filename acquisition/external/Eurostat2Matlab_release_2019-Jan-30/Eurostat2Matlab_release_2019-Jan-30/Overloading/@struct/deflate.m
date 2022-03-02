function in = deflate(in,deflator,base)
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

%% Body

intsobj = implode(in);
if isstruct(intsobj)
    error_msg('tsobj() scaling','Input struct() contains multiple frequencies...');
end

% Scale series
intsobj = deflate(intsobj,deflator,base);

% Process tsobj() only
fields = intsobj.techname;

for ii = 1:length(fields)
   in.(fields{ii}) = intsobj*(fields{ii});% Note that here tscoll() becomes tsobj() per output field
end

end %<eof>