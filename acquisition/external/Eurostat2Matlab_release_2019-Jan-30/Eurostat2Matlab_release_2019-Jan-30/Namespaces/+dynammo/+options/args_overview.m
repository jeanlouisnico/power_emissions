function args_overview(inp)
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Example input
% to_print = cell(0,0);
% to_print{1,1} = 'OPTION';
% to_print{1,2} = 'DEFAULT VALUE';
% to_print{1,3} = 'COMMENT';
% to_print{2,1} = '#=line#';
% 
% to_print(end+1,:) = {'filename:',args.filename,'... string indicating file name, possibly with partial or absolute path'};
% to_print(end+1,:) = {'setReadOnly:',args.setReadOnly,'... 1|0 switch to make the output read-only'};
% to_print(end+1,:) = {'overwrite_file:',args.overwrite_file,'... 1|0 switch to allow for file overwriting'};
% 
% to_print{end+1,1} = '#>>> XLS OUTPUT FILE <<<#';% Category name
% to_print(end+1,:) = {'sheetname:',args.sheetname,'... any string free of special characters, spaces allowed'};
% to_print(end+1,:) = {'overwrite_sheet:',args.overwrite_sheet,'... 1|0 switch to allow for sheet overwriting'};
% to_print(end+1,:) = {'freezePanes:',args.freezePanes,'... 1|0 switch to apply useful XLS property (applicable to time series output only)'};
% 
% to_print{end+1,1} = '#>>> non-XLS OUTPUT FILE <<<#';% Category name
% to_print(end+1,:) = {'delimiter:',args.delimiter,'... ","|";"|":"|"\t" (tabulator)'};
% to_print(end+1,:) = {'precision:',args.precision,'... number of digits to keep in the output'};
% to_print(end+1,:) = {'append:',args.append,'... 1|0 switch; Data can be appended to an existing file (not applicable to time series objects)'};
% 
% to_print{end+1,1} = '#>>> DEBUGGING <<<#';% Category name
% to_print(end+1,:) = {'debug:',args.debug,'... 1|0 switch to allow activate the debugging mode (useful if something bad happens)'};

%% Body

to_print = inp.to_print;

r = size(to_print,1);
colwidths = zeros(1,3);
offset = 3;
fprintf('\n');

for icol = 1:3

   % Max length in column
   inchar = cellfun(@ischar,to_print(:,icol));
   for iline = 1:r % Handle nonchar input 
       if inchar(iline)==0
           valuenow = to_print{iline,icol};
           [rnow,cnow] = size(valuenow);
           if iscell(valuenow)
               if rnow==1 && cnow==1
                   if isempty(valuenow{1})
                       to_print{iline,icol} = '{''''}';
                   else
                       keyboard;%todo when needed
                   end
               else
                   keyboard;%todo when needed
               end
           elseif isempty(valuenow)
               to_print{iline,icol} = '';
           elseif isnan(valuenow)
               to_print{iline,icol} = 'NaN';
           elseif isscalar(valuenow)
               to_print{iline,icol} = sprintf('%g',to_print{iline,icol});
           elseif rnow~=cnow % This should be
               if rnow==1 || cnow==1
                   matnow = to_print{iline,icol};
                   pat = '[';
                   if rnow==1
                       delim = ' '; 
                   else % cnow==1
                       delim = ';'; 
                   end
                   for iitemnow = 1:max(rnow,cnow)
                       pat = [pat sprintf('%g',matnow(iitemnow)) delim]; %#ok<AGROW>
                   end
                   pat = pat(1:end-1);
                   pat = [pat ']']; %#ok<AGROW>
                   to_print{iline,icol} = pat;
               else
                   to_print{iline,icol} = 'matrix';
               end
           else
               % Non-standard default option values are to be described in the "comment" section as well
               to_print{iline,icol} = '#####';
           end
       end
   end
   colwidths(icol) = max(cellfun(@length,to_print(:,icol)));

   % Heading
   if icol~=3 % Right alignment
       to_print{1,icol} = [repstr(' ',colwidths(icol) - length(to_print{1,icol}) + offset) to_print{1,icol}];
   else % Left alignment
       to_print{1,icol} = [repstr(' ',offset) to_print{1,icol} repstr(' ',colwidths(icol) - length(to_print{1,icol}))]; 
   end
   fprintf('%s',to_print{1,icol});
end
fprintf('\n');

% Line
fprintf('%s',[repstr(' ',offset) repstr('=',colwidths(1)) ...
              repstr(' ',offset) repstr('=',colwidths(2)) ...
              repstr(' ',offset) repstr('=',colwidths(3))]);
fprintf('\n');
%         keyboard;
% Fields
for iline = 3:r
    if isempty(strfind(to_print{iline,1},'#'))
        to_print{iline,1} = [repstr(' ',colwidths(1) - length(to_print{iline,1}) + offset) to_print{iline,1}];
        %if ischar(to_print{iline,2})
            to_print{iline,2} = [repstr(' ',colwidths(2) - length(to_print{iline,2}) + offset) to_print{iline,2}];
        %else
        %    to_print{iline,2} = [repstr(' ',colwidths(2) - length(to_print{iline,2}) + offset) sprintf('%g',to_print{iline,2})];
        %end
        to_print{iline,3} = [repstr(' ',offset) to_print{iline,3} repstr(' ',colwidths(3) - length(to_print{iline,3}))]; 
        fprintf('%s%s%s\n',to_print{iline,:});
    else % Category name
        fprintf('\n');
        to_print{iline,1} = strrep(to_print{iline,1},'#','');
        to_print{iline,1} = [repstr(' ',offset) to_print{iline,1} repstr(' ',colwidths(3) - length(to_print{iline,1}))];
        fprintf('%s\n',to_print{iline,1});
    end

end
fprintf('\n');

fprintf(['\t' inp.opt_call '\n\n']);

end %<eof>