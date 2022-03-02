function outstr = rand_str()
%
% Generates a random string that can be used as a valid filename,
% or as an extension the a filename
% 
% INPUT: none
% 
% OUTPUT: random string of 8 characters/numbers
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

s = 'AABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

% Find number of random characters to choose from
numRands = length(s); 

% Specify length of random string to generate
sLength = 8; % !!! This is not a place to play around, e.g. x12() needs exactly 8 chars for repstr('\b',x) to work properly...

% Generate random string
outstr = ['rnd_' s(ceil(rand(1,sLength)*numRands))];

end %<eof>