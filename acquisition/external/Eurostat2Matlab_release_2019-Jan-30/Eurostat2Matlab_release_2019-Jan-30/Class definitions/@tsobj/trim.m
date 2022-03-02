function out = trim(this,varargin)
% 
% Suggested usage:
% trim(this,2002:2005);     -> works for all frequencies, including daily data
% trim(this,2002q2:2005q1); -> quarterly data
% trim(this,2002m2:2005m1); -> monthly data
% 
% trim(this,'2002-02-01:2002-02-20'); -> daily data <"-" must be used as delimiter!!>
% trim(this,'2002-02'); -> entire February data set
% trim(this,'2002-02:2003-01');
% trim(this,2002:2005);
% 
% Leading/trailing NaNs
% =====================
% In general both leading and trailing NaN values get erased when calling trim() fcn.
% This can of course result in an empty time series object.
% 
% trim(this); -> full range retained, only leading/trailing NaNs get dropped out
% 
% SEE ALSO: trimNaNs(this,range); -> output range always in line with input range, 
%                                    possibly NaNs on output.
% 

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Empty result
if isempty(this.tind)
   gen_empty_tsobj()
   return
end

%% Input range

if nargin==1 % ### Still can trim away the NaNs ###
    
    if any(isnan(this.values(:)))
        range = this.range;
        tind = range2tind(range);
        % >>>
        where = (1:length(range)).';
        trim_step();
        % <<<
        
        return
        
    else
        out = this;
        return
       
    end
    
else % User-supplied range
    range = varargin{1};
    
end

%% Data frequency
freq = this.frequency;

%% Cell range within bounds

if iscell(range)
    [~,where] = ismember(range,this.range);
    if ~any(where(:)==0)        
        % >>>
        trim_step();
        % <<<        
        return
        
    end
end

%% Non-cell range + cell range outside bounds

subtind = tindrange(freq,range);

% tind/range
if subtind(1) < this.tind(1)
   start_new = this.tind(1);
elseif subtind(1) > this.tind(end)
   gen_empty_tsobj();
   return
else
   start_new = subtind(1); 
end
if subtind(end) > this.tind(end)
   finish_new = this.tind(end); 
elseif subtind(end) < this.tind(1)
   gen_empty_tsobj();
   return
else
   finish_new = subtind(end); 
end

[tind,range] = dynammo.tsobj.tind_build(freq,start_new,finish_new);
    
% >>>
[~,where] = ismember(range,this.range);%where=0 never
trim_step();
% <<<

%% Empty time series object generation
    
    function trim_step()
        
        values = this.values(where,:);

        % Leading/trailing NaN values get dropped out
        drop_start = sum(cumsum(       all(isnan(values),2) )==(1:size(values,1)).');
        drop_end   = sum(cumsum(flipud(all(isnan(values),2)))==(1:size(values,1)).');
        values = values(drop_start+1:end-drop_end,:);

        % Update
        this.values = values;
        this.tind = tind(drop_start+1:end-drop_end,1);
        this.range = range(drop_start+1:end-drop_end,1);

        out = this;
        
    end %<trim_step>

    function gen_empty_tsobj()
       out = tsobj();
       out.name = this.name;
       out.techname = this.techname;
       out.frequency = this.frequency;
       out.tind = [];
       out.range = [];
       out.values = [];
    end %<gen_empty_tsobj>

end %<eof>