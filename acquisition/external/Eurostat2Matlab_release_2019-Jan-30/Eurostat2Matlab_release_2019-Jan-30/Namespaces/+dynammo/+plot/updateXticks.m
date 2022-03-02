function updateXticks(obj,evd) %#ok<INUSL>
%
% Automatic update of Xticks after zooming in/out
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% keyboard;% does not work here! look below
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%% Rescale the horizontal axis

% Current axes object
ax = evd.Axes;% cannot run in debug mode, potential keyboard must be located below this line
% keyboard;

% Current horizontal limits
xlims = get(ax,'xlim');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if min(ceil(log10(xlims(2))))<4 % IRFs do not have 'yyyy' year format, only 'y' (4 digits tested)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Pool the timing info
    %     timing = get(ch(indGrand),'Xdata');
    %     timing = cellfun(@(x) transpose(x),timing,'UniformOutput',false);
    %     timing = cat(1,timing{:});

    % Trim the ticks according to the window
    %     range_to_show = timing(timing>=xlims(1) & timing<=xlims(2));
    start_ = ceil(xlims(1));
    end_ = floor(xlims(2));
    if start_<end_
        range_to_show = start_:1:end_;
    else
        range_to_show = end_:1:start_;
    end
    range_to_show = range_to_show(:);
    
    % Generate graph labels
    this.tind = range_to_show;
   %this.range = cellstr(char_int2str(this.tind));
    patt = ['%' sprintf('%d',floor(log10(max(this.tind)))+1) 'd'];
    this.range = sprintfc(patt,this.tind);
                
    this.frequency = 'Y';
    [xticksOUT,xlabelsOUT] = dynammo.tsobj.getLabels(this,0);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else % Usual time series data (not IRFs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    % All data in the graph (lines only)
    ch = get(ax,'children');
    freqGrand = '';
    % indGrand = [];
    for ii = 1:length(ch)
        if strcmpi(get(ch(ii),'Type'),'line') % Only line graphs will matter
            timing = get(ch(ii),'Xdata');

            % Determine the frequency
            freqnow = guessFreq();
            freqGrand = Grand_indices(freqGrand);

        end
    end

    % Take all possible ticks between xlims given the frequency
    [from_,to_] = dynammo.plot.ticksNearEdge(xlims,freqGrand);

    % Get range/tind according to the frequency
    [tind,range] = tindrange(freqGrand,from_,to_);

    % Generate graph labels
    this.tind = tind;
    this.range = range;
    this.frequency = freqGrand;
    [xticksOUT,xlabelsOUT] = dynammo.tsobj.getLabels(this,0);

end
                              
set(gca,'xtick',xticksOUT,'xticklabel',xlabelsOUT);

%% Nested functions
    function freqnow = guessFreq()
        ticks_rest = max(timing-floor(timing));
        if ticks_rest==0
            % Probably yearly data
            freqnow = 'y';
            return
        end
        timing = 4*timing;
        ticks_rest = max(timing-floor(timing));
        if ticks_rest==0
            % Probably quarterly data
            freqnow = 'q';
            return
        end
        timing = 3*timing;% By now multiplied by 12 already
        ticks_rest = max(abs(timing-round(timing)));
        if ticks_rest<=1e-3
            % Probably monthly data
            freqnow = 'm';
            return
        end    
        % If the above conditions do not apply
        freqnow = 'd';
        
    end %<guessFreq>

    function freqGrand_out = Grand_indices(freqGrand_in)
        switch freqnow
            case 'y'
                freqGrand_out = 'y';
            case 'q'
                
                if ~strcmp(freqGrand_in,'y')
                    freqGrand_out = 'q';
                end
            case 'm'
                if ~strcmp(freqGrand_in,'y') && ~strcmp(freqGrand_in,'q')
                    freqGrand_out = 'm';
                end
            case 'd'
                if ~strcmp(freqGrand_in,'y') && ~strcmp(freqGrand_in,'q') && ~strcmp(freqGrand_in,'m')
                    freqGrand_out = 'd';
                end
        end
        
    end%<Grand_indices>



end %<eof>