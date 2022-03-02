function xlabels = timeline(this)
% 
% Generates graph labels for entire time axis of given tsobj()
%  
% USED BY: tableobj/row()
% 
% SEE ALSO: tsobj/labels()
%           figlabels()

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

freq = this.frequency;
xticks = this.tind;
nx = length(xticks);

%% Data extraction

switch freq
    case 'Y'
        xlabels = this.range;%(temp_);
        xlabels = strrep(xlabels,' ','');

    case 'Q'

        xlabels = this.range;%(temp_);
        for ii = 1:nx            
            switch xlabels{ii}(6)
                case '1'
                    xlabels{ii} = ['I/' xlabels{ii}(3:4)];
                case '2'
                    xlabels{ii} = ['II/' xlabels{ii}(3:4)];% Incl year
                case '3'
                    xlabels{ii} = ['III/' xlabels{ii}(3:4)];% Incl year
                case '4'
                    xlabels{ii} = ['IV/' xlabels{ii}(3:4)];% Incl year
            end
        end

    case 'M'

        xlabels = this.range;%(temp_);

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

        xlabels = strrep(this.range,'-01-','-Jan-');
        xlabels = strrep(xlabels,   '-02-','-Feb-');
        xlabels = strrep(xlabels,   '-03-','-Mar-');
        xlabels = strrep(xlabels,   '-04-','-Apr-');
        xlabels = strrep(xlabels,   '-05-','-May-');
        xlabels = strrep(xlabels,   '-06-','-Jun-');
        xlabels = strrep(xlabels,   '-07-','-Jul-');
        xlabels = strrep(xlabels,   '-08-','-Aug-');
        xlabels = strrep(xlabels,   '-09-','-Sep-');
        xlabels = strrep(xlabels,   '-10-','-Oct-');
        xlabels = strrep(xlabels,   '-11-','-Nov-');
        xlabels = strrep(xlabels,   '-12-','-Dec-'); 

    otherwise
        dynammo.error.tsobj('Unknown frequency...');
end

xlabels = xlabels(:);

end %<eof>