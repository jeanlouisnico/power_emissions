function varargout = more_digits(in,varargin)
%
% Displays Matlab numbers with a predefined # of digits
% - works with tsobj() as well :)
% 
% INPUT: in ...input values
%       [# of digits] ...default value == 8
% 
% OUTPUT: copy of the input
%
% Test matrix: [randn(4,5);nan nan nan nan -Inf;zeros(1,5);1e-12 -1e-12 150 -1e-8 nan].'
% 
%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Store step
if nargout>0
   varargout{1} = in;
   return
end

%% # of digits
if ~isempty(varargin)
    digits_to_print = varargin{1};
else
    digits_to_print = 8;
end

%% tsobj() input
if isa(in,'tsobj')
    display(in,digits_to_print); % Matlab default is 4 (format short)
    return
end

%% struct() input
if isa(in,'struct')

    fields = fieldnames(in);
    
    % Length of fields
    fmax = max(cellfun(@length,fields));
    fmax = sprintf('%.0f',fmax);
    %vfields = strvcat(fields);
    %vfields = mat2cell(vfields,ones(size(fields,1),1),size(vfields,2));

    for ii = 1:length(fields)
       if isa(in.(fields{ii}),'double') && isscalar(in.(fields{ii}))
            linestring = ['\t%' fmax 's : ' '%.' sprintf('%.0f',digits_to_print) 'f\n'];
            fprintf(linestring,fields{ii},in.(fields{ii}));
       else
            linestring = ['\t%' fmax 's : ' 'non-scalar input\n'];
            fprintf(linestring,fields{ii});           
       end
    end
    fprintf('\n');
    return
end

%% Multidimensional tensors
if ~ismatrix(in)
   builtin('display',in);
   return
end

%% Body
if ~isa(in,'double')
   error_msg('Input','More digits can be revealed from "double" input only (i.e. scalar, matrix)...'); 
end

% keyboard;
% Determine # of digits per column
[row,col] = size(in);
infornan = isinf(in) | isnan(in);
thresh = 10^-digits_to_print;
in_old = in;% >>>

in(abs(in)<thresh) = 0;
% keyboard;
digs = max(ones(1,col), ...
         ~cellfun(@(x) all(isinf(x) | isnan(x) | abs(x)<thresh),num2cell(in,1)) ...
        * digits_to_print);
if any(infornan(:))
    in(infornan) = 1;
end
pos_needed_num = (floor(log10(max(abs(in),[],1)+1)+3)+digs).';
in = in_old;% <<<
pos_needed = sprintfc('%.0f',pos_needed_num);

% Generate line format
if row~=1
    lnini = [' <%' sprintf('%g',ceil(log10(row+1))) 'g>\t'];
else
    lnini = '';
end
linestring = lnini;
% digit_prec = ['.' sprintf('%.0f',digits_to_print) 'f'];
linestring_parts = cell(col,1);
for ii = 1:col
    linestring_parts{ii} = ['%' pos_needed{ii} '.' sprintf('%.0f',digs(ii)) 'f'];
    linestring = [linestring linestring_parts{ii} ' | ']; %#ok<AGROW>  
end
linestring(end-2:end) = '';
linestring = [linestring '\n'];
linestring = strrep(linestring,'% ','%');

% keyboard;
overthresh = 10^-(digits_to_print+10);% to bypass fprintf('',-0) problem
fprintf('\n');
for ii = 1:row
    lstring = linestring;
    isZero = abs(in(ii,:).')<thresh;
%     isPositive = in(ii,:).'>=0;
    
    % Bypass fprintf('%3.1f',-0) problem
    exactZero = in(ii,:).'==0;
    in(ii,exactZero) = in(ii,exactZero) + overthresh;
    
    if any(isZero)
%         keyboard;
        lparts = linestring_parts;
        pos_now = pos_needed_num(:);
        digs_now = digs(:);
        shifts = max(0,digs_now.'-1).';
        pos_now = pos_now - shifts;
        digs_now = digs_now - shifts;
        
        lparts_rep = lparts(isZero);
        shifts = shifts(isZero);
        pos_now = pos_now(isZero);
        digs_now = digs_now(isZero);
        for jj = 1:size(lparts_rep,1)
            lparts_rep{jj} = [lparts_rep{jj} repstr(' ',shifts(jj))];
            lparts_rep{jj} = regexprep(lparts_rep{jj},'\d*',sprintf('%g',pos_now(jj)),'once');    
            lparts_rep{jj} = regexprep(lparts_rep{jj},'(?<=\.)\d*',sprintf('%g',digs_now(jj)),'once');
        end
        lparts(isZero) = lparts_rep;
        
%         lparts(isZero) = repmat({['%5.1f' repstr(' ',7)]},sum(isZero),1);
% %         if all(isZero)
% %             lparts = regexprep(lparts,'(?<=\%)\d*(?=\.)','3');% 0.0 format of length 3
% %         end
%         lparts(isZero) = regexprep(lparts(isZero),'(?<=\%)\d*(?=\.)','-$0');
%         if digits_to_print>1
%             lparts(isZero) = regexprep(lparts(isZero),'(?<=\.)\d*(?=f)','1');
%         end
%         lparts(isZero & isPositive) = ...
%                          regexprep(lparts(isZero & isPositive),'.*',' $0');
%         lparts(~isZero | ~isPositive) = ...
%                          regexprep(lparts(~isZero | ~isPositive),'.*','$0 ');
% %         lparts(isZero | ~isPositive) = ...
% %                          regexprep(lparts(isZero | ~isPositive),'.*','\b$0');    
% %         lparts(exactZero) = regexprep(lparts(exactZero),'(?<=\%)-?\d*\.\d*f','g');
        lstring = strjoin2(lparts,' | ');
        lstring = [lnini lstring '\n']; %#ok<AGROW>
    end
%     keyboard;
    if row~=1
        fprintf(lstring,ii,in(ii,:));
    else
        fprintf(lstring,in(ii,:));
    end
end
fprintf('\n');

end % <eof>