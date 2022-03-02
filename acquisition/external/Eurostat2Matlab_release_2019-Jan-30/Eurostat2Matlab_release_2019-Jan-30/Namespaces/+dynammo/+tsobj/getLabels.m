function [xticks,xlabels] = getLabels(this,varargin)
% 
% ### Function used only internally ###
% 
% Graph horizontal 'tick' and 'labels' generator
% 
% INPUT: this ...tsobj contents as simple struct() entry
%       [maxlabels] ...maximum # of labels in graph
%                           ==0   will trigger default setup, 
%                           ==Inf will generate all ticks according to the data frequency
% 
% OUTPUT: xticks ...vector of returned time positions
%         xlabels...corresponding cell() object containing the labels
% 
% See also: tsobj/timeline() ...used internally for table column names
%           figlabels()      ...utility function

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Ini

freq = this.frequency;
xticks = this.tind;
nx = length(xticks);% isinf() case!
nx_max = nx;

%% Determine # of milestones
if nargin==1 || varargin{1}==0
    if strcmpi(freq,'D')
        maxlabels = 6;
    else
        maxlabels = 12;
    end
else
    large_ = 9999;
    maxlabels = min(varargin{1},large_);% Inf treatment
    nx = large_;
end

%% Data extraction

switch upper(freq)
    case 'Y'
        nx = nx_max;
        temp_ = (1:nx);
        temp_ = temp_(:);
        sixtets = ceil(nx/maxlabels);% maxlabels=6 <default>
        modulus = mod(nx,sixtets);
        if modulus==0
            modulus=sixtets;
        end
        temp_ = temp_(modulus:sixtets:end);
        nx = length(temp_);
       
        xticks = this.tind(temp_);
        xlabels = this.range(temp_);
        
        if all(xticks>1900)
            for ii = 1:nx
               xlabels{ii} = xlabels{ii}(3:4);
            end
        else
            xlabels = strrep(xlabels,' ','');
        end
        
    case 'Q'
        
        % years<1000 case
        if length(this.range{1})<6
            this.range = cellfun(@(x) sprintf('%6s',x),this.range,'UniformOutput',false);
        end
        
        if nx<=8
            temp_ = (1:nx);
            temp_ = temp_(:);
            
        elseif nx <= 16 % biquarterly
            temp_ = (1:nx);
            temp_ = temp_(:);
            if mod(eval(this.range{1}(6)),2)==1       %strcmp(this.range{1}(6),'1') || strcmp(this.range{1}(6),'3')
                temp_ = temp_(1:2:end);
            else
                temp_ = temp_(2:2:end);
            end
            nx = length(temp_);
            
        else % Qyearly  
            nx = nx_max;
            temp_ = (1:nx);
            temp_ = temp_(:);
            firstQ = eval(this.range{1}(6));
            if firstQ==1
               firstQ=5; 
            end
            temp_ = temp_(6-firstQ:4:end);
            nx = length(temp_);
            %temp_ = (1:nx)';
            sixtets = ceil(nx/maxlabels);% maxlabels=6 <default>
            modulus = mod(nx,sixtets);
            if modulus==0
                modulus=sixtets;
            end
            %firstQ = eval(this.range{1}(6));
            temp_ = temp_(modulus:sixtets:end);
            nx = length(temp_);

        end
        
        xticks = this.tind(temp_);
        xlabels = this.range(temp_);
        
        for ii = 1:nx            
            switch xlabels{ii}(6)
                case '1'
                   %xlabels{ii} = ['I/' xlabels{ii}(3:4)];
                    xlabels{ii} = sprintf('I/%s',xlabels{ii}(3:4));
                case '2'
                    xlabels{ii} = 'II';%['II/' xlabels{ii}(3:4)];%
                case '3'
                    xlabels{ii} = 'III';%['III/' xlabels{ii}(3:4)];%
                case '4'
                    xlabels{ii} = 'IV';%['IV/' xlabels{ii}(3:4)];%
            end
        end
        
    case 'M'
        
        % years<1000 case -> would be more difficult :(
%         if length(this.range{1})<6
%             this.range = cellfun(@(x) sprintf('%6s',x),t.range,'UniformOutput',false);
%         end
        
        if nx<=12
            temp_ = (1:nx);
            temp_ = temp_(:);
            
        elseif nx <= 24 % bimonthly
            temp_ = (1:nx);
            temp_ = temp_(:);
            if any(strcmp(this.range{1}(6:end),{'1';'3';'5';'7';'9';'11'}))
                temp_ = temp_(1:2:end);
            else
                temp_ = temp_(2:2:end);
            end
            nx = length(temp_);
            
        elseif nx <= 36 % Mquarterly
            temp_ = (1:nx);
            temp_ = temp_(:);
            if any(strcmp(this.range{1}(6:end),{'1';'4';'7';'10'}))
                temp_ = temp_(1:3:end);
            elseif any(strcmp(this.range{1}(6:end),{'2';'5';'8';'11'}))
                temp_ = temp_(3:3:end);
            else
                temp_ = temp_(2:3:end);
            end
            nx = length(temp_);
            
        elseif nx <= 60 % Mtwiceyearly
            temp_ = (1:nx);
            temp_ = temp_(:);
            start_ = eval(this.range{1}(6:end));
            table_ = [1;6;5;4;3;2;1;6;5;4;3;2];
            temp_ = temp_(table_(start_):6:end);
            nx = length(temp_);  
            
        elseif nx <= 96 % Myearly
            temp_ = (1:nx);
            temp_ = temp_(:);
            start_ = this.range{1}(6:end);
            if strcmp(start_,'1')
                temp_ = temp_(1:12:end);
            else
                temp_ = temp_(12-eval(start_)+2:12:end);
            end
            nx = length(temp_);
            
        else
            nx = nx_max;
            temp_ = (1:nx);
            temp_ = temp_(:);
            start_ = this.range{1}(6:end);
            if strcmp(start_,'1')
                temp_ = temp_(1:12:end);
            else
                temp_ = temp_(12-eval(start_)+2:12:end);
            end
            nx = length(temp_);
            if nx > maxlabels
                while nx > maxlabels
                    if mod(nx,2)==0
                        temp_ = temp_(2:2:end);
                        nx = nx/2;
                    else
                        temp_ = temp_(1:2:end);
                        nx = (nx+1)/2;
                    end
                end
            end
            
        end
        
        xticks = this.tind(temp_);
        xlabels = this.range(temp_);
        
        for ii = 1:nx            
            switch xlabels{ii}(6:end)
                case '1'
                   %xlabels{ii} = ['Jan. ' xlabels{ii}(3:4)];
                    xlabels{ii} = sprintf('Jan. %s',xlabels{ii}(3:4));
                case '2'
                    xlabels{ii}='Feb.';
                case '3'
                    xlabels{ii}='Mar.';
                case '4'
                    xlabels{ii}='Apr.';
                case '5'
                    xlabels{ii}='May';
                case '6'
                    xlabels{ii}='Jun.';
                case '7'
                    xlabels{ii}='Jul.';
                case '8'
                    xlabels{ii}='Aug.';
                case '9'
                    xlabels{ii}='Sep.';
                case '10'
                    xlabels{ii}='Oct.';
                case '11'
                    xlabels{ii}='Nov.';
                case '12'
                    xlabels{ii}='Dec.';
            end
        end
        
    case 'D'
        nx = nx_max;
        temp_ = (1:nx);
        temp_ = temp_(:);
        sixtets = ceil(nx/maxlabels);% maxlabels=6 <default>
        modulus = mod(nx,sixtets);
        if modulus==0
            modulus=sixtets;
        end
        temp_ = temp_(modulus:sixtets:end);

        xticks = this.tind(temp_);
        xlabels = strrep(this.range(temp_),'-01-','-Jan-');
        xlabels = strrep(xlabels,          '-02-','-Feb-');
        xlabels = strrep(xlabels,          '-03-','-Mar-');
        xlabels = strrep(xlabels,          '-04-','-Apr-');
        xlabels = strrep(xlabels,          '-05-','-May-');
        xlabels = strrep(xlabels,          '-06-','-Jun-');
        xlabels = strrep(xlabels,          '-07-','-Jul-');
        xlabels = strrep(xlabels,          '-08-','-Aug-');
        xlabels = strrep(xlabels,          '-09-','-Sep-');
        xlabels = strrep(xlabels,          '-10-','-Oct-');
        xlabels = strrep(xlabels,          '-11-','-Nov-');
        xlabels = strrep(xlabels,          '-12-','-Dec-'); 
        
    otherwise
        dynammo.error.tsobj('Unknown frequency...');
end

end %<eof>