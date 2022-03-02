function display(this,varargin) %#ok<DISPLAY>
%
% Internal file: no help provided

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

if ~isempty(varargin)
    
    % M2014b+ fix - output name is inside varargin :(
    if ischar(varargin{1})
        digits_to_print = 4; % # of digits to print in command window (default set-up 4)
    else
        digits_to_print = varargin{1};
    end
else
    digits_to_print = 4; % # of digits to print in command window (default set-up 4)
end

[r,c] = size(this.values);
names = this.name;

%% Empty object
if isempty(names)
    disp('Empty object...');
    return
end

%% Generate names string
if ~isempty(names{1})
    name_str = names{1};
else
    name_str = '<n/a>';
end
for ii = 2:length(names)
    if ~isempty(names{ii})
        name_str = [name_str ' | ' names{ii}]; %#ok<AGROW>
    else
        name_str = [name_str ' | <n/a>']; %#ok<AGROW>
    end
end

%% Beginning

fprintf('\n');

if isempty(this.tind)
    % If the name exists, the object can still contain no values
    fprintf('   Empty time series object:\t');
else
    if r>30 % Heading only for longer time series
        fprintf('   Object contents:\t');
    end
end

if r>30 % Heading only for longer time series
    if ~strcmp(name_str,'<n/a>')
        disp(name_str);
    else
        fprintf('<Name not specified>\n');
    end
    fprintf('\n');
end

if isempty(this.tind)
    fprintf('\b\b\n\n');
    return
end

%% Output positioning
% keyboard;
padding = 3; % to acount for minus sign, decimal point, ...
% if all(isnan(this.values))
%     pos_needed = char_int2str( ...
%                     (floor(log10(max(abs(repmat_value(100,size(this.values,2))'),[],1)+1)+ ...
%                                             padding)+digits_to_print)');
% else
%     pos_needed = char_int2str( ...
%                     (floor(log10(max(abs(this.values                           ),[],1)+1)+ ...
%                                             padding)+digits_to_print)');
% end

vals = this.values;
vals(isnan(vals) | isinf(vals)) = 1;% Should be a 3-digit number, but we have padding
% naninf = all(isnan(vals) | isinf(vals),1);
pos_needed_num = floor(log10(max(abs(vals),[],1)+1)+padding)+digits_to_print;
pos_needed = sprintfc('%.0f',pos_needed_num(:));
% keyboard;

%% Line format generation + technames string
linestring = '\t%s';
digit_prec = ['.' sprintf('%.0f',digits_to_print) 'f | '];

technames = this.techname;
tech_no_print = 0;
empty_tech = cellfun('isempty',technames);
if ~all(empty_tech)
    technames(empty_tech) = {'<n/a>'};
else
    tech_no_print = 1;
end

for ii = 1:c
%     if strcmp(nospaces(pos_needed(ii,:)),'NaN')
%         linestring = [linestring '%' '3' digit_prec]; %#ok<AGROW>
%         
%         % Tech block
%         if ~tech_no_print
%             if length(technames{ii}) > (3)
%                technames{ii}(3) = '~';
%                technames{ii}(4:end) = '';
%             else
%                %technames{ii}(end+1:3) = ' '; % Left alignment  
%                technames{ii} = [repstr(' ',3-length(technames{ii})) technames{ii}];% Right alignment
%             end
%         end
%     else

       %linestring = [linestring '%' pos_needed(ii,:) digit_prec]; %#ok<AGROW>
        linestring = [linestring '%' pos_needed{ii} digit_prec]; %#ok<AGROW>
        
        % Tech block
        if ~tech_no_print
           %postech = eval(pos_needed(ii,:));
            postech = pos_needed_num(ii);
            
            if length(technames{ii}) > (postech+0)
               technames{ii}(postech+0) = '~';
               technames{ii}(postech+1:end) = '';
            else
               %technames{ii}(end+1:(postech+0)) = ' '; % Left alignment 
               technames{ii} = [repstr(' ',postech-length(technames{ii})) technames{ii}];% Right alignment
            end
        end
        
%     end
end

linestring(end-2:end) = '';
linestring = [linestring '\n'];
linestring = strrep(linestring,'% ','%');

%% Lines to print
% keyboard;
if strcmpi(this.frequency,'Y')
    pat = ['%' sprintf('%.0f',floor(log10(this.tind(end)))+1) '.0f'];
    for ii = 1:r
        range_prt = strcat(sprintf(pat,this.tind(ii)),':');% tind equals range for yearly data        
        fprintf(linestring,range_prt,this.values(ii,:));
    end
elseif strcmpi(this.frequency,'M')
    for ii = 1:r
        if length(this.range{ii})==6
            range_prt = strcat(this.range{ii},' :');
        else
            range_prt = strcat(this.range{ii},':');
        end
        fprintf(linestring,range_prt,this.values(ii,:));
    end
else
    for ii = 1:r
        range_prt = strcat(this.range{ii},':');
        fprintf(linestring,range_prt,this.values(ii,:));
    end
end
fprintf('\n');

% for ii = 1:r
%     if strcmpi(this.frequency,'M') && length(this.range{ii})==6
%         range_prt = strcat(this.range{ii},' :');
%     elseif strcmpi(this.frequency,'Y')
%         pat = ['%' sprintf('%.0f',floor(log10(this.tind(end)))+1) '.0f'];
%         range_prt = strcat(sprintf(pat,this.tind(ii)),':');% tind equals range for yearly data
%     else
%         range_prt = strcat(this.range{ii},':');
%     end
%     fprintf(linestring,range_prt,this.values(ii,:));
% end
% fprintf('\n');

%% Technames to print

if ~tech_no_print
    techstring = repstr(' ',length(range_prt));
    for ii = 1:length(technames)
        techstring = [techstring technames{ii} ' | ']; %#ok<AGROW>
    end
    
    techstring(end-2:end) = '';
    fprintf('\t%s\n\n',techstring);
end

%% Ending
if r>0
    fprintf('   Object contents:\t');
    if ~strcmp(name_str,'<n/a>')
        disp(name_str);
    else
        fprintf('<Name not specified>\n');
    end
    fprintf('\n');
end

end