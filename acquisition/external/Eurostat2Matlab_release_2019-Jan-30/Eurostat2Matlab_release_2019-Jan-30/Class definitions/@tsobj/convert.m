function out = convert(this,varargin)
%
% Convertor of time series objects into specified frequency
% 
% INPUT: this ...tsobj()
%        [varargin] ...options (see below, execute dynammo.options.convert())
% 
% OUTPUT: tsobj() with desired frequency
%
% EXAMPLES: 
% convert(t,'freq','q') -> input gets transformed into quarterly frequency, 
%                          if the input is in monthly/daily frequency, 
%                               the output will be >>> aggregated <<<,
%                          if the input is in yearly frequency, 
%                               the output will be >>> interpolated <<<
% 
% To control the >>> aggregation <<< 
% (e.g. monthly/daily data into quarterly frequency):
% convert(t,'freq','q','aggregation','average') 
%           -> average values per quarter returned
% 
% convert(t,'freq','q','aggregation','lastobs') 
%           -> very last observation from particular quarter returned
% 
% convert(t,'freq','q','aggregation','lastavailable') 
%           -> last numeric value if the 'lastobs' is NaN
% 
% convert(t,'freq','q','aggregation','sum') 
%           -> sum of all values in a quarter (all must be non-NaN)
%                                   
% To control the >>> interpolation <<< 
% (e.g. yearly data into higher daily/monthly/quarterly frequency):
% convert(t,'freq','q','interpolation','clone') 
%           -> particular value will be repeated for all quarters in a given year
% 
% convert(t,'freq','q','interpolation','clone_flow') 
%           -> Flow variables can be cloned so that the sum of 4 quarters in a year 
%               yields the original yearly figure
% 
% convert(t,'freq','q','interpolation','smooth') -> spline interpolation
% 
% convert(t,'freq','q','interpolation','smooth_flow') 
%           -> spline interpolation for flow-type variables
% 
% convert(t,'freq','q','interpolation','linear')
%           -> linear interpolation between two consecutive yearly figures  
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

% ToDo list: interpolation - spline options...

%% Options
args = dynammo.options.convert(varargin{:});
if ~isstruct(args)
   error_msg('Options resolution','This usually happens if you do not enter the function options properly...'); 
end

% NaN treatment
if args.nan_as_zero
   vals = this.values;
   vals(isnan(vals)) = 0;
   this.values = vals;
end

%% Conversion

switch this.frequency
    case 'D'
        switch upper(args.freq)
            case 'M'
                d2m();
            case 'Q'
                d2q();
            case 'Y'
                d2y();
        end
    case 'M'
        switch upper(args.freq)
            case 'M'
                out = this;
            case 'Q'
                m2q();
            case 'Y'
                m2y();
        end
    case 'Q'
        switch upper(args.freq)
            case 'M'
                q2m();
            case 'Q'
                out = this;
            case 'Y'
                q2y();
        end
    case 'Y'
        switch upper(args.freq)
            case 'M'
                y2m();
            case 'Q'
                y2q();
            case 'Y'
                out = this;
        end
end

%% Subfunctions

    function d2m()
        
        first_obs  = this.range{1};
            first_year = eval(first_obs(1:4));
            first_month= eval(first_obs(6:7));
        last_obs   = this.range{end};
            last_year  = eval(last_obs(1:4));
            last_month = eval(last_obs(6:7));
        
        start_  = first_year + (first_month-1)/12;
        finish_ = last_year + (last_month-1)/12;
        
        tind = floor((start_:(1/12):finish_).*1e4)./1e4;
        tind = tind(:);
        range = tind2range(tind,'M');
        
        values = nan(length(range),size(this.values,2));
        
        for ii = 1:length(range)
            range_now = range{ii};
            if length(range_now)==6
                range_now = strrep(range_now,'M','-0');
            else
                range_now = strrep(range_now,'M','-');
            end
            
            time_str = strcat(range_now,'-01:',range_now,'-31');
            switch upper(args.aggregation)
                 case 'AVERAGE'
                        segm = trimNaNs(this,time_str);
                        if ~isempty(segm.range)
                            values(ii,:) = mean(segm);
                        end
                 case 'LASTOBS'
                        segm = trimNaNs(this,time_str);
                        if ~isempty(segm.range)                     
                            values(ii,:) = segm.values(end,:);
                        end
                 case 'LASTAVAILABLE'
                        segm = trim(this,time_str);
                        if ~isempty(segm.range)                       
                            for jj = 1:size(values,2)
                                lastobs = find(~isnan(segm.values(:,jj)),1,'last');
                                if ~isempty(lastobs)
                                    values(ii,jj) = segm.values(lastobs,jj);
                                end
                            end
                        end
                 case 'SUM'
                        segm = trimNaNs(this,time_str);
                        if args.nan_as_zero
                           segm.values(isnan(segm.values)) = 0; 
                        end
                        if ~isempty(segm.range)                        
                            values(ii,:) = sum(segm,'allvals',1); 
                        end
            end
             
        end

        out = tsobj();
        out.name = this.name;
        out.techname = this.techname;
        out.frequency = 'M';
        out.tind = tind;
        out.range = range;
        out.values = values;
        
    end
    function d2q()
            d2m();
            this = out;
            m2q();
    end
    function d2y()
            d2m();
            this = out;
            m2q();
            this = out;
            q2y();
    end
    function m2q()
        
        first_obs  = this.range{1};
            first_year = eval(first_obs(1:4));
            first_month= eval(first_obs(6:end));
        last_obs   = this.range{end};
            last_year  = eval(last_obs(1:4));
            last_month = eval(last_obs(6:end));
        
        if length(this.range) > 6 % 7 and more guarantees existence of the middle block
            
            %month | mod(month,3) | ini_num_months | last_num_months | quarter
            %1    1   3   1   1
            %2    2   2   2   1
            %3    0   1   3   1
            %4    1   3   1   2
            %5    2   2   2   2
            %6    0   1   3   2
            %7    1   3   1   3
            %8    2   2   2   3
            %9    0   1   3   3
            %10   1   3   1   4
            %11   2   2   2   4
            %12   0   1   3   4
            % quadratic polynomial 1.5x^2 - 3.5x + 3 = 0
            % floor((r-1)/3)+1
            ini_per    = 4 - (1.5*(mod(first_month,3))^2 - 3.5*mod(first_month,3) + 3);
            last_per   =      1.5*(mod(last_month, 3))^2 - 3.5*mod(last_month, 3) + 3;
            mid_blocks = (size(this.values,1) - ini_per - last_per)/3; 
            if mid_blocks > 0
                pers_per_block = [ini_per; 3*ones(mid_blocks,1) ;last_per];
            else
                pers_per_block = [ini_per; last_per];
            end
            total_blocks = 1 + mid_blocks + 1;
            from_to = cumsum(pers_per_block);
            pers_from_to = [[1;from_to(1:end-1)+1] from_to];
            values = nan(total_blocks,size(this.values,2));

            for ii = 1:size(values,1)  
                  time_str = sprintf('%s:%s',this.range{pers_from_to(ii,1)},this.range{pers_from_to(ii,2)});
                  switch upper(args.aggregation)
                         case 'AVERAGE'
                             segm = trimNaNs(this,time_str);
                             if ~isempty(segm.range) % if leading/trailing nans    
                                values(ii,:) = mean(segm);
                             end
                         case 'LASTOBS'
                             segm = trimNaNs(this,time_str);
                             if ~isempty(segm.range) % if leading/trailing nans                              
                                 values(ii,:) = segm.values(end,:);
                             end
                         case 'LASTAVAILABLE'
                             segm = trim(this,time_str);
                             if ~isempty(segm.range) % if leading/trailing nans                              
                                 for jj = 1:size(values,2)
                                      lastobs = find(~isnan(segm.values(:,jj)),1,'last');
                                      if ~isempty(lastobs)
                                          values(ii,jj) = segm.values(lastobs,jj);
                                      end
                                 end
                             end
                         case 'SUM'
                             segm = trimNaNs(this,time_str);
                             if args.nan_as_zero
                                segm.values(isnan(segm.values)) = 0; 
                             end                             
                             if ~isempty(segm.range) % if leading/trailing nans   
                                if pers_per_block(ii)~=3 && ~args.nan_as_zero
                                    values(ii,:) = NaN;
                                else
                                    values(ii,:) = sum(segm,'allvals',1);
                                end
                             end
                  end
            end
            
        else % Short series (6 and fewer months)
            
            pokr = true;
            values = '';
            while pokr
                
                if isempty(this.range)
                   break 
                end
                
                ini_per    = 4 - (1.5*(mod(first_month,3))^2 - 3.5*mod(first_month,3) + 3);
                if ini_per <= length(this.range)
                    time_str = strcat(this.range(1),':',this.range(ini_per));
                else
                    time_str = strcat(this.range(1),':',this.range(end));
                    ini_per = length(this.range);
                    pokr = false;
                end

                switch upper(args.aggregation)
                     case 'AVERAGE'
                        segm = trimNaNs(this,time_str{:});
                        if ~isempty(segm.range) % if leading/trailing nans                         
                            values_now = mean(segm);
                        else
                            values_now = nan(1,size(this.values,2));    
                        end
                     case 'LASTOBS'
                        segm = trimNaNs(this,time_str{:});
                        if ~isempty(segm.range) % if leading/trailing nans                         
                             values_now = segm.values(end,:);
                        else
                            values_now = nan(1,size(this.values,2));    
                        end                             
                     case 'LASTAVAILABLE'
                        segm = trim(this,time_str{:});
                        if ~isempty(segm.range) % if leading/trailing nans                           
                             values_now = nan(1,size(this.values,2));
                             for jj = 1:size(values_now,2)
                                  lastobs = find(~isnan(segm.values(:,jj)),1,'last');
                                  if ~isempty(lastobs)
                                      values_now(1,jj) = segm.values(lastobs,jj);
                                  end
                             end
                        else
                            values_now = nan(1,size(this.values,2));    
                        end                               
                     case 'SUM'
                        segm = trimNaNs(this,time_str{:});
                        if args.nan_as_zero
                           segm.values(isnan(segm.values)) = 0; 
                        end                        
                        if ~isempty(segm.range) % if leading/trailing nans
                            if pokr
                                values_now = sum(segm,'allvals',1);              
                            else
                                values_now = NaN;% segment is nonNaN but is shorter than full quarter
                            end
                        else
                            values_now = nan(1,size(this.values,2));
                        end                            
                end
                
                if isempty(values)
                    values =  values_now; 
                else
                    values = [values;values_now]; %#ok<AGROW>
                end
                
                if length(this.range) > ini_per
                    this.range = this.range(ini_per+1:end);
                    this.tind  = this.tind(ini_per+1:end);
                    this.values= this.values(ini_per+1:end,:);
                else
                    break
                end
                
            end %<eow>
            
        end

        out = tsobj(sprintf('%.0fQ%.0f:%.0fQ%.0f',first_year,floor((first_month-1)/3)+1, ...
                                                  last_year, floor(( last_month-1)/3)+1), ...
                    values,this.name);
        out.techname = this.techname;
        
    end
    function m2y()
        m2q();
        this = out;
        q2y();
    end
    function q2m()
        factor = 3;
        values = this.values;
        [r,c] = size(values);
        
        switch upper(args.interpolation)
             case 'CLONE'
                valbin = zeros(r*factor,c);
                for jj = 1:c
                    valnow = transpose(values(:,jj*ones(1,factor)));
                    valbin(:,jj) = valnow(:);
                end
            case 'CLONE_FLOW'
                valbin = zeros(r*factor,c);
                for jj = 1:c
                    valnow = transpose(values(:,jj*ones(1,factor)));
                    valbin(:,jj) = valnow(:)./3;% 3months per quarter
                end
            case 'SMOOTH' % something like spline
                % TODO
                keyboard;
                
            case 'SMOOTH_FLOW' % to match the annual figure in sum
                % TODO
                keyboard;
                
            case 'LINEAR'
                
                valbin = nan(r*factor,c);
                valbin(3:3:end,:) = this.values;
                
                for jj = 1:c
                    nonNaN_1st = find(~isnan(valbin(:,jj)),1,'first');
                    nonNaN_last = find(~isnan(valbin(:,jj)),1,'last');
                    valbin_inside = valbin(nonNaN_1st:nonNaN_last,jj);
                    nanpos = isnan(valbin_inside);

                    nanpos_diff = [0;nanpos(2:end,1)-nanpos(1:end-1,1)];
                    starts = find(nanpos_diff==1);
                    ends   = find(nanpos_diff==-1);

                    for isegm = 1:length(starts)
                        prevind = starts(isegm)-1;
                        afterind = ends(isegm);
                        vals_to_put = linspace(valbin_inside(prevind,1),valbin_inside(afterind,1),afterind-prevind+1);
                        valbin_inside(prevind:afterind,1) = vals_to_put(:);
                    end
                    valbin(nonNaN_1st:nonNaN_last,jj) = valbin_inside;
                end
                this.values = valbin;
                                
        end

        Q_start = this.range{1}(end);
        Q_end   = this.range{end}(end);

        out = tsobj(sprintf('%sM%d:%sM%d',this.range{1}(1:4), (eval(Q_start)-1)*3+1, ...
                                              this.range{end}(1:4),eval(Q_end  )   *3), ...
                                            valbin,this.name);        
        out.techname = this.techname;
        
    end
    function q2y()
 
        first_year = this.range{1};
        first_year = eval(first_year(1:4));
        last_year  = this.range{end};
        last_year  = eval(last_year(1:4));

        values = nan(last_year-first_year+1,size(this.values,2));
        
        %warned = 0;
        
        for ii = 1:size(values,1) 
             year_now = ii + first_year - 1;
                 switch upper(args.aggregation)
                     case 'AVERAGE'
                         segm = trimNaNs(this,sprintf('%d',year_now));
                         if ~isempty(segm.range)                         
                             values(ii,:) = mean(segm);
                         end
                     case 'LASTOBS'
                         segm = trimNaNs(this,sprintf('%d',year_now));
                         if ~isempty(segm.range)                           
                             values(ii,:) = segm.values(end,:);
                         end
                     case 'LASTAVAILABLE'
                         segm = trim(this,sprintf('%d',year_now));
                         if ~isempty(segm.range)                           
                             for jj = 1:size(values,2)
                                  lastobs = find(~isnan(segm.values(:,jj)),1,'last');
                                  if ~isempty(lastobs)
                                      values(ii,jj) = segm.values(lastobs,jj);
                                  end
                             end
                         end
                     case 'SUM'
                         segm = trimNaNs(this,sprintf('%d',year_now));
                         if args.nan_as_zero
                            segm.values(isnan(segm.values)) = 0; 
                         end                         
                         if ~isempty(segm.range)                            
                            values(ii,:) = sum(segm,'allvals',1);  % Overloaded tsobj/sum!!    
                         end
                 end
        end

        out = tsobj(sprintf('%.0f:%.0f',first_year,last_year), ...
                    values,this.name);                
        out.techname = this.techname;
            
    end
    function y2m()
        y2q();
        this = out;
        q2m();
    end
    function y2q()
        
        factor = 4;
        values = this.values;
        [r,c] = size(values);
        
        switch upper(args.interpolation)
             case 'CLONE'
                valbin = zeros(r*factor,c);
                for jj = 1:c
                    valnow = transpose(values(:,jj*ones(1,factor)));
                    valbin(:,jj) = valnow(:);
                end
            case 'CLONE_FLOW'
                valbin = zeros(r*factor,c);
                for jj = 1:c
                    valnow = transpose(values(:,jj*ones(1,factor)));
                    valbin(:,jj) = valnow(:)/4;% 4 quarters per year
                end
            case 'SMOOTH' % something like spline
                % TODO
                keyboard;
            case 'SMOOTH_FLOW' % to match the annual figure in sum
                % TODO
                keyboard;
            case 'LINEAR'
                
                valbin = nan(r*factor,c);
                valbin(4:4:end,:) = this.values;
                
                for jj = 1:c
                    nonNaN_1st = find(~isnan(valbin(:,jj)),1,'first');
                    nonNaN_last = find(~isnan(valbin(:,jj)),1,'last');
                    valbin_inside = valbin(nonNaN_1st:nonNaN_last,jj);
                    nanpos = isnan(valbin_inside);

                    nanpos_diff = [0;nanpos(2:end,1)-nanpos(1:end-1,1)];
                    starts = find(nanpos_diff==1);
                    ends   = find(nanpos_diff==-1);

                    for isegm = 1:length(starts)
                        prevind = starts(isegm)-1;
                        afterind = ends(isegm);
                        vals_to_put = linspace(valbin_inside(prevind,1),valbin_inside(afterind,1),afterind-prevind+1);
                        valbin_inside(prevind:afterind,1) = vals_to_put(:);
                    end
                    valbin(nonNaN_1st:nonNaN_last,jj) = valbin_inside;
                end
                
        end
 
        out = tsobj(sprintf('%sQ1:%sQ4',this.range{1},this.range{end}), ...
             valbin,this.name);
        out.techname = this.techname;
        
    end
    
end %<eof>