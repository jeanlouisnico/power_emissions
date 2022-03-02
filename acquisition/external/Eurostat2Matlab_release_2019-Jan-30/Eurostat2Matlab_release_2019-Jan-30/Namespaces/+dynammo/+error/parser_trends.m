function parser_trends(expr)
%
% Internal file: no help provided
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Body

error_msg('Parser',['Declaration of deterministic trends failed. Proper declaration would look like ' ...
                '"x:(+) trend_expression" for linear trend drift, or ' ...
                '"x:(*) trend_expression" for exponential trend. Empty ''trend_expression'', e.g. ' ...
                '"x:(+)" means that the corresponding trend factor will be derived numerically. ' ...
                'Both symbolic and numeric expressions can be inside trend declarations in place ' ...
                'of ''trend_expression''. Fix the following statement:'],expr); 

end %<eof>