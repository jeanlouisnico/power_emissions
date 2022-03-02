
clear all;
close all;

% Optional font type setting
% set(0,'defaultAxesFontName','Calibri');
% set(0,'defaultTextFontName','Calibri');

% Load data from spreadsheet
t = tsobj('fan_data.xlsx','sheetname','Sheet1');

%% Body

% Style definition
st = struct();
st.FaceColor = [123 114 175]./255;

% Fan chart creation
plot(t,'type','fan','maxticks',4,'style',st,'A4','doc1','title',' ');% Empty title prevents legend from being created

% Legend using external legendflex() -> we want narrower legend items
objs = cat(1,gobj.diffs.ints{:});
hl = struct();
[hl.leg, hl.obj, hl.hout, hl.mout] = legendflex(objs,{'90%','70%','50%','30% confidence interval'}, ...
                                     ...'anchor', {'nw','nw'}, ...
                                     ...'buffer', [5 -5], ...
                                        'ncol', 4, ...
                                        'fontsize', 7, ...
                                        'fontname','Calibri', ...
                                        'xscale', 0.2, ...
                                        'box', 'off');   
% Space for legend     
pos = get(gobj.sub,'Position');
pos(2) = pos(2) + 0.1;
pos(4) = pos(4) - 0.1;

% Manual cropping along sides
buf_ = pos(1)/2;
pos(1) = buf_;
pos(3) = pos(3) + 2*buf_;

set(gobj.sub,'Position',pos);

set(hl.leg,'Units','normalized');
pos = get(hl.leg,'Position');
pos(2) = 0.01;
pos(1) = (1-pos(3))/2;
set(hl.leg,'Position',pos);

% Optional saving
% dynammo.export.svg(gobj,'inflace.svg','');

%% Re-coloring
cellfun(@(x) set(x,'FaceColor',[66 170 93]./255),gobj.diffs.ints);
%     types = get(hl.leg.PlotChildren_I,'type');
%     FaceExists = regexpi(types,'(patch|bar)');
%     FaceAlphas = get(tmp.PlotChildren_I(cellfun(@double,FaceExists)==1),'FaceAlpha');
ch = get(hl.leg,'children');
FaceExists = regexpi(get(ch,'type'),'patch');
isPatch = ~cellfun('isempty',FaceExists);
    
    alphas = linspace(0,1,4+2);% +2 is here because we will trim the extreme values in the end (full opacity and full transparency)
    alphas = alphas(2:end-1);
    alphas = flipud(alphas(:));
    
chPatch = cat(1,ch(:));
chPatch = chPatch(isPatch);
for ii = 1:4
    chPatch(ii).FaceAlpha = alphas(ii);
end

% Optional saving
% dynammo.export.svg(gobj,'gdp.svg','');

%<eof>                                    