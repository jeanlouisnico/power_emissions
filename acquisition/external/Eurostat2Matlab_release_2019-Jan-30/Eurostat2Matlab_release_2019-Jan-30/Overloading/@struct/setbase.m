function in = setbase(in,base)
%
% Creates index which equals 1 at specified 'base' time period
%
% INPUT: in ...struct() containing time series objects
%        base ...e.g. 2010=1 scaling period
%
% OUTPUT: in ...struct() containing scaled tsobj()/tscoll()
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
intsobj = setbase(intsobj,base);

% Process tsobj() only
fields = intsobj.techname;

for ii = 1:length(fields)
   in.(fields{ii}) = intsobj*(fields{ii});% Note that here tscoll() becomes tsobj() per output field
end

end %<eof>