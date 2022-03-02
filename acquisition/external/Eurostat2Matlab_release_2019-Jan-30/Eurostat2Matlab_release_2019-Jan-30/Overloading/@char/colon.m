function str = colon(str1,str2)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Overloaded behavior of the builtin ':' operator
% -> 1st input must have been char, otherwise this fcn would not have been called

if length(str1)>=6 && (isletter(str1(5)) || strcmp(str1(5),'-')) % Daily data supported
    
    % Range concatenation
    % Example: str1 = '2012Q1';
    %          str2 = '2012Q4';
    %          str1:str2 should yield a single string '2012Q1:2012Q4'
    str = [upper(str1) ':' upper(str2)];
    
else
    % Standard Matlab behavior:
    % 'A':'Z' -> ABCDEFGHIJKLMNOPQRSTUVWXYZ
    str = builtin('colon',str1,str2);

end

end %<eof>