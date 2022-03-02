function hpstudio(in)
%
% Real time calibration of 'lambda' parameter for HP filter
%
% INPUT: this ...tsobj()
%
% OUTPUT: none
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

tsin = implode(in);
if isstruct(tsin) %&& ~any(ismember(upper(fieldnames(tsin)),{'YY';'QQ';'MM';'DD'}))
    error_msg('HP filter studio','Unique data frequency on input is required...');
    %error_msg('HP filter studio','Input Unrecognized...');
end
    
hpstudio(tsin);

end %<eof>